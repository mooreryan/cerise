open! Core

let abort ?(exit_code = 1) msg =
  let () = eprintf "%s\n" msg in
  Caml.exit exit_code

(* See
   https://github.com/ocaml/dune/commit/154272b779fe8943a9ce1b4afabb30150ab94ba6 *)

(* let ( ^/ ) = Filename.concat *)

(* Return list of entries in [path] as [path/entry] *)
let readdir path =
  Array.fold ~init:[]
    ~f:(fun acc entry -> Filename.concat path entry :: acc)
    (Sys.readdir path)

let rec rm_rf name =
  match Unix.lstat name with
  | { st_kind = S_DIR; _ } ->
      List.iter (readdir name) ~f:rm_rf;
      Unix.rmdir name
  | _ -> Unix.unlink name
  | exception Unix.Unix_error (ENOENT, _, _) -> ()
