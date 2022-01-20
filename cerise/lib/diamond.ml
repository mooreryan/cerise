open! Core

module Blastp_command = struct
  type config = {
    exe : string;
    queries : string;
    targets : string;
    outfile : string;
    evalue : float;
  }

  type t = { name : string; args : string list; config : config }

  let make ({ exe; queries; targets; outfile; evalue } as config) =
    {
      name = exe;
      args =
        [
          "blastp";
          "-q";
          queries;
          "-d";
          targets;
          "-o";
          outfile;
          "-e";
          Float.to_string evalue;
        ];
      config;
    }

  let check { config; _ } =
    if not (Sys.file_exists_exn ~follow_symlinks:true config.outfile) then
      failwith [%string "outfile '%{config.outfile}' does not exist"]

  let clean_up _ = ()
end

module Makedb_command = struct
  type config = { exe : string; infile : string; out_basename : string }

  type t = { name : string; args : string list; config : config }

  let make ({ exe; infile; out_basename } as config) =
    {
      name = exe;
      args = [ "makedb"; "--in"; infile; "--db"; out_basename ];
      config;
    }

  let clean_up _ = ()

  (** TODO somehow check the blast db output. *)
  let check _ = ()
end

module Runner = struct
  module T = struct
    type config = {
      exe : string;
      queries : string;
      targets : string;
      outdir : string;
      outfile : string;
      evalue : float;
    }

    type t = {
      makedb_runner : (module Command_runner.Runner.Instance.S);
      blastp_runner : (module Command_runner.Runner.Instance.S);
    }

    let make_makedb_runner config =
      Command_runner.Runner.make (module Makedb_command) config

    let make_blastp_runner config ~extra_config =
      Command_runner.Runner.make ?extra_config (module Blastp_command) config

    let make ?extra_config { exe; queries; targets; outdir; outfile; evalue } =
      let blastdb_out_base = Filename.temp_file ~in_dir:outdir "db" "" in
      (* let blastdb_out_file = blastdb_out_base ^ ".dmnd" in *)
      let makedb_cmd_config =
        {
          exe;
          Makedb_command.infile = targets;
          out_basename = blastdb_out_base;
        }
      in
      let blastp_cmd_config : Blastp_command.config =
        { exe; queries; targets = blastdb_out_base; outfile; evalue }
      in
      {
        makedb_runner = make_makedb_runner makedb_cmd_config;
        blastp_runner = make_blastp_runner ~extra_config blastp_cmd_config;
      }

    let run' t =
      Command_runner.Runner.run' t.makedb_runner;
      Command_runner.Runner.run' t.blastp_runner
  end

  include T

  let to_abstract_runner (t : T.t) :
      (module Command_runner.Abstract_runner.Instance.S) =
    (module struct
      module Abstract_runner = struct
        type t = T.t
        let run = T.run'
      end
      let this = t
    end : Command_runner.Abstract_runner.Instance.S)
end
