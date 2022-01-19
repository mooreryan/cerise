open! Core

open Cmdliner

let version = "0.1.0"

let queries_term =
  let doc = "Path to query sequences" in
  Arg.(required & pos 0 (some non_dir_file) None & info [] ~docv:"QUERIES" ~doc)

let targets_term =
  let doc = "Path to target sequences" in
  Arg.(required & pos 1 (some non_dir_file) None & info [] ~docv:"TARGETS" ~doc)

let outdir_term =
  let doc = "Out directory" in
  Arg.(
    value & opt string "cerise_out" & info [ "o"; "outdir" ] ~docv:"OUTDIR" ~doc)

let extra_config_term =
  let doc = "Extra config pairs for search program" in
  Arg.(
    value
    & opt (some non_dir_file) None
    & info [ "extra-config" ] ~docv:"EXTRA_CONFIG" ~doc)

let query_clusters_term =
  let doc = "Path to query sequence cluster info" in
  Arg.(
    value
    & opt (some non_dir_file) None
    & info [ "q"; "query-clusters" ] ~docv:"QUERY_CLUSTERS" ~doc)

let target_clusters_term =
  let doc = "Path to target sequence cluster info" in
  Arg.(
    value
    & opt (some non_dir_file) None
    & info [ "t"; "target-clusters" ] ~docv:"TARGET_CLUSTERS" ~doc)

let all_queries_term =
  let doc = "Path to all, non-clustered query sequences" in
  Arg.(
    value
    & opt (some non_dir_file) None
    & info [ "all-queries" ] ~docv:"ALL_QUERIES" ~doc)

let all_targets_term =
  let doc = "Path to all, non-clustered target sequences" in
  Arg.(
    value
    & opt (some non_dir_file) None
    & info [ "all-targets" ] ~docv:"ALL_TARGETS" ~doc)

let basename_term =
  let doc = "Basename for output files" in
  Arg.(
    value & opt string "cerise" & info [ "b"; "basename" ] ~docv:"BASENAME" ~doc)

(* TODO better converter for this *)
let search_program_term =
  let doc = "Program to use for homology search (must be on PATH)" in
  Arg.(
    value & opt string "mmseqs"
    & info [ "s"; "search-program" ] ~docv:"SEARCH_PROGRAM" ~doc)

let force_term =
  let doc = "If the outdir already exists, just keep going." in
  Arg.(value & flag & info [ "f"; "force" ] ~doc)

let evalue_term =
  let doc = "E-Value to consider a hit as significant." in
  Arg.(value & opt float 1e-3 & info [ "e"; "evalue" ] ~docv:"E-VALUE" ~doc)

let term =
  Term.(
    const Opts.make $ queries_term $ targets_term $ query_clusters_term
    $ target_clusters_term $ outdir_term $ force_term $ evalue_term
    $ basename_term $ search_program_term $ extra_config_term $ all_queries_term
    $ all_targets_term)

let info =
  let doc = "CERISE:  ClustEr RestrIcted homology SEarch" in
  let man =
    [
      `S Manpage.s_description;
      `P
        "Cerise is both a deep, reddish-pink color and a pipeline for speeding \
         up homology searches without compromising precision and recall (Nasko \
         et al., 2018; https://doi.org/10.1101/426098).";
      `P
        "Cerise is heavily inspired by Rubble, the original pipeline from the \
         Nasko mansucript.  Rubble program (https://github.com/dnasko/rubble) \
         only allows clustering of the target sequences, and only supports \
         homology searches with BLAST.  Cerise expands on Rubble by allowing \
         clustering of both query and target sequences and supporting multiple \
         homology search tools.";
    ]
  in
  Term.info "cerise" ~version ~doc ~man

let program = (term, info)

let parse_cli () =
  match Term.eval program with
  | `Ok opts ->
      Opts.check opts;
      `Run opts
  | `Help | `Version -> `Exit 0
  | `Error _ -> `Exit 1
