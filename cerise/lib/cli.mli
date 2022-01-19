open! Core

val parse_cli : unit -> [> `Exit of int | `Run of Opts.t ]
(** Will blow up in a variety of ways if the opts are bad :) *)
