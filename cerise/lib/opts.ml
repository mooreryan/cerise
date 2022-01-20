open! Core

type t = {
  queries : string;
  targets : string;
  query_clusters : string option;
  target_clusters : string option;
  outdir : string;
  basename : string;
  force : bool;
  search_program : string;
  extra_config : string option;
  all_queries : string option;
  all_targets : string option;
  verbosity : Little_logger.Logger.Level.t;
}

let make queries targets query_clusters target_clusters outdir force basename
    search_program extra_config all_queries all_targets verbosity =
  {
    queries;
    targets;
    query_clusters;
    target_clusters;
    outdir;
    force;
    basename;
    search_program;
    extra_config;
    all_queries;
    all_targets;
    verbosity;
  }

(* There are some things that are kind of annoying to check with cmdliner, so
   check any other imprtant stuff about the opts here for now. Eventually, I
   will move these into the arg parsing. *)
let check opts =
  let check_outdir opts =
    if (not opts.force) && Sys.file_exists_exn ~follow_symlinks:true opts.outdir
    then failwith "outdir exists but --force was not passed in"
  in
  let check_cluster_inputs opts =
    match (opts.query_clusters, opts.target_clusters) with
    | None, None ->
        failwith "you need to have at least one of query or target clusters"
    | Some _, None | None, Some _ | Some _, Some _ -> ()
  in
  let check_queries opts =
    match (opts.query_clusters, opts.all_queries) with
    | Some _, None | None, Some _ ->
        failwith
          "--query-clusters and --all-queries must both be present, or neither \
           should be present"
    | Some _, Some _ | None, None -> ()
  in
  let check_targets opts =
    match (opts.target_clusters, opts.all_targets) with
    | Some _, None | None, Some _ ->
        failwith
          "--target-clusters and --all-targets must both be present, or \
           neither should be present"
    | Some _, Some _ | None, None -> ()
  in
  let check_search_program opts =
    match opts.search_program with
    | "blast" | "mmseqs" | "diamond" -> ()
    | _ -> failwith "--search-program must be one of blast, mmseqs, or diamond"
  in
  check_cluster_inputs opts;
  check_outdir opts;
  check_queries opts;
  check_targets opts;
  check_search_program opts;
  ()
