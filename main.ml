(* mode: tuareg-mode *)
open Unix;;                     (* filesystem-related stuff *)

(* helpers - they probably should be in stdlib.. *)
type 'a option = None | Some of 'a;;
let (|>) a b = b a;;

let root_path = "/home/cji/poligon/comp/";;

let shouldBeVisible fname = not (fname = "." || fname = "..") ;;

let ls path : string list option =
  try
    let d = opendir path in
    let rec gather_files acc =
      try
        let newfname = (readdir d) in
        gather_files (
            if shouldBeVisible newfname then
              (Filename.concat path newfname) :: acc
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

let unwrapDirContents (x : string list option) =
  match x with Some y -> y | None -> []
;;


let descendants path =
  let rec _loop to_check results =
    match to_check with
    | [] -> results
    | h :: t  ->
       _loop
         (t @ (ls h |> unwrapDirContents))
         (h :: results)
  in
  _loop [path] []
;;

(******************************************************************************)

(descendants root_path)
  |> List.sort String.compare
  |> List.iter print_endline;;
