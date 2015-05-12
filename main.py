import os
import os.path as P

start = os.getcwd()

isdir = P.isdir
ls = lambda path: map(lambda x: P.join(path,x), os.listdir(path))

def descendants(path, stream):
    stream.append(path)
    if isdir(path):
        map(lambda x: descendants(x, stream), ls(path))

if __name__ == '__main__':
    l = []
    descendants(start, l)
    # print len(l)
    for x in sorted(l):
        print x


# if False:
#     # impossibly fast version
#     class File(object):
#         @staticmethod
#         def new(path):
#             if P.exists(path) and P.isdir(path):
#                 return Dir(path)
#             else:
#                 return File(path)

#         def __init__(self, path):
#             self.path = path

#         def children(self): return []
#         def descendants(self): return []

#     class Dir(File):
#         def children(self):
#             return map(lambda x: P.join(self.path, x), os.listdir(self.path))

#         def descendants(self):
#             kids = self.children()
#             result = []

#             for k in map(File.new, kids):
#                 result.append(k.path)
#                 result.extend(k.descendants())

#             return result
