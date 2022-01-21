CLI argument errors

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
  cerise: QUERIES argument: no `queries.fasta' file
  Usage: cerise [OPTION]... QUERIES TARGETS
  Try `cerise --help' for more information.
  [1]
  $ cerise a targets.fasta
  cerise: QUERIES argument: no `a' file
  Usage: cerise [OPTION]... QUERIES TARGETS
  Try `cerise --help' for more information.
  [1]

Bad mmseqs search config

  $ cerise --search-config='--format-mode 1' --search-program=mmseqs queries.fa targets.fa --query-clusters query_clusters.txt --target-clusters target_clusters.txt --all-queries all_queries.fa --all-targets all_targets.fa 2> err
  [2]
  $ grep -A1 Failure err | sed -E 's/^ +//'
  (Failure
  "You are not allowed to include --format-mode or --format-output in the search config for MMseqs2.")
  $ cerise --search-config='--format-output pident' --search-program=mmseqs queries.fa targets.fa --query-clusters query_clusters.txt --target-clusters target_clusters.txt --all-queries all_queries.fa --all-targets all_targets.fa 2> err
  [2]
  $ grep -A1 Failure err | sed -E 's/^ +//'
  (Failure
  "You are not allowed to include --format-mode or --format-output in the search config for MMseqs2.")

Bad blast search config

  $ cerise --search-config='-html' --search-program=blast queries.fa targets.fa --query-clusters query_clusters.txt --target-clusters target_clusters.txt --all-queries all_queries.fa --all-targets all_targets.fa 2> err
  [2]
  $ grep -A1 Failure err | sed -E 's/^ +//'
  (Failure
  "You are not allowed to include -outfmt or -html in the search config for blastp.")
  $ cerise --search-config='-outfmt 7' --search-program=blast queries.fa targets.fa --query-clusters query_clusters.txt --target-clusters target_clusters.txt --all-queries all_queries.fa --all-targets all_targets.fa 2> err
  [2]
  $ grep -A1 Failure err | sed -E 's/^ +//'
  (Failure
  "You are not allowed to include -outfmt or -html in the search config for blastp.")

Bad diamond search config

  $ cerise --search-config='--outfmt 7' --search-program=diamond queries.fa targets.fa --query-clusters query_clusters.txt --target-clusters target_clusters.txt --all-queries all_queries.fa --all-targets all_targets.fa 2> err
  [2]
  $ grep -A1 Failure err | sed -E 's/^ +//'
  (Failure
  "You are not allowed to include --outfmt or --header in the search config for diamond.")
  $ cerise --search-config='--header' --search-program=diamond queries.fa targets.fa --query-clusters query_clusters.txt --target-clusters target_clusters.txt --all-queries all_queries.fa --all-targets all_targets.fa 2> err
  [2]
  $ grep -A1 Failure err | sed -E 's/^ +//'
  (Failure
  "You are not allowed to include --outfmt or --header in the search config for diamond.")

