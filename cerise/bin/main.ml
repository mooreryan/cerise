open! Core
open! Cerise_lib

let make_tmpdir () = Filename.temp_dir "cerise" ""
let make_outfile_name opts suffix =
  Filename.concat opts.Opts.outdir opts.basename ^ suffix

let make_outdir opts = Unix.mkdir_p ~perm:0o775 opts.Opts.outdir

let make_runner ~extra_config ~outdir ~outfile ~search_program ~queries ~targets
    ~evalue () : (module Command_runner.Abstract_runner.Instance.S) =
  match search_program with
  | "blast" ->
      Blast.Runner.to_abstract_runner
      @@ Blast.Runner.make ?extra_config
           {
             makeblastdb_exe = "makeblastdb";
             blastp_exe = "blastp";
             queries;
             targets;
             outfile;
             evalue;
           }
  | "mmseqs" ->
      let tmpdir = make_tmpdir () in
      Mmseqs.Runner.to_abstract_runner
      @@ Mmseqs.Runner.make ?extra_config
           { exe = "mmseqs"; queries; targets; outfile; evalue; tmpdir }
  | "diamond" ->
      Diamond.Runner.to_abstract_runner
      @@ Diamond.Runner.make ?extra_config
           { exe = "diamond"; queries; targets; outdir; outfile; evalue }
  | _ -> failwith "search_program must be either mmseqs or blastp"

(* Sligthly confusing function as different things will happen depending on
   whether [new_targets] and [all_targets] are [Some] or [None]. *)
let make_new_search_infile ~orig_seq_file ~new_seq_file ~new_seqs
    ~non_clustered_seq_file =
  match (new_seqs, non_clustered_seq_file) with
  | Some _, None | None, Some _ -> assert false
  | None, None -> orig_seq_file
  | Some new_seqs, Some non_clustered_seq_file ->
      let open Bio_io.Fasta in
      Stdio.Out_channel.with_file new_seq_file ~f:(fun oc ->
          In_channel.with_file_iter_records_exn non_clustered_seq_file
            ~f:(fun record ->
              if Set.mem new_seqs @@ Record.id record then
                Stdio.Out_channel.output_string oc @@ Record.to_string_nl record));
      new_seq_file

let run_first_search ~extra_config ~opts =
  let first_search_outfile = make_outfile_name opts ".first_search.tsv" in
  let first_search_runner =
    make_runner ~extra_config ~outdir:opts.outdir ~outfile:first_search_outfile
      ~search_program:opts.search_program ~queries:opts.queries
      ~targets:opts.targets ~evalue:opts.evalue ()
  in
  Command_runner.Abstract_runner.run first_search_runner;
  first_search_outfile

let run_second_search ~extra_config ~opts ~new_query_infile ~new_target_infile =
  let second_search_outfile = make_outfile_name opts ".second_search.tsv" in
  let second_search_runner =
    make_runner ~extra_config ~outdir:opts.outdir ~outfile:second_search_outfile
      ~search_program:opts.search_program ~queries:new_query_infile
      ~targets:new_target_infile ~evalue:opts.evalue ()
  in
  Command_runner.Abstract_runner.run second_search_runner;
  second_search_outfile

let set_up_second_search ~opts ~first_search_outfile =
  let query_clusters = Clusters.read opts.Opts.query_clusters in
  let target_clusters = Clusters.read opts.target_clusters in
  let new_queries, new_targets =
    Clusters.get_new_search_input_seq_ids ~query_clusters ~target_clusters
      first_search_outfile
  in
  let new_query_infile =
    make_new_search_infile ~orig_seq_file:opts.queries
      ~new_seq_file:(make_outfile_name opts ".new_queries.fasta")
      ~new_seqs:new_queries ~non_clustered_seq_file:opts.all_queries
  in
  let new_target_infile =
    make_new_search_infile ~orig_seq_file:opts.targets
      ~new_seq_file:(make_outfile_name opts ".new_targets.fasta")
      ~new_seqs:new_targets ~non_clustered_seq_file:opts.all_targets
  in
  (new_query_infile, new_target_infile)

let run opts =
  (* Set up *)
  make_outdir opts;
  let extra_config =
    Option.map opts.extra_config ~f:Command_runner.Extra_config.read
  in
  (* First search *)
  let first_search_outfile = run_first_search ~extra_config ~opts in
  (* Set up 2nd search *)
  let new_query_infile, new_target_infile =
    set_up_second_search ~opts ~first_search_outfile
  in
  (* 2nd search *)
  let second_search_outfile =
    run_second_search ~extra_config ~opts ~new_query_infile ~new_target_infile
  in
  prerr_endline [%string "The final outfile is %{second_search_outfile}"]

let main () =
  match Cli.parse_cli () with `Run opts -> run opts | `Exit code -> exit code

let () = main ()
