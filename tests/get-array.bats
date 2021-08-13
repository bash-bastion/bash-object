#!/usr/bin/env bats

load './util/init.sh'

@test "errors if final type is 'string' when expecting type 'array' 1" {
	declare -A OBJECT=([my_key]='string_value2')

	run bash_object.traverse get array OBJECT '.my_key'

	assert_failure
	assert_line -p "A query for type 'array' was given, but a string was found"
}

@test "errors if final type is 'string' when expecting type 'array' 2" {
	declare -A SUB_OBJECT=([nested]='string_value')
	declare -A OBJECT=([my_key]=$'\x1C\x1Dtype=object;&SUB_OBJECT')

	run bash_object.traverse get array OBJECT '.my_key.nested'

	assert_failure
	assert_line -p "A query for type 'array' was given, but a string was found"
}

@test "errors if final type is 'object' when expecting type 'string' 1" {
	declare -A SUB_OBJECT=([omicron]='pi')
	declare -A OBJECT=([my_key]=$'\x1C\x1Dtype=object;&SUB_OBJECT')

	run bash_object.traverse get array OBJECT '.my_key'

	assert_failure
	assert_line -p "A query for type 'array' was given, but an object was found"
}

@test "errors if final type is 'object' when expecting type 'string' 2" {
	declare -A SUB_SUB_OBJECT=([omicron]='pi')
	declare -A SUB_OBJECT=([nested]=$'\x1C\x1Dtype=object;&SUB_SUB_OBJECT')
	declare -A OBJECT=([my_key]=$'\x1C\x1Dtype=object;&SUB_OBJECT')

	run bash_object.traverse get array OBJECT '.my_key.nested'

	assert_failure
	assert_line -p "A query for type 'array' was given, but an object was found"
}
