#!/usr/bin/env bats

load './util/init.sh'

@test "properly sets 1" {
	declare -A OBJ=()

	bash_object.traverse set string 'OBJ' '.my_key' 'my_value'
	assert [ "${OBJ[my_key]}" = 'my_value' ]

	bash_object.traverse get string 'OBJ' '.my_key'
	assert [ "$REPLY" = 'my_value' ]
}

# @test "properly sets 2" {
# 	declare -A OBJ=()

# 	bash_object.traverse set string 'OBJ' '.xray.yankee.zulu' 'boson'
# 	bash_object.traverse set string 'OBJ' '.xray.yankee' 'lithography'

# 	bash_object.traverse get string 'OBJ' '.xray.yankee.zulu'
# 	assert [ "$REPLY" = 'boson' ]

# 	# bash_object.traverse get string 'OBJ' '.xray.yankee'
# 	# assert [ "$REPLY" = 'lithography' ]
# }
