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

let make (type config) ?extra_config
    (module Cmd : Command.S with type config = config) config :
    (module Instance.S) =
  (module struct
    module Runner = struct
      include Cmd

      let run t = Shexp_process.eval @@ Shexp_process.run t.name t.args

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
