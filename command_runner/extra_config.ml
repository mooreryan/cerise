open! Base

let read fname =
  Stdio.In_channel.read_lines fname
  |> List.map ~f:(fun line ->
         match String.split ~on:'=' line with
         | [ option; value ] -> [ option; value ]
         | _ -> failwith ("bad line in config file " ^ line))
  |> List.concat
