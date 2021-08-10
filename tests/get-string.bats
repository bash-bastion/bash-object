#!/usr/bin/env bats

load './util/init.sh'

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
