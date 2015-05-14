#include <sys/stat.h>
#include <set>
#include <memory>
#include <string>
#include <iostream>
#include <vector>
#include <cstdio>
#include <sys/types.h>

#include <dirent.h>
#include <unistd.h>


using namespace std;

const int LIMIT = 1200;

DIR* opendir(string &p) {
  return opendir((const char *)p.c_str());
}

vector<string> ls(const string &path ){
  vector<string> res, empty;
  struct stat finfo;

  stat(path.c_str(), &finfo);

  if ( !S_ISDIR(finfo.st_mode) )
    return empty;

  auto dir = opendir(path.c_str());

  while(dirent* dd = readdir(dir)){
    string s(dd->d_name);
    if( s != "." && s != "..")
      res.push_back(
        (path + "/" + s)
      );
  }
  closedir(dir);
  return res;
}

set<string> descendants(const string &path){
  set< string > q, res; // sets are sorted by default
  q.insert(path);

  while( q.size() > 0 ){
    auto it = q.begin();
    string el = *it;
    q.erase(it);
    res.insert(el);
    for(auto& el2 : ls(el)) { q.insert(el2); }
  }

  return res;
}

unique_ptr< char > cwd(){
  unique_ptr< char >  c(new char[LIMIT]);
  getcwd(c.get(), LIMIT);
  return c;
}


int main(){
  const string s = cwd().get();
  for(auto& a: descendants(s)){ cout << a << endl; }
  return 0;
}
