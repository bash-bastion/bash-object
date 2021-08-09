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

# @test "properly sets 3" {
# 	declare -A OBJ=()

# 	bash_object.do-object-set 'OBJ' '.my_key.nested.YAY' 'fortran_is_cool'
# 	echo ---- divider >&3
# 	bash_object.do-object-set 'OBJ' '.my_key.other' 'success'

# 	bash_object.do-object-get 'OBJ' '.my_key.nested.YAY'
# 	assert [ "$REPLY" = 'fortran_is_cool' ]

# 	bash_object.do-object-get 'OBJ' '.my_key.other'
# 	assert [ "$REPLY" = 'success' ]
# }
