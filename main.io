Sequence isRealPath := method(
    (self endsWithSeq("..") or self endsWithSeq(".")) not
)

Sequence isDir := method(
    ret := false
    try(
        Directory with(self) items; ret := true
    ) catch(Error,
        ret := false
    )
    ret
)

File isDir := method(self path isDir)
Directory isDir := method(self path isDir)

ls := method(dir,
    res := list()
    dir items foreach(v, if(v path isRealPath, res append(v)))
    res
)

descendants := method(dir,
    res := list()
    res append(dir)
    if(dir isDir,  ls(dir) foreach(x, descendants(x) foreach(v, res append(v))))
    res
)

descendants(Directory with("/home/cji/poligon/comp/")) map(path) sort foreach(println)
