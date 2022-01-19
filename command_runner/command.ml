module type S = sig
  type config

  type t = { name : string; args : string list; config : config }
  (** Need the [config] here to be able to check the output. *)

  val make : config -> t

  (* TODO maybe combine these into one called finalize? *)

  val check : t -> unit
  val clean_up : t -> unit
end
