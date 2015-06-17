import os
import os.path as P

start = os.getcwd()
isdir = P.isdir
ls    = lambda path: map(lambda x: P.join(path,x), os.listdir(path))

def descendants(path, stream):
    stream.append(path)
    if isdir(path):
        map(lambda x: descendants(x, stream), ls(path))


def main():
    l = []
    descendants(start, l)
    for x in sorted(l):
        print x

if __name__ == '__main__':
    main()
