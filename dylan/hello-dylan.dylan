Module: hello-dylan
Synopsis: A walkfiles(tm) implementation for Dylan
Author: cji

define constant fmt = curry(format-to-string, "%s");
define inline method \+(string1 :: <string>, string2 :: <string> ) => (result :: <string>)
    concatenate(string1, string2);
end;
define inline method is-dir?( dir-path )
    file-exists?(dir-path) & file-type(dir-path) = #"directory";
end;

define inline method ls(dir-path :: <string>) => (files :: <vector>)
    let res = make(<stretchy-vector>);

    local method suffix (kind)
              if(kind = #"directory") "/" else "" end
          end;

    local method gather-files (path, fname, kind)
            let file-path = fmt(path) + fmt(fname) + suffix(kind);
            add!(res, file-path);
          end;

    if (is-dir?(dir-path))
        do-directory(gather-files, dir-path);
        as(<vector>, res);
    else
        make(<vector>);
    end;
end;

define method descendants(dir-path :: <string>, result-stream :: <string-stream>)
    write-line(result-stream, dir-path);
    for (child in ls(dir-path))
        /* recurse! */
        descendants(child, result-stream);
    end;
end;


define function main (name :: <string>, arguments :: <vector>)
    let stream = make(<string-stream>, direction: #"input-output");
    descendants("/home/cji/poligon/comp/", stream);
    format-out(stream-contents(stream));

    // let sorted = sort(remove(d, #f));
    // map(curry(format-out, "%s\n"), sorted);

    exit-application(0);
end function main;

main(application-name(),
     application-arguments());
