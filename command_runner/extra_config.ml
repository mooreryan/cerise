open! Base

let read fname =
  Stdio.In_channel.read_lines fname
  |> List.map ~f:(fun line ->
         match String.split_on_chars ~on:[ '='; ' ' ] line with
         | [ option; value ] -> [ option; value ]
         | _ -> failwith ("bad line in config file " ^ line))
  |> List.concat
  |> List.filter ~f:(Fn.non String.is_empty)

let of_string s =
  String.split_on_chars ~on:[ '='; ' ' ] s
  |> List.filter ~f:(Fn.non String.is_empty)
