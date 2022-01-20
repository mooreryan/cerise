open! Base

module type S = sig
  include Command.S
  val run : t -> unit
  val run' : t -> unit
end

module Instance = struct
  module type S = sig
    module Runner : S
    val this : Runner.t
  end
end

type redirect = Append of string | Truncate of string

(** Certain combinations of [stdout] and [stderr] will cause a runtime error. If
    you're redirecting stdout and stderr to the same file, but you have one
    being [Truncate] and the other being [Append], then you will get a runtime
    exception. *)
let handle_redirects ?stdout ?stderr () =
  let module Sp = Shexp_process in
  match (stdout, stderr) with
  | None, None -> Fn.id
  | Some (Append out), None -> Sp.stdout_to ~append:() out
  | Some (Truncate out), None -> Sp.stdout_to out
  | None, Some (Append err) -> Sp.stderr_to ~append:() err
  | None, Some (Truncate err) -> Sp.stderr_to err
  | Some (Truncate out), Some (Truncate err) ->
      if String.(out = err) then fun process -> Sp.outputs_to out process
      else fun process -> Sp.stdout_to out @@ Sp.stderr_to err process
  | Some (Append out), Some (Append err) ->
      (* For both appending, pretty sure they're equivalent, but leave both for
         consistency. *)
      if String.(out = err) then fun process ->
        Sp.outputs_to out ~append:() process
      else fun process ->
        Sp.stdout_to ~append:() out @@ Sp.stderr_to ~append:() err process
  | Some (Append out), Some (Truncate err) ->
      if String.(out = err) then
        failwith
          "stdout and stderr were the same file, but out was append and err \
           was truncate"
      else fun process ->
        Sp.stdout_to ~append:() out @@ Sp.stderr_to err process
  | Some (Truncate out), Some (Append err) ->
      if String.(out = err) then
        failwith
          "stdout and stderr were the same file, but out was truncate and err \
           was append"
      else fun process ->
        Sp.stdout_to out @@ Sp.stderr_to ~append:() err process

let make (type config) ?stdout ?stderr ?extra_config
    (module Cmd : Command.S with type config = config) config :
    (module Instance.S) =
  (module struct
    module Runner = struct
      include Cmd

      let run t =
        Shexp_process.eval
        @@ handle_redirects ?stdout ?stderr ()
        @@ Shexp_process.run t.name t.args

      let run' t =
        run t;
        check t;
        clean_up t
    end

    let this =
      let runner = Runner.make config in
      match extra_config with
      | None -> runner
      | Some extra -> { runner with args = List.append runner.args extra }
  end : Instance.S)

let run (module M : Instance.S) = M.Runner.run M.this
let run' (module M : Instance.S) = M.Runner.run' M.this
let check (module M : Instance.S) = M.Runner.check M.this
let clean_up (module M : Instance.S) = M.Runner.clean_up M.this
