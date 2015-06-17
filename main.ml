(* -*- mode: tuareg -*- *)
open Unix;;                     (* low-level OS and filesystem related stuff *)
open Printf;;                   (* easy to guess what it is, right? *)

(* like an option type, but also holds some info about what broke (useful for
debugging in this case) *)
type 'a either = Success of 'a | Fail of string;;

(* a simple record to hold directory children along with their count *)
type dset = { files : string list; count : int };;

(* this is safe because of immutability of dset type instances - there's no
way to modify this after its definition. *)
let empty_dset = {files = []; count = 0};;

let dset_add d path = {files = (path :: d.files); count = (succ d.count)};;
let dset_merge d1 d2 = {files = (d1.files @ d2.files);
                        count = (d1.count + d2.count)};;


let is_real_path = function
  | "." |  ".." -> false
  | _           -> true ;;


(* an option is easier to deal with than exceptions *)
let stream_pop stream =
  match Stream.peek stream with
  | Some value -> Stream.junk stream;
                  Some value
  | None       -> None ;;

(* we don't really *need* the stream, we're going to consume it whole anyway.
It's just that a Stream is a convenient abstraction for how open-, read- and
closedir work. *)
let stream_to_list s =
  let rec _loop output =
    match stream_pop s with
    | None -> output
    | Some v -> _loop (v :: output)
  in
  _loop [] ;;


let dirstream dirname =
  try
    let dir = opendir dirname in
    let generator _ =
      try Some (readdir dir)
      with End_of_file -> closedir dir;
                          None (* meaning there's no more elements *)
    in
    Success (Stream.from generator)
  with Unix_error(code, func_name, arg) ->
    Fail (sprintf "Unix_error: %s (arg: %s) in %s"
                  (error_message code) arg func_name) ;;


(*******************************************************************************
                                Actual solution
*******************************************************************************)

let ls path =
  match dirstream path with
  | Fail msg         -> empty_dset
  | Success children ->
     (stream_to_list children)
         |> List.filter is_real_path |> List.map (Filename.concat path)
         |> List.fold_left dset_add empty_dset;;

let descendants root =
  let rec _loop remaining output =
    match remaining with
    | [] -> {output with files=(List.sort String.compare output.files)}
    | current :: tail ->
       let current = ls current in
       _loop (tail @ current.files)
             (dset_merge output current)
  in
  _loop [root] empty_dset;;


let children = descendants (Sys.getcwd ()) in
    children |> (fun x -> x.files) |> List.iter print_endline;
    print_int children.count; print_newline ();;
