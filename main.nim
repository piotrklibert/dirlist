import os                       # filesystem-related stuff
import algorithm                # sorting
import strutils                 # string formatting


const MAX_PATH_LEN = 40         # completely arbitrary number!

type
  DirSet = tuple[res: seq[string], count: int]


# straight from C lib
proc getcwd(cstring, int) : cstring {.importc: "getcwd", header: "<unistd.h>".}


proc isRealPath(fname : string) : bool = fname != "." and fname != ".."

# both get the first element and delete it from a collection. This works with
# anything that defines `[]` and `del` operations.
template pop(s : expr) : expr =
  let tmp = s[0]
  s.del(0)
  tmp


proc currentDirectory() : string =
  var char_buf: array[MAX_PATH_LEN, char] # a chunk of memory like in C,
                                          # allocated on stack and auto-freed
  discard getcwd(char_buf, MAX_PATH_LEN)  # `getcwd` writes into supplied buffer

  return $( char_buf ) # `$` for type array[char] (alias type cstring) returns a
                       # memory-safe, freshly allocated string


# Main code:

proc listDir(path:string): DirSet =
  if not path.dirExists:        # if path is invalid (not existing or not a dir)
    return (res: @[], count: 0) # it can't have any children

  var
    count = 0
    output = newSeq[string]()

  for kind, subpath in walkDir(path): # walkDir(p) is an iterator from `os`
      if subpath.extractFilename().isRealPath:
        output.add(subpath)
      count += 1

  result = (res: output, count: count)


proc descendants(root: string) : DirSet =
  var
    count : int
    output : seq[string] = @[]
    remaining = @[root]         # let's start with the dir we got from caller

  while len(remaining) > 0:
    var current = remaining.pop()
    output.add(current)
    # note: `add` with empty seq is a no-op
    let (kids, c) = listDir(current)
    if c > 0:
      remaining.add(kids)       # save all the files for visiting later
      count += 1                # also count dirs while we're at it

  result = (res: output, count: count)


when isMainModule:              # only compiled if not to dll
  var (results, dircount) = currentDirectory().descendants
  algorithm.sort(results, cmp)    # `cmp` is from `system` module

  discard results.map(proc (x):string = echo x)
  echo "We've counted $1 directories." % [$(dircount)]
