import sets
import os                       # filesystem-related stuff
import algorithm                # sorting

proc getcwd(cstring, int):cstring {. importc: "getcwd", header: "<unistd.h>" .}

var buf = ""
let root_path = $getcwd(buf, 40)

proc isRealPath(fname : string) : bool = fname != "." and fname != ".."


proc ls(path:string): seq[string] =
  var result = newSeq[string]()
  if not path.dirExists():
    return @[]

  for kind, subpath in walkDir(path):
    let fname = subpath.extractFilename()
    if fname.isRealPath:
      result.add(subpath)

  return result


proc descendants(root: string, output : var seq[string]) =
  var
    toTest = @[root]
    current = ""

  while len(toTest) > 0:
    current = toTest[0]
    output.add(current)

    toTest.del(0)
    toTest.add(ls(current))


################################################################################

var dbuf : seq[string] = @[]

descendants(root_path, dbuf)
algorithm.sort(dbuf, cmp)

for el in items(dbuf):
  echo el


# var d = opendir("/home/cji")
# var ff = readdir(d)
