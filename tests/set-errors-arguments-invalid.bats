#!/usr/bin/env bats

# @file Contains tests that ensure the positional
# parameters have been validated properly, when possible

load './util/init.sh'

@test "error on more than correct 'set' arguments" {
	local subcmds=(set-string set-array set-object)

	for subcmd in "${subcmds[@]}"; do
		declare -A OBJECT=()

		run bobject "$subcmd" --ref 'OBJECT' '.zulu.yankee' 'xray' 'invalid'

		assert_failure
		assert_line -p 'ERROR_ARGUMENTS_INVALID'
		assert_line -p "Expected 4 arguments (with --ref), but received 5"
	done
}

@test "error on less than correct 'set' arguments" {
	local subcmds=(set-string set-array set-object)

	for subcmd in "${subcmds[@]}"; do
		declare -A OBJECT=()

		run bobject "$subcmd" --ref 'OBJECT' '.zulu'

		assert_failure
		assert_line -p 'ERROR_ARGUMENTS_INVALID'
		assert_line -p "Expected 4 arguments (with --ref), but received 3"
	done
}

@test "Error on invalid \$1" {
	run bobject set-blah

	assert_failure
	assert_line -p "ERROR_ARGUMENTS_INVALID"
	assert_line -p "Subcommand 'set-blah' not recognized"
}

@test "Error with --ref \$# of 1" {
	run bash_object.traverse-set --ref string

	assert_failure
	assert_line -p "ERROR_ARGUMENTS_INVALID"
	assert_line -p "Expected 4 arguments (with --ref), but received 1"
}

@test "Error with --ref \$# of 2" {
	run bobject set-string --ref 'OBJECT'

	assert_failure
	assert_line -p "ERROR_ARGUMENTS_INVALID"
	assert_line -p "Expected 4 arguments (with --ref), but received 2"
}

@test "Error with --ref \$# of 3" {
	run bobject set-string --ref 'OBJECT' '.obj'

	assert_failure
	assert_line -p "ERROR_ARGUMENTS_INVALID"
	assert_line -p "Expected 4 arguments (with --ref), but received 3"
}

@test "Error with --ref \$# of 5" {
	run bobject set-string --ref 'OBJECT' '.obj' obj extraneous

	assert_failure
	assert_line -p "ERROR_ARGUMENTS_INVALID"
	assert_line -p "Expected 4 arguments (with --ref), but received 5"
}

@test "Error with --value \$# of 1" {
	run bobject set-string --value

	assert_failure
	assert_line -p "ERROR_ARGUMENTS_INVALID"
	assert_line -p "Expected 3 arguments (with --value) before '--', but received 1"
}

@test "Error with --value \$# of 2" {
	run bobject set-string --value 'OBJECT'

	assert_failure
	assert_line -p "ERROR_ARGUMENTS_INVALID"
	assert_line -p "Expected 3 arguments (with --value) before '--', but received 2"
}

@test "Error with --value \$# of 4" {
	run bobject set-string --value 'OBJECT' '.obj' obj

	assert_failure
	assert_line -p "ERROR_ARGUMENTS_INVALID"
	assert_line -p "Expected 3 arguments (with --value) before '--', but received 4"
}

@test "Error with --value if forget to pass --" {
	local subcmds=(set-string set-array set-object)

	for subcmd in "${subcmds[@]}"; do
		declare -A OBJECT=()

		run bobject "$subcmd" --value 'OBJECT' '.zulu'

		assert_failure
		assert_line -p 'ERROR_ARGUMENTS_INVALID'
		assert_line -p "Must pass '--' and the value when using --value"
	done
}

@test "Error on empty \$2" {
	run bobject set-string --ref "" '.obj' obj

	assert_failure
	assert_line -p "ERROR_ARGUMENTS_INVALID"
	assert_line -p "Positional parameter 2 is empty"
}

