Module: hello-dylan
Synopsis: A walkfiles(tm) implementation for Dylan
Author: Piotr Klibert

define constant fmt = format-to-string("%s", _);

define inline method \+(string1 :: <string>,
                        string2 :: <string> ) => (result :: <string>)
    concatenate(string1, string2);
end;

define inline method is-dir?( dir-path )
    file-exists?(dir-path) & file-type(dir-path) = #"directory";
end;

// define macro lambda
//     { lambda (?:name) ?b:body end }
//         => { local method (?name) ?b end }
// end macro lambda;
define macro lambda
    {lambda (?=name, ...) ?body end }
        => { method (?name, ...) ?body end}
end macro lambda;

define inline method ls(dir-path :: <string>) => (files :: <vector>)
    let res = make(<stretchy-vector>); // `make` is the same as `new` in eg. JS
                                       // `<stretchy-vector>` is a common resizable container class

    let ress = lambda (x, b) x+1; end;

    ress(1,2);

    exit-application(0);



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

define method descendants(dir-path :: <string>, result-stream :: <string-stream>)
    write-line(result-stream, dir-path);
    for (child in ls(dir-path))
        /* recurse! */
        descendants(child, result-stream);
    end;
end;


define function main (name :: <string>, arguments :: <vector>)
    let stream = make(<string-stream>, direction: #"input-output");
    descendants(as(<string>, working-directory()), stream);

    let s = stream-contents(stream);
    let s = split-lines(s);

    for(a in map(curry(format-to-string, "%s\n"), sort(s)))
        format-out("%s", a);
    end;

    exit-application(0);
end function main;

main(application-name(),
     application-arguments());
