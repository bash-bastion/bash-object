#!/usr/bin/env bats

load './util/init.sh'

@test "error on more than correct 'get' arguments" {
	local subcmds=(get-string get-array get-object)

	for subcmd in "${subcmds[@]}"; do
		declare -A OBJ=()

		run bobject "$subcmd" 'OBJ' '.zulu.yankee' 'invalid'

		assert_failure
		assert_line -p "Incorrect arguments for subcommand '$subcmd'"
	done
}

@test "error on less than correct 'get' arguments" {
	local subcmds=(get-string get-array get-object)

	for subcmd in "${subcmds[@]}"; do
		declare -A OBJ=()

		run bobject "$subcmd" 'invalid'

		assert_failure
		assert_line -p "Incorrect arguments for subcommand '$subcmd'"
	done
}

@test "error on more than correct 'set' arguments" {
	local subcmds=(set-string set-array set-object)

	for subcmd in "${subcmds[@]}"; do
		declare -A OBJ=()

		run bobject "$subcmd" 'OBJ' '.zulu.yankee' 'xray' 'invalid'

		assert_failure
		assert_line -p "Incorrect arguments for subcommand '$subcmd'"
	done
}

@test "error on less than correct 'set' arguments" {
	local subcmds=(set-string set-array set-object)

	for subcmd in "${subcmds[@]}"; do
		declare -A OBJ=()

		run bobject "$subcmd" 'OBJ' '.zulu'

		assert_failure
		assert_line -p "Incorrect arguments for subcommand '$subcmd'"
	done
}

@test "get-string" {
	declare -A OBJ=()

	bobject set-string 'OBJ' '.zulu.yankee' 'MEOW'
	bobject get-string 'OBJ' '.zulu.yankee'

	assert [ "$REPLY" = 'MEOW' ]
}
