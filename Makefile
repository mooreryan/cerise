BROWSER = firefox
BENCH_D = bench
DOCS_D = _docs
TEST_COV_D = /tmp/cerise
NAME = cerise

.PHONY: all
all: build_release install

.PHONY: build
build:
	dune build

.PHONY: build_mac
build_mac:
	dune build -j 1

.PHONY: build_release
build_release:
	dune build --profile=release

.PHONY: build_release_mac
build_release_mac:
	dune build --profile=release -j 1

.PHONY: check
check:
	dune build @check

.PHONY: clean
clean:
	dune clean

.PHONY: install
install: build_release
	dune install

.PHONY: uninstall
uninstall:
	dune uninstall

.PHONY: test
test:
	dune runtest

.PHONY: test_mac
test_mac:
	dune runtest -j 1

.PHONY: test_coverage
test_coverage:
	if [ -d $(TEST_COV_D) ]; then rm -r $(TEST_COV_D); fi
	mkdir -p $(TEST_COV_D)
	BISECT_FILE=$(TEST_COV_D)/$(NAME) dune runtest --no-print-directory \
	  --instrument-with bisect_ppx --force
	bisect-ppx-report html --coverage-path $(TEST_COV_D)
	bisect-ppx-report summary --coverage-path $(TEST_COV_D)

.PHONY: test_coverage_open
test_coverage_open: test_coverage
	$(BROWSER) _coverage/index.html

.PHONY: send_coverage
send_coverage: test_coverage
	bisect-ppx-report send-to Coveralls --coverage-path $(TEST_COV_D)
