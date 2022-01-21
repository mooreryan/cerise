open! Base
open! Stdio

(* TODO make a runner that has actual interesting check and clean_up
   behavior. *)

let with_tempfile f =
  let tempfile = Caml.Filename.temp_file "test" "" in
  let finally file = Caml.Sys.remove file in
  Exn.protectx ~f ~finally tempfile

let with_tempfiles f =
  let tempfile1 = Caml.Filename.temp_file "test" "" in
  let tempfile2 = Caml.Filename.temp_file "test" "" in
  let finally (file1, file2) =
    Caml.Sys.remove file1;
    Caml.Sys.remove file2
  in
  Exn.protectx ~f ~finally (tempfile1, tempfile2)

module Printer = struct
  module Command = struct
    type config = unit
    type t = { name : string; args : string list; config : config }

    let make config = { name = "test_files/printer.sh"; args = []; config }

    let check _ = ()
    let clean_up _ = ()
  end

  module Runner = struct
    module T = struct
      include Command
      type t = (module Command_runner.Runner.Instance.S)

      let make ?stdout ?stderr ?extra_config config : t =
        Command_runner.Runner.make ?stdout ?stderr ?extra_config
          (module Command)
          config
    end

    include T

    let to_abstract_runner (runner : T.t) :
        (module Command_runner.Abstract_runner.Instance.S) =
      (module struct
        module Abstract_runner = struct
          type t = T.t
          let run = Command_runner.Runner.run'
        end
        let this = runner
      end : Command_runner.Abstract_runner.Instance.S)
  end
end

module Cr = Command_runner

let run runner =
  print_endline "~first time~";
  Cr.Runner.run' runner;
  print_endline "~second time~";
  Cr.Runner.run' runner

