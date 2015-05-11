# -*- mode: nim-mode -*-
import os                       # filesystem-related stuff
import algorithm                # sorting


const root_path = "/home/cji/poligon/comp/"

proc shouldBeVisible(fname : string) : bool = fname != "." and fname != ".."


iterator chain[T](a:iterator():T, b:iterator():T) : iterator() =
  for x in a():
    yield x
  for x in b():
    yield x


proc ls(path:string): seq[string] =
  var result : seq[string] = @[]
  if not path.dirExists():
    return result

  for kind, subpath  in walkDir(path):
    let fname = subpath.extractFilename()
    if fname.shouldBeVisible and not result.contains(fname):
      result.add(subpath)

  return result


proc unionSeqs[T](a:seq[T], b:seq[T]) : seq[T] =
  var result : seq[T] = a
  for x in items(a & b):
    if not result.contains(x):
      result.add(x)
  return result


proc descendants(root: string) : seq[string] =
  var
    stack = ls(root)
    result : seq[string] = @[]

  if len(stack) == 0:
    return @[root]

  for el1 in items(stack.map(descendants)):
    for el2 in items(el1): # for option-like unwrapping
      result.add(el2)

  return stack.unionSeqs(result)


################################################################################

var flist = descendants(root_path)
algorithm.sort(flist, cmp)

echo root_path
for el in items(flist):
  echo el
