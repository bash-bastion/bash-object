#!/usr/bin/env bats

# @file Contains tests that ensure the positional
# parameters have been validated properly, when possible

load './util/init.sh'

@test "Error if neither '--pass-by-ref' nor '--pass-by-value' are passed" {
	run bash_object.traverse-set

	assert_failure
	assert_line -p "ERROR_ARGUMENTS_INVALID"
	assert_line -p "Must pass either the '--pass-by-ref' or '--pass-by-value' flag"
}

@test "Error with \$# of 1" {
	run bash_object.traverse-set --pass-by-ref string

	assert_failure
	assert_line -p "ERROR_ARGUMENTS_INVALID"
	assert_line -p ", but received '1'"
}

@test "Error with \$# of 2" {
	run bobject set-string --pass-by-ref 'OBJECT'

	assert_failure
	assert_line -p "ERROR_ARGUMENTS_INVALID"
	assert_line -p ", but received '2'"
}

@test "Error with \$# of 3" {
	run bobject set-string --pass-by-ref 'OBJECT' '.obj'

	assert_failure
	assert_line -p "ERROR_ARGUMENTS_INVALID"
	assert_line -p ", but received '3'"
}

@test "Error with \$# of 5" {
	run bobject set-string --pass-by-ref 'OBJECT' '.obj' obj extraneous

	assert_failure
	assert_line -p "ERROR_ARGUMENTS_INVALID"
	assert_line -p ", but received '5'"
}

@test "Error with \$# of 1 (--pass-by-value, string)" {
	run bobject set-string --pass-by-value

	assert_failure
	assert_line -p "ERROR_ARGUMENTS_INVALID"
	assert_line -p ", but received '1'"
}

@test "Error with \$# of 2 (--pass-by-value, string)" {
	run bobject set-string --pass-by-value 'OBJECT'

	assert_failure
	assert_line -p "ERROR_ARGUMENTS_INVALID"
	assert_line -p ", but received '2'"
}

@test "Error with \$# of 3 (--pass-by-value, string)" {
	run bobject set-string --pass-by-value 'OBJECT' '.obj'

	assert_failure
	assert_line -p "ERROR_ARGUMENTS_INVALID"
	assert_line -p ", but received '3'"
}

@test "Error with \$# of 5 (--pass-by-value, string)" {
	run bobject set-string --pass-by-value 'OBJECT' '.obj' obj extraneous

	assert_failure
	assert_line -p "ERROR_ARGUMENTS_INVALID"
	assert_line -p ", but received '5'"
}


@test "Error on empty \$2" {
	run bobject set-string --pass-by-ref "" '.obj' obj

	assert_failure
	assert_line -p "ERROR_ARGUMENTS_INVALID"
	assert_line -p "'2' is empty"
}

@test "Error on empty \$3" {
	run bobject set-string --pass-by-ref 'OBJECT' "" obj

	assert_failure
	assert_line -p "ERROR_ARGUMENTS_INVALID"
	assert_line -p "'3' is empty"
}

@test "Error on empty \$4" {
	run bobject set-string --pass-by-ref 'OBJECT' '.obj' ""

	assert_failure
	assert_line -p "ERROR_ARGUMENTS_INVALID"
	assert_line -p "'4' is empty"
}

@test "Do not error on empty \$4 on --pass-by-value" {
	run bobject set-string --pass-by-value 'OBJECT' '.obj' ""

	assert_success
}

@test "Error if root object does not exist" {
	export VERIFY_BASH_OBJECT=

	run bobject set-string --pass-by-ref 'OBJECT' '.obj' obj

	assert_failure
	assert_line -p "ERROR_NOT_FOUND"
	assert_line -p "The associative array 'OBJECT' does not exist"
}

@test "Error if root object is an array" {
	export VERIFY_BASH_OBJECT=
	declare -a OBJECT=()

	run bobject set-string --pass-by-ref 'OBJECT' '.obj' obj

	assert_failure
	assert_line -p "ERROR_ARGUMENTS_INVALID_TYPE"
	assert_line -p "The 'root object' must be an associative array"
}

@test "Error if root object is a string" {
	export VERIFY_BASH_OBJECT=
	declare OBJECT=

	run bobject set-string --pass-by-ref 'OBJECT' '.obj' obj

	assert_failure
	assert_line -p "ERROR_ARGUMENTS_INVALID_TYPE"
	assert_line -p "The 'root object' must be an associative array"
}

@test "Error if root object is a string 2" {
	export VERIFY_BASH_OBJECT=
	OBJECT=

	run bobject set-string --pass-by-ref 'OBJECT' '.obj' obj

	assert_failure
	assert_line -p "ERROR_ARGUMENTS_INVALID_TYPE"
	assert_line -p "The 'root object' must be an associative array"
}

@test "Error if final_value_type is 'object', but is actually nonexistent" {
	export VERIFY_BASH_OBJECT=
	declare -A OBJECT=()
	unset str

	run bobject set-object --pass-by-ref 'OBJECT' '.obj' str

	assert_failure
	assert_line -p "ERROR_NOT_FOUND"
	assert_line -p "The variable 'str' does not exist"
}

