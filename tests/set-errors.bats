#!/usr/bin/env bats
load './util/init.sh'

@test "Error with \$# of 1" {
	run bash_object.traverse-set string

	assert_failure
	assert_line -p "ERROR_INVALID_ARGS"
	assert_line -p ", but received '1'"
}

@test "Error with \$# of 2" {
	run bash_object.traverse-set string 'OBJECT'

	assert_failure
	assert_line -p "ERROR_INVALID_ARGS"
	assert_line -p ", but received '2'"
}

@test "Error with \$# of 3" {
	run bash_object.traverse-set string 'OBJECT' '.obj'

	assert_failure
	assert_line -p "ERROR_INVALID_ARGS"
	assert_line -p ", but received '3'"
}

@test "Error with \$# of 5" {
	run bash_object.traverse-set string 'OBJECT' '.obj' obj extraneous

	assert_failure
	assert_line -p "ERROR_INVALID_ARGS"
	assert_line -p ", but received '5'"
}

@test "Error on empty \$1" {
	run bash_object.traverse-set "" 'OBJECT' '.obj' obj

	assert_failure
	assert_line -p "ERROR_INVALID_ARGS"
	assert_line -p "'1' is empty"
}

@test "Error on empty \$2" {
	run bash_object.traverse-set string "" '.obj' obj

	assert_failure
	assert_line -p "ERROR_INVALID_ARGS"
	assert_line -p "'2' is empty"
}

@test "Error on empty \$3" {
	run bash_object.traverse-set string 'OBJECT' "" obj

	assert_failure
	assert_line -p "ERROR_INVALID_ARGS"
	assert_line -p "'3' is empty"
}

@test "Error on empty \$4" {
	run bash_object.traverse-set string 'OBJECT' '.obj' ""

	assert_failure
	assert_line -p "ERROR_INVALID_ARGS"
	assert_line -p "'4' is empty"
}

@test "Error if root object does not exist" {
	export VERIFY_BASH_OBJECT=

	run bash_object.traverse-set string 'OBJECT' '.obj' obj

	assert_failure
	assert_line -p "ERROR_VALUE_NOT_FOUND"
	assert_line -p "The associative array 'OBJECT' does not exist"
}

@test "Error if root object is an array" {
	export VERIFY_BASH_OBJECT=
	declare -a OBJECT=()

	run bash_object.traverse-set string 'OBJECT' '.obj' obj

	assert_failure
	assert_line -p "ERROR_VALUE_INCORRECT_TYPE"
	assert_line -p "The 'root object' must be an associative array"
}

@test "Error if root object is a string" {
	export VERIFY_BASH_OBJECT=
	declare OBJECT=

	run bash_object.traverse-set string 'OBJECT' '.obj' obj

	assert_failure
	assert_line -p "ERROR_VALUE_INCORRECT_TYPE"
	assert_line -p "The 'root object' must be an associative array"
}

@test "Error if root object is a string 2" {
	export VERIFY_BASH_OBJECT=
	OBJECT=

	run bash_object.traverse-set string 'OBJECT' '.obj' obj

	assert_failure
	assert_line -p "ERROR_VALUE_INCORRECT_TYPE"
	assert_line -p "The 'root object' must be an associative array"
}

@test "Error if final_value_type is 'object', but is actually nonexistent" {
	export VERIFY_BASH_OBJECT=
	declare -A OBJECT=()
	unset str

	run bash_object.traverse-set object 'OBJECT' '.obj' str

	assert_failure
	assert_line -p "ERROR_VALUE_NOT_FOUND"
	assert_line -p "The variable 'str' does not exist"
}

@test "Error if final_value_type is 'object', but is really 'array'" {
	export VERIFY_BASH_OBJECT=
	declare -A OBJECT=()
	declare -a obj=()

	run bash_object.traverse-set object 'OBJECT' '.obj' obj

	assert_failure
	assert_line -p "ERROR_VALUE_INCORRECT_TYPE"
	assert_line -p ", but a variable with type 'array' was passed"
}

