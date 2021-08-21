#!/usr/bin/env bats

# @brief Ensures errors are thrown when the type of the virtual object
# does not match up with the actual object that it references. We construct
# the virtual object manually since this type of error would get caught
# when checking the type of the command arguments (with VERIFY_BASH_OBJECT set)

load './util/init.sh'

# get-object
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

# get-array
@test "Error if vobj array ref is actually an object" {
	export VERIFY_BASH_OBJECT=
	declare -A whatever=()
	declare -A OBJECT=([my_key]=$'\x1C\x1Dtype=array;&whatever')

	run bobject get-array --as-value OBJECT '.my_key'

	assert_failure
	assert_line -p "ERROR_VOBJ_INCORRECT_TYPE"
	assert_line -p "Virtual object has a reference of type 'array', but when dereferencing, a variable of type 'object' was found"
}

@test "Error if vobj array ref is actually a string" {
	export VERIFY_BASH_OBJECT=
	whatever=

	declare -A OBJECT=([my_key]=$'\x1C\x1Dtype=array;&whatever')

	run bobject get-array --as-value OBJECT '.my_key'

	assert_failure
	assert_line -p "ERROR_VOBJ_INCORRECT_TYPE"
	assert_line -p "Virtual object has a reference of type 'array', but when dereferencing, a variable of type 'string' was found"
}
