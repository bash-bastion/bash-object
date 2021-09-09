#!/usr/bin/env bats

# @brief Contains tests that ensure the positional
# parameters have been validated properly, when possible. \$1 is not
# tested because bobject.sh always sets the first positional parameter

load './util/init.sh'

@test "error on more than correct 'get' arguments" {
	local subcmds=(get-string get-array get-object)

	for subcmd in "${subcmds[@]}"; do
		declare -A OBJECT=()

		run bobject "$subcmd" --value 'OBJECT' '.zulu.yankee' 'invalid'

		assert_failure
		assert_line -p 'ERROR_ARGUMENTS_INVALID'
		assert_line -p "Expected 3 arguments, but received 4"
	done
}

@test "error on less than correct 'get' arguments" {
	local subcmds=(get-string get-array get-object)

	for subcmd in "${subcmds[@]}"; do
		declare -A OBJECT=()

		run bobject "$subcmd" --value 'invalid'

		assert_failure
		assert_line -p 'ERROR_ARGUMENTS_INVALID'
		assert_line -p "Expected 3 arguments, but received 2"
	done
}

# get
@test "Error on invalid \$1" {
	run bobject get-blah

	assert_failure
	assert_line -p "ERROR_ARGUMENTS_INVALID"
	assert_line -p "Subcommand 'get-blah' not recognized"
}

@test "Error with \$# of 2" {
	run bobject get-string --value 'OBJECT'

	assert_failure
	assert_line -p "ERROR_ARGUMENTS_INVALID"
	assert_line -p "Expected 3 arguments, but received 2"
}

@test "Error with \$# of 4" {
	run bobject get-string --value 'OBJECT' '.obj' extraneous

	assert_failure
	assert_line -p "ERROR_ARGUMENTS_INVALID"
	assert_line -p "Expected 3 arguments, but received 4"
}

@test "Error on empty \$2" {
	run bobject get-string --value "" '.obj'

	assert_failure
	assert_line -p "ERROR_ARGUMENTS_INVALID"
	assert_line -p "Positional parameter 2 is empty"
}

@test "Error on empty \$3" {
	run bobject get-string --value 'OBJECT' ""

	assert_failure
	assert_line -p "ERROR_ARGUMENTS_INVALID"
	assert_line -p "Positional parameter 3 is empty"
}
