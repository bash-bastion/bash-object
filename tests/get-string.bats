#!/usr/bin/env bats

load './util/init.sh'

@test "errors if final value is not of type string" {
	declare -A SUB_OBJECT=([omicron]='pi')
	declare -A OBJECT=([my_key]=$'\x1C\x1Dtype=object;&SUB_OBJECT')

	run bash_object.traverse get string OBJECT '.my_key'
	assert_failure
	assert_line -p 'A query for a string was given, but either an object or array was found'
}

@test "properly gets string in root" {
	declare -A OBJECT=([my_key]='my_value')

	bash_object.traverse get string OBJECT '.my_key'
	assert [ "$REPLY" = 'my_value' ]
}

@test "properly gets string in object" {
	declare -A EPSILON_OBJECT=([my_key]='my_value2')
	declare -A OBJECT=([epsilon]=$'\x1C\x1Dtype=object;&EPSILON_OBJECT')

	bash_object.traverse get string OBJECT '.epsilon.my_key'
	assert [ "$REPLY" = 'my_value2' ]
}
