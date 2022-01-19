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
          "-query";
          queries;
          "-db";
          targets;
          "-out";
          outfile;
          "-outfmt";
          "6";
          "-evalue";
          Float.to_string evalue;
        ];
      config;
    }

  let check { config; _ } =
    if not (Sys.file_exists_exn ~follow_symlinks:true config.outfile) then
      failwith [%string "outfile '%{config.outfile}' does not exist"]

  let clean_up _ = ()
end

module Makeblastdb_command = struct
  type config = { exe : string; infile : string; out_basename : string }

  type t = { name : string; args : string list; config : config }

  let make ({ exe; infile; out_basename } as config) =
    {
      name = exe;
      args = [ "-dbtype"; "prot"; "-in"; infile; "-out"; out_basename ];
      config;
    }

  let clean_up _ = ()

  (** TODO somehow check the blast db output. *)
  let check _ = ()
end

module Runner = struct
  module T = struct
    type config = {
      makeblastdb_exe : string;
      blastp_exe : string;
      queries : string;
      targets : string;
      outfile : string;
      evalue : float;
    }

    type t = {
      makeblastdb_runner : (module Command_runner.Runner.Instance.S);
      blastp_runner : (module Command_runner.Runner.Instance.S);
    }

    let make_makeblastdb_runner config =
      Command_runner.Runner.make (module Makeblastdb_command) config

    let make_blastp_runner config ~extra_config =
      Command_runner.Runner.make ?extra_config (module Blastp_command) config

    let make ?extra_config
        { makeblastdb_exe; blastp_exe; queries; targets; outfile; evalue } =
      let blastdb_out_basename = targets ^ ".bdb" in
      let makeblastdb_cmd_config =
        {
          Makeblastdb_command.exe = makeblastdb_exe;
          infile = targets;
          out_basename = blastdb_out_basename;
        }
      in
      let blastp_cmd_config =
        {
          Blastp_command.exe = blastp_exe;
          queries;
          targets = blastdb_out_basename;
          outfile;
          evalue;
        }
      in
      {
        makeblastdb_runner = make_makeblastdb_runner makeblastdb_cmd_config;
        blastp_runner = make_blastp_runner ~extra_config blastp_cmd_config;
      }

    let run' t =
      Command_runner.Runner.run' t.makeblastdb_runner;
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
