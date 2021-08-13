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

@test "correctly gets array" {
	declare -a SUB_ARRAY=(omicron pi rho)
	declare -A OBJECT=([my_key]=$'\x1C\x1Dtype=array;&SUB_ARRAY')

	bash_object.traverse-get array OBJECT '.my_key'
	assert [ ${#REPLY[@]} -eq 3 ]
	assert [ "${REPLY[0]}" = omicron ]
	assert [ "${REPLY[1]}" = pi ]
	assert [ "${REPLY[2]}" = rho ]

	bash_object.traverse-get string OBJECT '.["my_key"].[2]'
	assert [ "$REPLY" = rho ]
}

@test "correctly gets array in subobject" {
	declare -a SUB_SUB_ARRAY=(pi rho sigma)
	declare -A SUB_OBJECT=([subkey]=$'\x1C\x1Dtype=array;&SUB_SUB_ARRAY')
	declare -A OBJECT=([my_key]=$'\x1C\x1Dtype=object;&SUB_OBJECT')

	bash_object.traverse-get array OBJECT '.my_key.subkey'
	assert [ ${#REPLY[@]} -eq 3 ]
	assert [ "${REPLY[0]}" = pi ]
	assert [ "${REPLY[1]}" = rho ]
	assert [ "${REPLY[2]}" = sigma ]

	bash_object.traverse-get string OBJECT '.["my_key"].["subkey"].[2]'
	assert [ "$REPLY" = sigma ]
}

@test "correctly gets array in subarray" {
	declare -a SUB_SUB_ARRAY=(omicron pi rho)
	declare -a SUB_ARRAY=('foo' 'bar' $'\x1C\x1Dtype=array;&SUB_SUB_ARRAY')
	declare -A OBJECT=([my_key]=$'\x1C\x1Dtype=array;&SUB_ARRAY')

	bash_object.traverse-get array OBJECT '.["my_key"].[2]'
	assert [ ${#REPLY[@]} -eq 3 ]
	assert [ "${REPLY[0]}" = omicron ]
	assert [ "${REPLY[1]}" = pi ]
	assert [ "${REPLY[2]}" = rho ]


	bash_object.traverse-get string OBJECT '.["my_key"].[2].[0]'
	assert [ "$REPLY" = omicron ]
}
