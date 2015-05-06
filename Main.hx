import Sys;
import Reflect;
import Std;
import sys.*;
import haxe.io.Path;
import haxe.ds.Option;

enum Entry {
  F(path: String);
  D(path: String);
}

class Node {
  public var kind : Entry;
  public var files(get, null) : Array<Node>;

  public function new(p:String) {
    if( FileSystem.exists(p) && FileSystem.isDirectory(p) ){
      this.kind = D(p);}
    else
      this.kind = F(p);
  }

  @:op(A < B)
  public static function cmp(a:Node, b:Node) : Int {
    var b = a.unwrap() < b.unwrap();
    return if(b) -1 else 1;
  }

  public function unwrap() {
    return switch(this.kind) {
    case F(p): p;
    case D(p): p;
    }
  }

  public function get_files() : Array<Node> {
    switch (this.kind){
    case F(_):
      return [];
    case D(path):
      return FileSystem
        .readDirectory(path)
        .map(function (x) {
            return new Node(Path.join([path, x]));
        });
    }
  }

  public function toString(): String {
    return this.unwrap();
  }


  public function descendants() : Array<Node> {
    switch(kind) {
    case F(p):
      return [this];
    case D(p):
      var ret = [];
      for(el in this.files) {
        // ret.push(el);
        for(child in el.descendants()){
          ret.push(child);
        }
      }

      ret.sort(Node.cmp);

      return ret;
    }
  }
}


class Main {
  static private function get_files() : Array<Node> {
    return (new Node("/home/cji/poligon/comp/")).descendants();
  }

  static public function main():Void {
    for(el in get_files())
      trace(el);
  }
}
