# Cerise

[![Build and Test](https://github.com/mooreryan/cerise/actions/workflows/build_and_test.yml/badge.svg?branch=main)](https://github.com/mooreryan/cerise/actions/workflows/build_and_test.yml)

[![code on GitHub](https://img.shields.io/badge/code-GitHub-blue)](https://github.com/mooreryan/cerise) [![GitHub issues](https://img.shields.io/github/issues/mooreryan/cerise)](https://github.com/mooreryan/cerise/issues) [![Coverage Status](https://coveralls.io/repos/github/mooreryan/cerise/badge.svg?branch=main)](https://coveralls.io/github/mooreryan/cerise?branch=main)

Cerise is both a deep, reddish-pink color and a pipeline for speeding up homology searches without compromising precision and recall ([Nasko et al., 2018](https://doi.org/10.1101/426098)).

Cerise is heavily inspired by [Rubble](https://github.com/dnasko/rubble), the original pipeline from the Nasko mansucript.  The Rubble pipeline only allows clustering of the target sequences, and only supports homology searches with BLAST.  Cerise expands on Rubble by allowing clustering of both query and target sequences and supporting multiple homology search tools.

## Installation

### 3rd party dependencies

You need to have one of following homology search tools installed and available on your `PATH`.

* NCBI BLAST
* Mmseqs2
* Diamond

### Download a pre-compiled binary (easy)

Next, download the lastest [release](https://github.com/mooreryan/pasv/releases/latest) of `cerise`.  I provide precompiled binaries for Linux (Ubuntu-like OSes) and MacOS.  If you don't have one of those, you have to install from source.

### Installing from source (less easy)

If you want to compile Cerise from source, you need to have a working OCaml development setup.  Additionally, you will need to install [GNU Make](https://www.gnu.org/software/make/).

*Note: I won't be able to help you with Windows installation at this time :( At some point in the future, I will likely provide a Docker image for this purpose.*

#### Set up OCaml development environment

Instructions to set up an OCaml development environment can be found [here](https://ocaml.org/learn/tutorials/up_and_running.html) or [here](https://dev.realworldocaml.org/install.html).

#### Get the code

Use git to clone the git repository.

```
$ git clone https://github.com/mooreryan/cerise.git
```

or download a release from [here](https://github.com/mooreryan/pasv/releases).

#### Install OCaml dependencies

(I'm assuming you already set up `opam` properly and have a working switch.  See above for setting up an OCaml dev environment.

```
cd cerise
opam install . --deps-only --with-doc --with-test
```

#### Build, install, & run tests

```
make test && make build_release && make install
```

#### Sanity check

If all went well, this should give you the path to the `cerise` executable file.

```
which cerise
```

## Usage

For background and motivation see the [Rubble manuscript](https://doi.org/10.1101/426098).

### Clustering

Rubble let you search query sequences against a clustered DB.  Cerise allows you to search queries against clustered targets, clustered queries against targets, and clustered queries against clustered targets.

Prior to you search, you will need to cluster your query sequences, target sequences, or both, depending on how you want to run the search.

For this, I generally use `mmseqs easy-cluster`.  You can use anything, but your favorite clustering program needs to be able to output a TSV with clustering info.  The format should be two columns: cluster representative, cluster member.

### Searching

Once you have at least one of queries or targets clustered, you may run a search.

Here is an example in which we have clustered both the queries and the targets.

```
$ cerise \
    clustered_queries.fasta \
    clustered_targets.fasta \
    --query-clusters=query_clusters.tsv \
    --target-clusters=target_clusters.tsv \
    --all-queries=queries.fasta \
    --all-targets=targets.fasta \
    --search-config='--threads 4 -s 7 --num-iterations 3' \
    --search-program=mmseqs
```

A couple of things to note here:

* `--all-queries` and `--all-targets` refer to the original, non-clustered files
* `--query-clusters` and `--target-clusters` refer to the TSV files describing the clusters
* `clustered_queries.fasta` and `clustered_targets.fasta` are the cluster representative sequences
* `--search-config` lets you pass in command line options to the search program
* `--search-program` lets you select which homology search program to use.  Note that it must be on your `PATH` (e.g., `which mmseqs` will work).

For more info on command line usage, see the help screen by running `cerise --help`.

## Citation

If you use Cerise, please cite the Rubble [preprint](https://doi.org/10.1101/426098).  Thank you!!

## License

[![license MIT or Apache
2.0](https://img.shields.io/badge/license-MIT%20or%20Apache%202.0-blue)](https://github.com/mooreryan/pasv)

Copyright (c) 2021 Ryan M. Moore.

Licensed under the Apache License, Version 2.0 or the MIT license, at your option. This program may not be copied, modified, or distributed except according to those terms.
