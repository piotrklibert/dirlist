#include <sys/stat.h>
#include <set>
#include <memory>
#include <string>
#include <iostream>
#include <vector>
#include <deque>
#include <cstdio>
#include <sys/types.h>

#include <dirent.h>
#include <unistd.h>

using namespace std;

static const int LIMIT = 1200;
static const vector<string> empty;

DIR* opendir(string &p) { return opendir((const char *)p.c_str()); }

vector<string> ls(const string &path ){
  vector<string> res;

  struct stat finfo; stat(path.c_str(), &finfo);
  if ( !S_ISDIR(finfo.st_mode) )
    return empty;

  auto dir = opendir(path.c_str());

  while(dirent* dd = readdir(dir)){
    string s(dd->d_name);
    if( s != "." && s != "..")
      res.push_back(path + "/" + s);
  }
  closedir(dir);
  return res;
}

set<string> descendants(const string path){
  deque< string > input;
  set< string > output;

  output.insert(path);
  input.push_front(path);

  while( input.size() > 0 ){
    auto fpath = input.front();
    input.pop_front();
    output.insert(fpath);
    for( const auto& el : ls(fpath) ) input.push_back(el);
  }

  return output;
}

unique_ptr< char > cwd(){
  unique_ptr< char >  c(new char[LIMIT]);
  getcwd(c.get(), LIMIT);
  return c;
}


int main(){
  const string s = cwd().get();
  for(auto& a: descendants(s))
    cout << a << endl;
  return 0;
}
