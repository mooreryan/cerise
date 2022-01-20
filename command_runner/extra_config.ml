open! Base

let read fname =
  Stdio.In_channel.read_lines fname
  |> List.map ~f:(fun line ->
         match String.split ~on:'=' line with
         | [ option; value ] -> [ option; value ]
         | _ -> failwith ("bad line in config file " ^ line))
  |> List.concat

let of_string s =
  s |> String.split ~on:' '
  |> List.map ~f:(fun opt ->
         match String.split ~on:'=' opt with
         | [ option; value ] -> [ option; value ]
         | _ -> failwith ("bad config: " ^ opt))
  |> List.concat
