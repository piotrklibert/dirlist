const
  C = 100
  cache_fname = ".cache"
  headers = [
    "GET /",
    "User-Agent: curl/7.32.0",
    "Host: openexchangerates.org",
    "Accept: */*"]

proc get_headers() : string =
  return join(headers, "\n") & "\n\n\n"

proc get_sock() : net.Socket =
  let sock = newSocket()
  sock.connect("127.0.0.1", net.Port(8000))
  return sock


proc read(sock : net.Socket, sep : string) : string =
  var ret = ""

  while true:
    var buf = ""
    let bytes_count = sock.recv(buf, C)
    echo buf
    echo bytes_count

    if buf.find(sep) == -1:
      echo "not found"
    else:
      return ret

    ret &= buf

    if bytes_count < C:
      return ret

# proc read_headers


proc main() =
  var sock = get_sock()
  sock.send(get_headers())
  var i = ""
  discard sock.recv(i, 100)
  echo i

echo getContent("http://127.0.0.1:8000/s")# main()

# var
#   buf = ""
#   cnt = 0
# proc printf*(formatstr: cstring) {.
#     header: "<stdio.h>",
#     importc: "printf",
#     varargs
# .}
# var f: File
# try:
#   f = open("omfg2", fmRead, 900)
# except IOError:
#   echo "a'"
# # f.writeln("asdadsasa")
# while true:
#   cnt += 1
#   let c = s.recv(buf, C)
#   printf("%d>>%s", cnt, buf)
#   if c < C:
#     s.close()
#     break
# # e = getCurrentException()
# # msg = getCurrentExceptionMsg()
# # echo(msg)
# # echo(e)
# url = "http://openexchangerates.org/api/latest.json?app_id=cb50ce987deb4652a35ea5ed063f270c"
# echo (parseFloat(commandLineParams()[0]) + parseJson(txt)["rates"]["PLN"].fnum)
# proc log(s:seq[string], o:seq[string]) =
#   echo "============================================================="
#   for x in items(s):
#     echo x
#   echo "Len: " & $len(s)
#   for x in items(o):
#     echo x
#   echo "Len: " & $len(o)
#   echo "============================================================="
