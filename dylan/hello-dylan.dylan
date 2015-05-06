Module: hello-dylan
Synopsis: A walkfiles(tm) implementation for Dylan
Author: cji

define constant fmt = curry(format-to-string, "%s");
define method \+(string1 :: <string>, string2 :: <string> ) => (result :: <string>)
    concatenate(string1, string2);
end;
define method is-dir?( dir-path )
    file-exists?(dir-path) & file-type(dir-path) = #"directory";
end;


define method println (#rest things)
    let output = make(<string-stream>, direction: #"input-output");
    for (thing in things) format(output, "%s", thing); end;
    format-out("%s\n", stream-contents(output));
    force-out();
end;


define method ls(dir-path :: <string>) => (files :: <vector>)
    let res = make(<stretchy-vector>);

    local method suffix (kind) if(kind = #"directory") "/" else "" end end;
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

define method descendants(dir-path :: <string>)
    let res = make(<stretchy-vector>);
    add!(res, dir-path);
    for (child in ls(dir-path))
        /* recurse! */
        for(c in descendants(child)) add!(res, c); end;
    end;
    res;
end;


define function main (name :: <string>, arguments :: <vector>)
    let d = sort(descendants("/home/cji/poligon/comp/"));
    map(println, d);
    exit-application(0);
end function main;

main(application-name(),
     application-arguments());
