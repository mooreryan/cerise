open! Core

open Cmdliner

module Verbosity = struct
  open Little_logger

  let log_level_term ?docs () =
    let verbosity_term =
      let doc =
        "Increase verbosity. Repeatable, but more than twice does not bring \
         more."
      in
      Arg.(value & flag_all & info [ "v" ] ~doc ?docs)
    in
    let quiet_term =
      let doc = "Silence all log messages. Takes over verbosity ($(b,-v))." in
      Arg.(value & flag & info [ "quiet" ] ~doc ?docs)
    in
    let choose quiet verbosity =
      if quiet then Logger.Level.Silent
      else
        match List.length verbosity with
        | 0 -> Logger.Level.Warning
        | 1 -> Logger.Level.Info
        | _ -> Logger.Level.Debug
    in
    Term.(const choose $ quiet_term $ verbosity_term)

  (* Adapted from the logs package. Original copyright:

     Copyright (c) 2015 The logs programmers. All rights reserved. Distributed
     under the ISC license, see terms at the end of the file.

     Permission to use, copy, modify, and/or distribute this software for any
     purpose with or without fee is hereby granted, provided that the above
     copyright notice and this permission notice appear in all copies.

     THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
     WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
     MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY
     SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
     WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
     ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR
     IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE. *)
end

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
    & info [ "query-clusters" ] ~docv:"QUERY_CLUSTERS" ~doc)

let target_clusters_term =
  let doc = "Path to target sequence cluster info" in
  Arg.(
    value
    & opt (some non_dir_file) None
    & info [ "target-clusters" ] ~docv:"TARGET_CLUSTERS" ~doc)

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

let term =
  Term.(
    const Opts.make $ queries_term $ targets_term $ query_clusters_term
    $ target_clusters_term $ outdir_term $ force_term $ basename_term
    $ search_program_term $ extra_config_term $ all_queries_term
    $ all_targets_term
    $ Verbosity.log_level_term ())

let info =
  let doc = "CERISE: ClustEr RestrIcted homology SEarch" in
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