@test "Error if final_value_type is 'object', but is really 'string'" {
	export VERIFY_BASH_OBJECT=
	declare -A OBJECT=()
	declare obj=

	run bash_object.traverse-set object 'OBJECT' '.obj' obj

	assert_failure
	assert_line -p "ERROR_VALUE_INCORRECT_TYPE"
	assert_line -p ", but a variable with type 'string' was passed"
}

@test "Error if final_value_type is 'object', but is really 'other'" {
	export VERIFY_BASH_OBJECT=
	declare -A OBJECT=()
	declare -i obj=

	run bash_object.traverse-set object 'OBJECT' '.obj' obj

	assert_failure
	assert_line -p "ERROR_VALUE_INCORRECT_TYPE"
	assert_line -p ", but a variable with type 'other' was passed"
}

@test "Error if final_value_type is 'array', but is actually nonexistent" {
	export VERIFY_BASH_OBJECT=
	declare -A OBJECT=()
	unset str

	run bash_object.traverse-set array 'OBJECT' '.obj' str

	assert_failure
	assert_line -p "ERROR_VALUE_NOT_FOUND"
	assert_line -p "The variable 'str' does not exist"
}

@test "Error if final_value_type is 'array', but is really 'object'" {
	export VERIFY_BASH_OBJECT=
	declare -A OBJECT=()
	declare -A obj=()

	run bash_object.traverse-set array 'OBJECT' '.obj' obj

	assert_failure
	assert_line -p "ERROR_VALUE_INCORRECT_TYPE"
	assert_line -p ", but a variable with type 'object' was passed"
}

@test "Error if final_value_type is 'array', but is really 'string'" {
	export VERIFY_BASH_OBJECT=
	declare -A OBJECT=()
	declare obj=

	run bash_object.traverse-set array 'OBJECT' '.obj' obj

	assert_failure
	assert_line -p "ERROR_VALUE_INCORRECT_TYPE"
	assert_line -p ", but a variable with type 'string' was passed"
}

@test "Error if final_value_type is 'array', but is really 'other'" {
	export VERIFY_BASH_OBJECT=
	declare -A OBJECT=()
	declare -i obj=

	run bash_object.traverse-set array 'OBJECT' '.obj' obj

	assert_failure
	assert_line -p "ERROR_VALUE_INCORRECT_TYPE"
	assert_line -p ", but a variable with type 'other' was passed"
}

@test "Error if final_value_type is 'string', but is actually nonexistent" {
	export VERIFY_BASH_OBJECT=
	declare -A OBJECT=()
	unset str

	run bash_object.traverse-set string 'OBJECT' '.obj' str

	assert_failure
	assert_line -p "ERROR_VALUE_NOT_FOUND"
	assert_line -p "The variable 'str' does not exist"
}

@test "Error if final_value_type is 'string', but is really 'object'" {
	export VERIFY_BASH_OBJECT=
	declare -A OBJECT=()
	declare -A obj=()

	run bash_object.traverse-set string 'OBJECT' '.obj' obj

	assert_failure
	assert_line -p "ERROR_VALUE_INCORRECT_TYPE"
	assert_line -p ", but a variable with type 'object' was passed"
}

@test "Error if final_value_type is 'string', but is really 'array'" {
	export VERIFY_BASH_OBJECT=
	declare -A OBJECT=()
	declare -a obj=()

	run bash_object.traverse-set string 'OBJECT' '.obj' obj

	assert_failure
	assert_line -p "ERROR_VALUE_INCORRECT_TYPE"
	assert_line -p ", but a variable with type 'array' was passed"
}

@test "Error if final_value_type is 'string', but is really 'other'" {
	export VERIFY_BASH_OBJECT=
	declare -A OBJECT=()
	declare -i obj=

	run bash_object.traverse-set string 'OBJECT' '.obj' obj

	assert_failure
	assert_line -p "ERROR_VALUE_INCORRECT_TYPE"
	assert_line -p ", but a variable with type 'other' was passed"
}
