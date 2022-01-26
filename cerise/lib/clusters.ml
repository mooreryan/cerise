open! Core

type t =
  ( string,
    (string, String.comparator_witness) Set.t,
    String.comparator_witness )
  Map.t

type string_set = Set.M(String).t

let read fname : t option =
  Option.map fname ~f:(fun fname ->
      In_channel.with_file fname ~f:(fun ic ->
          In_channel.fold_lines ic
            ~init:(Map.empty (module String))
            ~f:(fun m line ->
              match String.split ~on:'\t' line with
              | [ rep; member ] ->
                  Map.update m rep ~f:(function
                    | None -> Set.of_list (module String) [ rep; member ]
                    | Some members -> Set.add members member)
              | _ -> failwith [%string "bad line in clusters file '%{line}'"])))

(* For now just get any hits in the file. Eventually, we probably want to give
   user option to select by evalue or percent identity or whatever. *)
let maybe_keep_cluster_members ~centroid ~clusters ~keep =
  match (clusters, keep) with
  | Some clusters, Some keep -> (
      match Map.find clusters centroid with
      | None ->
          (* TODO better message for if this was a query cluster or a target
             cluster. *)
          failwith
            [%string
              "centroid %{centroid} was in the btab but not found in a cluster \
               file"]
      | Some members ->
          (* Cluster members should already include the query, so we don't need
             to add it here again. *)
          Some (Set.union keep members))
  | Some _, None | None, Some _ -> assert false
  | None, None -> None

(* After the first homology search, run this to figure out which seqs to use in
   the next round. *)
let get_new_search_input_seq_ids ~query_clusters ~target_clusters btab_fname =
  let clusters =
    match (query_clusters, target_clusters) with
    | None, None ->
        failwith "you should provide either query or target clusters"
    | Some _, None -> (Some (Set.empty (module String)), None)
    | None, Some _ -> (None, Some (Set.empty (module String)))
    | Some _, Some _ ->
        (Some (Set.empty (module String)), Some (Set.empty (module String)))
  in
  let count, clusters =
    In_channel.with_file btab_fname ~f:(fun ic ->
        In_channel.fold_lines ic ~init:(0, clusters)
          ~f:(fun (i, (keep_queries, keep_targets)) line ->
            match String.split ~on:'\t' line with
            | query :: target :: _rest ->
                ( i + 1,
                  ( maybe_keep_cluster_members ~centroid:query
                      ~clusters:query_clusters ~keep:keep_queries,
                    maybe_keep_cluster_members ~centroid:target
                      ~clusters:target_clusters ~keep:keep_targets ) )
            | _ -> failwith "bad btab file"))
  in
  if count > 0 then clusters
  else Utils.abort "ERROR: there were no hits of your queries to your targets"
