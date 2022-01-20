open! Core

module Command = struct
  type config = {
    exe : string;
    queries : string;
    targets : string;
    outfile : string;
    tmpdir : string;
  }

  type t = { name : string; args : string list; config : config }

  let make ({ exe; queries; targets; outfile; tmpdir } as config) =
    let args = [ "easy-search"; queries; targets; outfile; tmpdir ] in
    { name = exe; args; config }

  let check { config; _ } =
    if not (Sys.file_exists_exn ~follow_symlinks:true config.outfile) then
      failwith [%string "outfile '%{config.outfile}' does not exist"]

  let clean_up { config; _ } =
    if Sys.file_exists_exn ~follow_symlinks:true config.tmpdir then
      Utils.rm_rf config.tmpdir
end

module Runner = struct
  module T = struct
    include Command

    type t = (module Command_runner.Runner.Instance.S)

    let make ?extra_config config : t =
      Command_runner.Runner.make ?extra_config (module Command) config
  end

  include T

  let to_abstract_runner (runner : T.t) :
      (module Command_runner.Abstract_runner.Instance.S) =
    (module struct
      module Abstract_runner = struct
        type t = T.t
        let run = Command_runner.Runner.run'
      end
      let this = runner
    end : Command_runner.Abstract_runner.Instance.S)
end
