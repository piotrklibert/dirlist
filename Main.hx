import Sys;
import Reflect;
import Std;
import sys.*;
import haxe.io.Path;
import haxe.ds.Option;


// this gives us exhaustiveness checking when `switch`ing on values of this type
enum EntryKind {
  File;
  Dir;
}


class U { // utils
  public static inline function print(arg : Dynamic){
    #if neko
    trace("uuu!");
    #else
    cpp.Lib.println(arg);
    #end
  }

  public static inline function joinPaths(a:String, b:String) : String {
    return Path.join([a, b]);
  }
}



class Node {
  public var kind : EntryKind;
  public var path : String;

  public function new(path:String) {
    this.path = path;

    if( FileSystem.exists(path) && FileSystem.isDirectory(path) ){
      this.kind = Dir;
    }
    else
      this.kind = File;
  }

  // the `files` attribute will have a getter, called `get_files` and no setter
  public var files(get, null) : Array<Node>;

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



  public function toString(): String {
    return this.path;
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

  public static inline function cmp(a:Node, b:Node) {
    return Reflect.compare(a.path, b.path);
  }
}



class Main {
  static private inline function get_files() : Array<Node> {
    var p = Sys.getCwd();
    return (new Node(p)).descendants();
  }

  static public function main():Void {
    var f = get_files();
    f.sort(Node.cmp);

    for(el in f)
      U.print(el);
  }
}