let%expect_test _ =
  let runner = Printer.Runner.make () in
  Cr.Runner.run runner;
  Cr.Runner.check runner;
  Cr.Runner.clean_up runner;
  [%expect
    {|
    hi I'm stdout line 1
    hi I'm stderr line 1
    hi I'm stdout line 2
    hi I'm stderr line 2 |}]

let%expect_test _ =
  let runner = Printer.Runner.make () in
  run runner;
  [%expect
    {|
    ~first time~
    hi I'm stdout line 1
    hi I'm stderr line 1
    hi I'm stdout line 2
    hi I'm stderr line 2
    ~second time~
    hi I'm stdout line 1
    hi I'm stderr line 1
    hi I'm stdout line 2
    hi I'm stderr line 2 |}]

let%expect_test _ =
  with_tempfile (fun tempfile ->
      let runner = Printer.Runner.make ~stdout:(Truncate tempfile) () in
      run runner;
      print_endline "reading stdout";
      print_endline @@ In_channel.read_all tempfile);
  [%expect
    {|
    ~first time~
    hi I'm stderr line 1
    hi I'm stderr line 2
    ~second time~
    hi I'm stderr line 1
    hi I'm stderr line 2
    reading stdout
    hi I'm stdout line 1
    hi I'm stdout line 2 |}]

let%expect_test _ =
  with_tempfile (fun tempfile ->
      let runner = Printer.Runner.make ~stderr:(Truncate tempfile) () in
      run runner;
      print_endline "reading stderr";
      print_endline @@ In_channel.read_all tempfile);
  [%expect
    {|
    ~first time~
    hi I'm stdout line 1
    hi I'm stdout line 2
    ~second time~
    hi I'm stdout line 1
    hi I'm stdout line 2
    reading stderr
    hi I'm stderr line 1
    hi I'm stderr line 2 |}]

let%expect_test _ =
  with_tempfile (fun tempfile ->
      let runner = Printer.Runner.make ~stdout:(Append tempfile) () in
      run runner;
      print_endline "reading stdout";
      print_endline @@ In_channel.read_all tempfile);
  [%expect
    {|
    ~first time~
    hi I'm stderr line 1
    hi I'm stderr line 2
    ~second time~
    hi I'm stderr line 1
    hi I'm stderr line 2
    reading stdout
    hi I'm stdout line 1
    hi I'm stdout line 2
    hi I'm stdout line 1
    hi I'm stdout line 2 |}]

let%expect_test _ =
  with_tempfile (fun tempfile ->
      let runner = Printer.Runner.make ~stderr:(Append tempfile) () in
      run runner;
      print_endline "reading stderr";
      print_endline @@ In_channel.read_all tempfile);
  [%expect
    {|
    ~first time~
    hi I'm stdout line 1
    hi I'm stdout line 2
    ~second time~
    hi I'm stdout line 1
    hi I'm stdout line 2
    reading stderr
    hi I'm stderr line 1
    hi I'm stderr line 2
    hi I'm stderr line 1
    hi I'm stderr line 2 |}]

let%expect_test _ =
  with_tempfiles (fun (so, se) ->
      let runner =
        Printer.Runner.make ~stdout:(Append so) ~stderr:(Append se) ()
      in
      run runner;
      print_endline "reading stdout";
      print_endline @@ In_channel.read_all so;
      print_endline "reading stderr";
      print_endline @@ In_channel.read_all se);
  [%expect
    {|
    ~first time~
    ~second time~
    reading stdout
    hi I'm stdout line 1
    hi I'm stdout line 2
    hi I'm stdout line 1
    hi I'm stdout line 2

    reading stderr
    hi I'm stderr line 1
    hi I'm stderr line 2
    hi I'm stderr line 1
    hi I'm stderr line 2 |}]

let%expect_test _ =
  with_tempfiles (fun (so, se) ->
      let runner =
        Printer.Runner.make ~stdout:(Append so) ~stderr:(Truncate se) ()
      in
      run runner;
      print_endline "reading stdout";
      print_endline @@ In_channel.read_all so;
      print_endline "reading stderr";
      print_endline @@ In_channel.read_all se);
  [%expect
    {|
    ~first time~
    ~second time~
    reading stdout
    hi I'm stdout line 1
    hi I'm stdout line 2
    hi I'm stdout line 1
    hi I'm stdout line 2

    reading stderr
    hi I'm stderr line 1
    hi I'm stderr line 2 |}]

let%expect_test _ =
  with_tempfiles (fun (so, se) ->
      let runner =
        Printer.Runner.make ~stdout:(Truncate so) ~stderr:(Append se) ()
      in
      run runner;
      print_endline "reading stdout";
      print_endline @@ In_channel.read_all so;
      print_endline "reading stderr";
      print_endline @@ In_channel.read_all se);
  [%expect
    {|
    ~first time~
    ~second time~
    reading stdout
    hi I'm stdout line 1
    hi I'm stdout line 2

    reading stderr
    hi I'm stderr line 1
    hi I'm stderr line 2
    hi I'm stderr line 1
    hi I'm stderr line 2 |}]

let%expect_test _ =
  with_tempfiles (fun (so, se) ->
      let runner =
        Printer.Runner.make ~stdout:(Truncate so) ~stderr:(Truncate se) ()
      in
      run runner;
      print_endline "reading stdout";
      print_endline @@ In_channel.read_all so;
      print_endline "reading stderr";
      print_endline @@ In_channel.read_all se);
  [%expect
    {|
    ~first time~
    ~second time~
    reading stdout
    hi I'm stdout line 1
    hi I'm stdout line 2

    reading stderr
    hi I'm stderr line 1
    hi I'm stderr line 2 |}]

let%expect_test "truncate both, same file" =
  with_tempfile (fun tf ->
      let runner =
        Printer.Runner.make ~stdout:(Truncate tf) ~stderr:(Truncate tf) ()
      in
      run runner;
      print_endline "reading outfile";
      print_endline @@ In_channel.read_all tf);
  [%expect
    {|
    ~first time~
    ~second time~
    reading outfile
    hi I'm stdout line 1
    hi I'm stderr line 1
    hi I'm stdout line 2
    hi I'm stderr line 2 |}]

let%expect_test "truncate stdout, append stderr, same file" =
  print_s
  @@ Or_error.sexp_of_t Unit.sexp_of_t
  @@ Or_error.try_with (fun () ->
         with_tempfile (fun tf ->
             let runner =
               Printer.Runner.make ~stdout:(Truncate tf) ~stderr:(Append tf) ()
             in
             run runner;
             print_endline "reading outfile";
             print_endline @@ In_channel.read_all tf));
  [%expect
    {|
    ~first time~
    (Error
     (Failure
      "stdout and stderr were the same file, but out was truncate and err was append")) |}]

let%expect_test "append stdout, truncate stderr, same file" =
  print_s
  @@ Or_error.sexp_of_t Unit.sexp_of_t
  @@ Or_error.try_with (fun () ->
         with_tempfile (fun tf ->
             let runner =
               Printer.Runner.make ~stdout:(Append tf) ~stderr:(Truncate tf) ()
             in
             run runner;
             print_endline "reading outfile";
             print_endline @@ In_channel.read_all tf));
  [%expect
    {|
    ~first time~
    (Error
     (Failure
      "stdout and stderr were the same file, but out was append and err was truncate")) |}]
