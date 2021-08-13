#!/usr/bin/env bats

load './util/init.sh'

@test "ERROR_VALUE_INCORRECT_TYPE on get-array'ing string" {
	declare -A OBJECT=([my_key]='string_value2')

	run bash_object.traverse-get array OBJECT '.my_key'

	assert_failure
	assert_line -p "ERROR_VALUE_INCORRECT_TYPE"
	assert_line -p 'Queried for array, but found string'
}

@test "ERROR_VALUE_INCORRECT_TYPE on get-array'ing string in object" {
	declare -A SUB_OBJECT=([nested]='string_value')
	declare -A OBJECT=([my_key]=$'\x1C\x1Dtype=object;&SUB_OBJECT')

	run bash_object.traverse-get array OBJECT '.my_key.nested'

	assert_failure
	assert_line -p "ERROR_VALUE_INCORRECT_TYPE"
	assert_line -p 'Queried for array, but found string'
}

@test "ERROR_VALUE_INCORRECT_TYPE on get-array'ing object" {
	declare -A SUB_OBJECT=([omicron]='pi')
	declare -A OBJECT=([my_key]=$'\x1C\x1Dtype=object;&SUB_OBJECT')

	run bash_object.traverse-get array OBJECT '.my_key'

	assert_failure
	assert_line -p "ERROR_VALUE_INCORRECT_TYPE"
	assert_line -p 'Queried for array, but found object'
}

@test "ERROR_VALUE_INCORRECT_TYPE on get-array'ing object in object" {
	declare -A SUB_SUB_OBJECT=([omicron]='pi')
	declare -A SUB_OBJECT=([nested]=$'\x1C\x1Dtype=object;&SUB_SUB_OBJECT')
	declare -A OBJECT=([my_key]=$'\x1C\x1Dtype=object;&SUB_OBJECT')

	run bash_object.traverse-get array OBJECT '.my_key.nested'

	assert_failure
	assert_line -p "ERROR_VALUE_INCORRECT_TYPE"
	assert_line -p 'Queried for array, but found object'
}
