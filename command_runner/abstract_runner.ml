open! Base

(** Sometimes you need something more abstract than a single runner. E.g., if
    your "command" is actually multiple CLI programs. E.g, makeblastdb followed
    by blastp. Then you will need a more generalized interface than that
    provider by [Runner]. *)

module type S = sig
  type t

  val run : t -> unit
end

module Instance = struct
  module type S = sig
    module Abstract_runner : S
    val this : Abstract_runner.t
  end
end

let run (module M : Instance.S) = M.Abstract_runner.run M.this