@test "Error on empty \$3" {
	run bobject set-string --ref 'OBJECT' "" obj

	assert_failure
	assert_line -p "ERROR_ARGUMENTS_INVALID"
	assert_line -p "Positional parameter 3 is empty"
}

@test "Error on empty \$4 --ref" {
	run bobject set-string --ref 'OBJECT' '.obj' ""

	assert_failure
	assert_line -p "ERROR_ARGUMENTS_INVALID"
	assert_line -p "Positional parameter 4 is empty"
}

# check for type of arguments for --ref
@test "Error if final_value_type is 'object', but is actually nonexistent" {
	export VERIFY_BASH_OBJECT=
	declare -A OBJECT=()
	unset str

	run bobject set-object --ref 'OBJECT' '.obj' str

	assert_failure
	assert_line -p "ERROR_NOT_FOUND"
	assert_line -p "The variable 'str' does not exist"
}

@test "Error if final_value_type is 'object', but is actually 'array'" {
	export VERIFY_BASH_OBJECT=
	declare -A OBJECT=()
	declare -a obj=()

	run bobject set-object --ref 'OBJECT' '.obj' obj

	assert_failure
	assert_line -p "ERROR_ARGUMENTS_INVALID_TYPE"
	assert_line -p ", but a variable with type 'array' was passed"
}

@test "Error if final_value_type is 'object', but is actually 'string'" {
	export VERIFY_BASH_OBJECT=
	declare -A OBJECT=()
	declare obj=

	run bobject set-object --ref 'OBJECT' '.obj' obj

	assert_failure
	assert_line -p "ERROR_ARGUMENTS_INVALID_TYPE"
	assert_line -p ", but a variable with type 'string' was passed"
}

@test "Error if final_value_type is 'object', but is actually 'other'" {
	export VERIFY_BASH_OBJECT=
	declare -A OBJECT=()
	declare -i obj=

	run bobject set-object --ref 'OBJECT' '.obj' obj

	assert_failure
	assert_line -p "ERROR_ARGUMENTS_INVALID_TYPE"
	assert_line -p ", but a variable with type 'other' was passed"
}

@test "Error if final_value_type is 'array', but is actually nonexistent" {
	export VERIFY_BASH_OBJECT=
	declare -A OBJECT=()
	unset str

	run bobject set-array --ref 'OBJECT' '.obj' str

	assert_failure
	assert_line -p "ERROR_NOT_FOUND"
	assert_line -p "The variable 'str' does not exist"
}

@test "Error if final_value_type is 'array', but is actually 'object'" {
	export VERIFY_BASH_OBJECT=
	declare -A OBJECT=()
	declare -A obj=()

	run bobject set-array --ref 'OBJECT' '.obj' obj

	assert_failure
	assert_line -p "ERROR_ARGUMENTS_INVALID_TYPE"
	assert_line -p ", but a variable with type 'object' was passed"
}

@test "Error if final_value_type is 'array', but is actually 'string'" {
	export VERIFY_BASH_OBJECT=
	declare -A OBJECT=()
	declare obj=

	run bobject set-array --ref 'OBJECT' '.obj' obj

	assert_failure
	assert_line -p "ERROR_ARGUMENTS_INVALID_TYPE"
	assert_line -p ", but a variable with type 'string' was passed"
}

@test "Error if final_value_type is 'array', but is actually 'other'" {
	export VERIFY_BASH_OBJECT=
	declare -A OBJECT=()
	declare -i obj=

	run bobject set-array --ref 'OBJECT' '.obj' obj

	assert_failure
	assert_line -p "ERROR_ARGUMENTS_INVALID_TYPE"
	assert_line -p ", but a variable with type 'other' was passed"
}

@test "Error if final_value_type is 'string', but is actually nonexistent" {
	export VERIFY_BASH_OBJECT=
	declare -A OBJECT=()
	unset str

	run bobject set-string --ref 'OBJECT' '.obj' str

	assert_failure
	assert_line -p "ERROR_NOT_FOUND"
	assert_line -p "The variable 'str' does not exist"
}
