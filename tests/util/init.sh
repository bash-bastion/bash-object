# shellcheck shell=bash

eval "$(basalt-package-init)"
basalt.package-init
basalt.package-load
basalt.load 'github.com/hyperupcall/bats-all' 'load.bash'

setup() {
	cd "$BATS_TEST_TMPDIR"
}

teardown() {
	cd "$BATS_SUITE_TMPDIR"
}
