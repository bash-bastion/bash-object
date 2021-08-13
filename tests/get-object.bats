#!/usr/bin/env bats

load './util/init.sh'

@test "ERROR_VALUE_INCORRECT_TYPE on get-object'ing string" {
	declare -A OBJECT=([my_key]='string_value2')

	run bash_object.traverse-get object OBJECT '.my_key'

	assert_failure
	assert_line -p "ERROR_VALUE_INCORRECT_TYPE"
	assert_line -p 'Queried for object, but found string'
}

@test "ERROR_VALUE_INCORRECT_TYPE on get-object'ing string inside object" {
	declare -A SUB_OBJECT=([nested]='string_value')
	declare -A OBJECT=([my_key]=$'\x1C\x1Dtype=object;&SUB_OBJECT')

	run bash_object.traverse-get object OBJECT '.my_key.nested'

	assert_failure
	assert_line -p "ERROR_VALUE_INCORRECT_TYPE"
	assert_line -p 'Queried for object, but found string'
}

@test "ERROR_VALUE_INCORRECT_TYPE on get-object'ing array" {
	declare -a SUB_ARRAY=(omicron pi rho)
	declare -A OBJECT=([my_key]=$'\x1C\x1Dtype=array;&SUB_ARRAY')

	run bash_object.traverse-get object OBJECT '.my_key'

	assert_failure
	assert_line -p "ERROR_VALUE_INCORRECT_TYPE"
	assert_line -p 'Queried for object, but found array'
}

@test "ERROR_VALUE_INCORRECT_TYPE on get-object'ing array inside object" {
	declare -a SUB_SUB_ARRAY=(omicron pi rho)
	declare -A SUB_OBJECT=([nested]=$'\x1C\x1Dtype=array;&SUB_SUB_ARRAY')
	declare -A OBJECT=([my_key]=$'\x1C\x1Dtype=array;&SUB_OBJECT')

	run bash_object.traverse-get object OBJECT '.my_key.nested'

	assert_failure
	assert_line -p "ERROR_VALUE_INCORRECT_TYPE"
	assert_line -p 'Queried for object, but found array'
}

# { "stars": { "cool": "Wolf 359" } }
@test "properly gets 4" {
	declare -A inner_object=([cool]='Wolf 359')
	declare -A OBJ=([stars]=$'\x1C\x1Dtype=object;&inner_object')

	bash_object.traverse-get object 'OBJ' '.stars'
	assert [ "${REPLY[cool]}" = 'Wolf 359' ]
}

# { "stars": { "cool": "Wolf 359" } }
@test "properly gets 5" {
	declare -a inner_array=('Alpha Centauri A' 'Proxima Centauri')
	declare -A OBJ=([nearby]=$'\x1C\x1Dtype=object;&inner_array')

	bash_object.traverse-get object 'OBJ' '.nearby'
	assert [ "${#REPLY[@]}" -eq 2 ]
	assert [ "${REPLY[0]}" = 'Alpha Centauri A' ]
	assert [ "${REPLY[1]}" = 'Proxima Centauri' ]
}
