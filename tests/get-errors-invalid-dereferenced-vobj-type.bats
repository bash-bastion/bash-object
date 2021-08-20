#!/usr/bin/env bats

# @brief Ensures errors are thrown when the type of vobject does not match up with the actual object that it references
# TODO

load './util/init.sh'

@test "Error if vobj object ref is actually an array" {
	export VERIFY_BASH_OBJECT=
	declare -a whatever=()
	declare -A OBJECT=([my_key]=$'\x1C\x1Dtype=object;&whatever')

	run bobject get-object --as-value OBJECT '.my_key'

	assert_failure
	assert_line -p "ERROR_VOBJ_INCORRECT_TYPE"
	assert_line -p "Virtual object has a reference of type 'object', but when dereferencing, a variable of type 'array' was found"
}

@test "Error if vobj object ref is actually a string" {
	export VERIFY_BASH_OBJECT=
	whatever=

	declare -A OBJECT=([my_key]=$'\x1C\x1Dtype=object;&whatever')

	run bobject get-object --as-value OBJECT '.my_key'

	assert_failure
	assert_line -p "ERROR_VOBJ_INCORRECT_TYPE"
	assert_line -p "Virtual object has a reference of type 'object', but when dereferencing, a variable of type 'string' was found"
}
