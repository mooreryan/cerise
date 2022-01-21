open! Base

let of_string s =
  String.split_on_chars ~on:[ '='; ' ' ] s
  |> List.filter ~f:(Fn.non String.is_empty)
