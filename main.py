import os
import os.path as op

class File(object):
    @staticmethod
    def new(path):
        if op.exists(path) and op.isdir(path):
            return Dir(path)
        else:
            return File(path)

    def __init__(self, path):
        self.path = path

    def children(self): return []
    def descendants(self): return []

class Dir(File):
    def children(self):
        return map(lambda x: op.join(self.path, x), os.listdir(self.path))

    def descendants(self):
        kids = self.children()
        result = []

        for k in map(File.new, kids):
            result.append(k.path)
            result.extend(k.descendants())

        return result

root_path = "/home/cji/poligon/comp/"

print root_path
for x in sorted(Dir(root_path).descendants()):
    print x
