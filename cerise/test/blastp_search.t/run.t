Queries and targets clustered (blastp)

  $ if [ -d cerise_out ]; then rm -r cerise_out; fi
  $ cerise --search-program=blastp clustered_queries.fasta clustered_targets.fasta --query-clusters query_clusters.tsv --target-clusters target_clusters.tsv --all-queries queries.fasta --all-targets targets.fasta --extra-config extra_config.txt > cerise_oe 2>&1
  $ ls cerise_out
  cerise.first_search.tsv
  cerise.new_queries.fasta
  cerise.new_targets.fasta
  cerise.new_targets.fasta.bdb.pdb
  cerise.new_targets.fasta.bdb.phr
  cerise.new_targets.fasta.bdb.pin
  cerise.new_targets.fasta.bdb.pot
  cerise.new_targets.fasta.bdb.psq
  cerise.new_targets.fasta.bdb.ptf
  cerise.new_targets.fasta.bdb.pto
  cerise.second_search.tsv
  $ grep '^>' cerise_out/cerise.new_queries.fasta | cut -f1 -d' ' | sort | diff - expected_new_queries__both.txt
  $ grep '^>' cerise_out/cerise.new_targets.fasta | cut -f1 -d' ' | sort | diff - expected_new_targets__both.txt
  $ sort -k1,2 cerise_out/cerise.first_search.tsv | cut -f1,2 | diff - expected_first_search__both.tsv
  $ sort -k1,2 cerise_out/cerise.second_search.tsv | cut -f1,2 | diff - expected_second_search__both.tsv

Just queries clustered (blastp)

  $ if [ -d cerise_out ]; then rm -r cerise_out; fi
  $ cerise --search-program=blastp  clustered_queries.fasta clustered_targets.fasta --query-clusters query_clusters.tsv --all-queries queries.fasta --extra-config extra_config.txt > cerise_oe 2>&1
  $ ls cerise_out
  cerise.first_search.tsv
  cerise.new_queries.fasta
  cerise.second_search.tsv
  $ grep '^>' cerise_out/cerise.new_queries.fasta | cut -f1 -d' ' | sort | diff - expected_new_queries__clustered_queries.txt
  $ sort -k1,2 cerise_out/cerise.first_search.tsv | cut -f1,2 | diff - expected_first_search__clustered_queries.tsv
  $ sort -k1,2 cerise_out/cerise.second_search.tsv | cut -f1,2 | diff - expected_second_search__clustered_queries.tsv

Just targets clustered (blastp)

  $ if [ -d cerise_out ]; then rm -r cerise_out; fi
  $ cerise --search-program=blastp  clustered_queries.fasta clustered_targets.fasta --target-clusters target_clusters.tsv --all-targets targets.fasta --extra-config extra_config.txt > cerise_oe 2>&1
  $ ls cerise_out
  cerise.first_search.tsv
  cerise.new_targets.fasta
  cerise.new_targets.fasta.bdb.pdb
  cerise.new_targets.fasta.bdb.phr
  cerise.new_targets.fasta.bdb.pin
  cerise.new_targets.fasta.bdb.pot
  cerise.new_targets.fasta.bdb.psq
  cerise.new_targets.fasta.bdb.ptf
  cerise.new_targets.fasta.bdb.pto
  cerise.second_search.tsv
  $ grep '^>' cerise_out/cerise.new_targets.fasta | cut -f1 -d' ' | sort | diff - expected_new_targets__clustered_targets.txt
  $ sort -k1,2 cerise_out/cerise.first_search.tsv | cut -f1,2 | diff - expected_first_search__clustered_targets.tsv
  $ sort -k1,2 cerise_out/cerise.second_search.tsv | cut -f1,2 | diff - expected_second_search__clustered_targets.tsv
