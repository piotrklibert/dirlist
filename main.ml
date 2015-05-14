(* mode: tuareg-mode *)
open Unix;;                     (* os and filesystem related stuff *)

(* type 'a option = None | Some of 'a;; *)
let unwrapToList (x : 'a list option) = match x with Some y -> y
                                                   | None   -> [];;
let (|>) a b = b a;;
let (//) = Filename.concat


let dirstream dirname  =
  let dir = opendir(dirname) in
  let f _ =
    try
      Some (readdir dir)
    with End_of_file ->
      closedir(dir);
      None
  in
  Stream.from f
;;


let ls path : string list option =
  let res = ref [] in
  let get_one_file f = match f with
    | "." | ".." -> ()
    | a          -> res := (path // a :: !res)
  in
  try
    dirstream path |> Stream.iter get_one_file;
    Some (List.rev !res)
  with
    Unix_error(_,_,_) -> None
;;



let descendants path =
  let rec
      _loop to_check results = match to_check with
    | [] -> results
    | h :: t  ->
       _loop
         (t @ (ls h |> unwrapToList))
         (h :: results)
  in
  _loop [path] []
;;


(Sys.getcwd() |> descendants)
  |> List.sort String.compare
  |> List.iter print_endline;;


(*



let is_realpath fname = not (fname = "." || fname = "..") ;;

let old_ls path : string list option =
  try
    let d = opendir path in
    let rec gather_files acc =
      try
        let newfname = (readdir d) in
        gather_files (
            if is_realpath newfname then
              (path // newfname) :: acc
            else
              acc
          )
      with
        End_of_file -> closedir(d); acc
    in
    Some (gather_files [])
  with
    Unix_error(_,_,_) -> None
;;


*)
