#!/usr/bin/env bats

load './util/init.sh'

@test "properly sets 1" {
	declare -A OBJ=()

	bash_object.do-object-set 'OBJ' '.my_key' 'my_value'
	assert [ "${OBJ[my_key]}" = 'my_value' ]

	bash_object.do-object-get 'OBJ' '.my_key'
	assert [ "$REPLY" = 'my_value' ]
}

@test "properly sets 2" {
	declare -A OBJ=()

	bash_object.do-object-set 'OBJ' '.my_key.nested' 'my_value'

	bash_object.do-object-get 'OBJ' '.my_key.nested'
	assert [ "$REPLY" = 'my_value' ]
}
