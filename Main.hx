import Sys;
import Reflect;
import Std;
import sys.*;
import haxe.io.Path;
import haxe.ds.Option;

// utils; the name is so short for convenience when calling them
class U {
  public static inline function print(arg : Dynamic){
    #if neko
    Sys.println(arg);
    #else
    cpp.Lib.println(arg);
    #end
  }

  public static inline function joinPaths(a:String, b:String) : String {
    return Path.join([a, b]);
  }
}

enum EntryKind {File; Dir;}
// A filesystem entry can only be File or Dir. We can use `switch` on values of
// this type - compiler will warn us if we forget to handle one of those
// (exhaustiveness checking).


class Node {
  public var kind : EntryKind;
  public var path : String;
  // the `files` attribute will have a getter, called `get_files` and no setter
  public var files(get, null) : Array<Node>;

  public function toString(): String {return this.path;}
  public static inline function cmp(a:Node, b:Node) { return Reflect.compare(a.path, b.path); }

  public function new(path:String) {
    this.path = path;
    if(FileSystem.exists(path) && FileSystem.isDirectory(path))
      this.kind = Dir;
    else
      this.kind = File;
  }


  public function get_files() : Array<Node> {
    switch (this.kind){
    case File:
      return [];
    case Dir:
      return FileSystem
        .readDirectory(this.path)
        .map(function (x) {
            return new Node(U.joinPaths(this.path, x));
        });
    }
  }

  public function descendants() : Array<Node> {
    switch(kind) {
    case File:
      return [this];

    case Dir:
      var ret = [];

      for(el in this.files) {
        // recurse!
        for(child in el.descendants()){
          ret.push(child);
        }
      }

      return ret;
    }
  }
}


class Main {
  static private inline function get_files() : Array<Node> {
    var p = Sys.getCwd();
    return (new Node(p)).descendants();
  }

  static public function main() : Void {
    var f = get_files();
    f.sort(Node.cmp);

    for(el in f)
      U.print(el);
  }
}