@test "Error if final_value_type is 'object', but is really 'array'" {
	export VERIFY_BASH_OBJECT=
	declare -A OBJECT=()
	declare -a obj=()

	run bobject set-object --pass-by-ref 'OBJECT' '.obj' obj

	assert_failure
	assert_line -p "ERROR_ARGUMENTS_INVALID_TYPE"
	assert_line -p ", but a variable with type 'array' was passed"
}

@test "Error if final_value_type is 'object', but is really 'string'" {
	export VERIFY_BASH_OBJECT=
	declare -A OBJECT=()
	declare obj=

	run bobject set-object --pass-by-ref 'OBJECT' '.obj' obj

	assert_failure
	assert_line -p "ERROR_ARGUMENTS_INVALID_TYPE"
	assert_line -p ", but a variable with type 'string' was passed"
}

@test "Error if final_value_type is 'object', but is really 'other'" {
	export VERIFY_BASH_OBJECT=
	declare -A OBJECT=()
	declare -i obj=

	run bobject set-object --pass-by-ref 'OBJECT' '.obj' obj

	assert_failure
	assert_line -p "ERROR_ARGUMENTS_INVALID_TYPE"
	assert_line -p ", but a variable with type 'other' was passed"
}

@test "Error if final_value_type is 'array', but is actually nonexistent" {
	export VERIFY_BASH_OBJECT=
	declare -A OBJECT=()
	unset str

	run bobject set-array --pass-by-ref 'OBJECT' '.obj' str

	assert_failure
	assert_line -p "ERROR_NOT_FOUND"
	assert_line -p "The variable 'str' does not exist"
}

@test "Error if final_value_type is 'array', but is really 'object'" {
	export VERIFY_BASH_OBJECT=
	declare -A OBJECT=()
	declare -A obj=()

	run bobject set-array --pass-by-ref 'OBJECT' '.obj' obj

	assert_failure
	assert_line -p "ERROR_ARGUMENTS_INVALID_TYPE"
	assert_line -p ", but a variable with type 'object' was passed"
}

@test "Error if final_value_type is 'array', but is really 'string'" {
	export VERIFY_BASH_OBJECT=
	declare -A OBJECT=()
	declare obj=

	run bobject set-array --pass-by-ref 'OBJECT' '.obj' obj

	assert_failure
	assert_line -p "ERROR_ARGUMENTS_INVALID_TYPE"
	assert_line -p ", but a variable with type 'string' was passed"
}

@test "Error if final_value_type is 'array', but is really 'other'" {
	export VERIFY_BASH_OBJECT=
	declare -A OBJECT=()
	declare -i obj=

	run bobject set-array --pass-by-ref 'OBJECT' '.obj' obj

	assert_failure
	assert_line -p "ERROR_ARGUMENTS_INVALID_TYPE"
	assert_line -p ", but a variable with type 'other' was passed"
}

@test "Error if final_value_type is 'string', but is actually nonexistent" {
	export VERIFY_BASH_OBJECT=
	declare -A OBJECT=()
	unset str

	run bobject set-string --pass-by-ref 'OBJECT' '.obj' str

	assert_failure
	assert_line -p "ERROR_NOT_FOUND"
	assert_line -p "The variable 'str' does not exist"
}

@test "Error if final_value_type is 'string', but is really 'object'" {
	export VERIFY_BASH_OBJECT=
	declare -A OBJECT=()
	declare -A obj=()

	run bobject set-string --pass-by-ref 'OBJECT' '.obj' obj

	assert_failure
	assert_line -p "ERROR_ARGUMENTS_INVALID_TYPE"
	assert_line -p ", but a variable with type 'object' was passed"
}

@test "Error if final_value_type is 'string', but is really 'array'" {
	export VERIFY_BASH_OBJECT=
	declare -A OBJECT=()
	declare -a obj=()

	run bobject set-string --pass-by-ref 'OBJECT' '.obj' obj

	assert_failure
	assert_line -p "ERROR_ARGUMENTS_INVALID_TYPE"
	assert_line -p ", but a variable with type 'array' was passed"
}

@test "Error if final_value_type is 'string', but is really 'other'" {
	export VERIFY_BASH_OBJECT=
	declare -A OBJECT=()
	declare -i obj=

	run bobject set-string --pass-by-ref 'OBJECT' '.obj' obj

	assert_failure
	assert_line -p "ERROR_ARGUMENTS_INVALID_TYPE"
	assert_line -p ", but a variable with type 'other' was passed"
}

# Data validation should not be done if the keys to set are
# being passed as value
@test "Do not error if final_value_type is 'string', but is really 'array' on --pass-by-value" {
	export VERIFY_BASH_OBJECT=
	declare -A OBJECT=()
	declare -a obj=()

	run bobject set-string --pass-by-value 'OBJECT' '.obj' obj

	assert_success
}
