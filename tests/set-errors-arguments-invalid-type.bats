#!/usr/bin/env bats

load './util/init.sh'

@test "Error if root object does not exist" {
	export VERIFY_BASH_OBJECT=

	run bobject set-string --ref 'OBJECT' '.obj' obj

	assert_failure
	assert_line -p "ERROR_NOT_FOUND"
	assert_line -p "The associative array 'OBJECT' does not exist"
}

@test "Error if root object is an array" {
	export VERIFY_BASH_OBJECT=
	declare -a OBJECT=()

	run bobject set-string --ref 'OBJECT' '.obj' obj

	assert_failure
	assert_line -p "ERROR_ARGUMENTS_INVALID_TYPE"
	assert_line -p "The 'root object' must be an associative array"
}

@test "Error if root object is a string" {
	export VERIFY_BASH_OBJECT=
	declare OBJECT=

	run bobject set-string --ref 'OBJECT' '.obj' obj

	assert_failure
	assert_line -p "ERROR_ARGUMENTS_INVALID_TYPE"
	assert_line -p "The 'root object' must be an associative array"
}

@test "Error if root object is a string 2" {
	export VERIFY_BASH_OBJECT=
	OBJECT=

	run bobject set-string --ref 'OBJECT' '.obj' obj

	assert_failure
	assert_line -p "ERROR_ARGUMENTS_INVALID_TYPE"
	assert_line -p "The 'root object' must be an associative array"
}

@test "Error if final_value_type is 'string', but is actually 'object'" {
	export VERIFY_BASH_OBJECT=
	declare -A OBJECT=()
	declare -A obj=()

	run bobject set-string --ref 'OBJECT' '.obj' obj

	assert_failure
	assert_line -p "ERROR_ARGUMENTS_INVALID_TYPE"
	assert_line -p ", but a variable with type 'object' was passed"
}

@test "Error if final_value_type is 'string', but is actually 'array'" {
	export VERIFY_BASH_OBJECT=
	declare -A OBJECT=()
	declare -a obj=()

	run bobject set-string --ref 'OBJECT' '.obj' obj

	assert_failure
	assert_line -p "ERROR_ARGUMENTS_INVALID_TYPE"
	assert_line -p ", but a variable with type 'array' was passed"
}

@test "Error if final_value_type is 'string', but is actually 'other'" {
	export VERIFY_BASH_OBJECT=
	declare -A OBJECT=()
	declare -i obj=

	run bobject set-string --ref 'OBJECT' '.obj' obj

	assert_failure
	assert_line -p "ERROR_ARGUMENTS_INVALID_TYPE"
	assert_line -p ", but a variable with type 'other' was passed"
}
