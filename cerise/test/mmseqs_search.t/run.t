CLI errors

  $ cerise
  cerise: required arguments QUERIES, TARGETS are missing
  Usage: cerise [OPTION]... QUERIES TARGETS
  Try `cerise --help' for more information.
  [1]
  $ cerise a
  cerise: required argument TARGETS is missing
  Usage: cerise [OPTION]... QUERIES TARGETS
  Try `cerise --help' for more information.
  [1]
  $ cerise a b
  cerise: QUERIES argument: no `a' file
  Usage: cerise [OPTION]... QUERIES TARGETS
  Try `cerise --help' for more information.
  [1]
  $ cerise queries.fasta b
  cerise: TARGETS argument: no `b' file
  Usage: cerise [OPTION]... QUERIES TARGETS
  Try `cerise --help' for more information.
  [1]
  $ cerise a targets.fasta
  cerise: QUERIES argument: no `a' file
  Usage: cerise [OPTION]... QUERIES TARGETS
  Try `cerise --help' for more information.
  [1]

Missing cluster info

  $ cerise queries.fasta targets.fasta 2> err
  [2]
  $ grep Failure err | sed -E 's/^ +//'
  (Failure "you need to have at least one of query or target clusters")

Missing "all seqs" files.

  $ if [ -d cerise_out ]; then rm -r cerise_out; fi
  $ cerise clustered_queries.fasta clustered_targets.fasta --query-clusters query_clusters.tsv --target-clusters target_clusters.tsv 2> err
  [2]
  $ grep -A1 Failure err | sed -E 's/^ +//'
  (Failure
  "--query-clusters and --all-queries must both be present, or neither should be present")

Queries and targets clustered

  $ if [ -d cerise_out ]; then rm -r cerise_out; fi
  $ cerise clustered_queries.fasta clustered_targets.fasta --query-clusters query_clusters.tsv --target-clusters target_clusters.tsv --all-queries queries.fasta --all-targets targets.fasta --search-config='-s=1 --threads=4' > cerise_oe 2>&1
  $ ls cerise_out
  cerise.first_search.tsv
  cerise.new_queries.fasta
  cerise.new_targets.fasta
  cerise.second_search.tsv
  command_logs.txt
  $ grep '^>' cerise_out/cerise.new_queries.fasta | cut -f1 -d' ' | sort | diff - expected_new_queries__both.txt
  $ grep '^>' cerise_out/cerise.new_targets.fasta | cut -f1 -d' ' | sort | diff - expected_new_targets__both.txt
  $ sort -k1,2 cerise_out/cerise.first_search.tsv | cut -f1,2 | diff - expected_first_search__both.tsv
  $ sort -k1,2 cerise_out/cerise.second_search.tsv | cut -f1,2 | diff - expected_second_search__both.tsv

Queries and targets clustered (verbose)

  $ if [ -d cerise_out ]; then rm -r cerise_out; fi
  $ cerise -vv clustered_queries.fasta clustered_targets.fasta --query-clusters query_clusters.tsv --target-clusters target_clusters.tsv --all-queries queries.fasta --all-targets targets.fasta --search-config='-s=1 --threads=4' > cerise_oe 2>&1
  $ ../helpers/sanitize_logs cerise_oe
  I, [DATE TIME PID] INFO -- Setting up first search
  I, [DATE TIME PID] INFO -- Running first search
  I, [DATE TIME PID] INFO -- Setting up second search
  I, [DATE TIME PID] INFO -- Running second search
  I, [DATE TIME PID] INFO -- The final outfile is cerise_out/cerise.second_search.tsv
  $ ls cerise_out
  cerise.first_search.tsv
  cerise.new_queries.fasta
  cerise.new_targets.fasta
  cerise.second_search.tsv
  command_logs.txt
  $ grep '^>' cerise_out/cerise.new_queries.fasta | cut -f1 -d' ' | sort | diff - expected_new_queries__both.txt
  $ grep '^>' cerise_out/cerise.new_targets.fasta | cut -f1 -d' ' | sort | diff - expected_new_targets__both.txt
  $ sort -k1,2 cerise_out/cerise.first_search.tsv | cut -f1,2 | diff - expected_first_search__both.tsv
  $ sort -k1,2 cerise_out/cerise.second_search.tsv | cut -f1,2 | diff - expected_second_search__both.tsv


Just queries clustered.  Note that the file names are a bit
misleading.  I'm using the clustered files to make checking the output
easier, but I'm treating them as non-clustered...see the options for
clarification.

  $ if [ -d cerise_out ]; then rm -r cerise_out; fi
  $ cerise clustered_queries.fasta clustered_targets.fasta --query-clusters query_clusters.tsv --all-queries queries.fasta --search-config='-s=1 --threads=4' > cerise_oe 2>&1
  $ ls cerise_out
  cerise.first_search.tsv
  cerise.new_queries.fasta
  cerise.second_search.tsv
  command_logs.txt
  $ grep '^>' cerise_out/cerise.new_queries.fasta | cut -f1 -d' ' | sort | diff - expected_new_queries__clustered_queries.txt
  $ sort -k1,2 cerise_out/cerise.first_search.tsv | cut -f1,2 | diff - expected_first_search__clustered_queries.tsv
  $ sort -k1,2 cerise_out/cerise.second_search.tsv | cut -f1,2 | diff - expected_second_search__clustered_queries.tsv

Just targets clustered.  See above for not about file names.

  $ if [ -d cerise_out ]; then rm -r cerise_out; fi
  $ cerise clustered_queries.fasta clustered_targets.fasta --target-clusters target_clusters.tsv --all-targets targets.fasta --search-config='-s=1 --threads=4' > cerise_oe 2>&1
  $ ls cerise_out
  cerise.first_search.tsv
  cerise.new_targets.fasta
  cerise.second_search.tsv
  command_logs.txt
  $ grep '^>' cerise_out/cerise.new_targets.fasta | cut -f1 -d' ' | sort | diff - expected_new_targets__clustered_targets.txt
  $ sort -k1,2 cerise_out/cerise.first_search.tsv | cut -f1,2 | diff - expected_first_search__clustered_targets.tsv
  $ sort -k1,2 cerise_out/cerise.second_search.tsv | cut -f1,2 | diff - expected_second_search__clustered_targets.tsv
