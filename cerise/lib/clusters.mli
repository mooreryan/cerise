open! Core

type t
type string_set = Set.M(String).t

val read : string option -> t option

val get_new_search_input_seq_ids :
  query_clusters:t option ->
  target_clusters:t option ->
  string ->
  string_set option * string_set option
(** If both [query_clusters] and [target_clusters] is [None], then this function
    will raise. It will raise in a lot more ways too...for now at least :) So if
    you get a return value of [(None, None)] you should raise in the caller of
    this function as well. *)
