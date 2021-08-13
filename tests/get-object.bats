#!/usr/bin/env bats

load './util/init.sh'

@test "errors if final type is 'string' when expecting type 'object' 1" {
	declare -A OBJECT=([my_key]='string_value2')

	run bash_object.traverse get object OBJECT '.my_key'

	assert_failure
	assert_line -p "A query for type 'object' was given, but a string was found"
}

@test "errors if final type is 'string' when expecting type 'object' 2" {
	declare -A SUB_OBJECT=([nested]='string_value')
	declare -A OBJECT=([my_key]=$'\x1C\x1Dtype=object;&SUB_OBJECT')

	run bash_object.traverse get object OBJECT '.my_key.nested'

	assert_failure
	assert_line -p "A query for type 'object' was given, but a string was found"
}

@test "errors if final type is 'array' when expecting type 'object' 1" {
	declare -a SUB_ARRAY=(omicron pi rho)
	declare -A OBJECT=([my_key]=$'\x1C\x1Dtype=array;&SUB_ARRAY')

	run bash_object.traverse get object OBJECT '.my_key'

	assert_failure
	assert_line -p "A query for type 'object' was given, but an array was found"
}

@test "errors if final type is 'array' when expecting type 'object' 2" {
	declare -a SUB_SUB_ARRAY=(omicron pi rho)
	declare -A SUB_OBJECT=([nested]=$'\x1C\x1Dtype=array;&SUB_SUB_ARRAY')
	declare -A OBJECT=([my_key]=$'\x1C\x1Dtype=array;&SUB_OBJECT')

	run bash_object.traverse get object OBJECT '.my_key.nested'

	assert_failure
	assert_line -p "A query for type 'object' was given, but an array was found"
}

# # { "stars": { "cool": "Wolf 359" } }
@test "properly gets 4" {
	declare -A inner_object=([cool]='Wolf 359')
	declare -A OBJ=([stars]=$'\x1C\x1Dtype=object;&inner_object')

	bash_object.traverse get object 'OBJ' '.stars'
	assert [ "${REPLY[cool]}" = 'Wolf 359' ]
}

# # { "stars": { "cool": "Wolf 359" } }
@test "properly gets 5" {
	declare -a inner_array=('Alpha Centauri A' 'Proxima Centauri')
	declare -A OBJ=([nearby]=$'\x1C\x1Dtype=object;&inner_array')

	bash_object.traverse get object 'OBJ' '.nearby'
	assert [ "${#REPLY[@]}" -eq 2 ]
	assert [ "${REPLY[0]}" = 'Alpha Centauri A' ]
	assert [ "${REPLY[1]}" = 'Proxima Centauri' ]
}
