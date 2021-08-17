#!/usr/bin/env bats

load './util/init.sh'

@test "ERROR_VALUE_INCORRECT_TYPE on get-object'ing string" {
	declare -A OBJECT=([my_key]='string_value2')

	run bash_object.traverse-get object OBJECT '.my_key'

	assert_failure
	assert_line -p "ERROR_VALUE_INCORRECT_TYPE"
	assert_line -p 'Queried for object, but found existing string'
}

@test "ERROR_VALUE_INCORRECT_TYPE on get-object'ing string inside object" {
	declare -A SUB_OBJECT=([nested]='string_value')
	declare -A OBJECT=([my_key]=$'\x1C\x1Dtype=object;&SUB_OBJECT')

	run bash_object.traverse-get object OBJECT '.my_key.nested'

	assert_failure
	assert_line -p "ERROR_VALUE_INCORRECT_TYPE"
	assert_line -p 'Queried for object, but found existing string'
}

@test "ERROR_VALUE_INCORRECT_TYPE on get-object'ing array" {
	declare -a SUB_ARRAY=(omicron pi rho)
	declare -A OBJECT=([my_key]=$'\x1C\x1Dtype=array;&SUB_ARRAY')

	run bash_object.traverse-get object OBJECT '.my_key'

	assert_failure
	assert_line -p "ERROR_VALUE_INCORRECT_TYPE"
	assert_line -p 'Queried for object, but found existing array'
}

@test "ERROR_VALUE_INCORRECT_TYPE on get-object'ing array inside object" {
	declare -a SUB_SUB_ARRAY=(omicron pi rho)
	declare -A SUB_OBJECT=([nested]=$'\x1C\x1Dtype=array;&SUB_SUB_ARRAY')
	declare -A OBJECT=([my_key]=$'\x1C\x1Dtype=array;&SUB_OBJECT')

	run bash_object.traverse-get object OBJECT '.my_key.nested'

	assert_failure
	assert_line -p "ERROR_VALUE_INCORRECT_TYPE"
	assert_line -p 'Queried for object, but found existing array'
}

@test "correctly gets object" {
	declare -A inner_object=([cool]='Wolf 359')
	declare -A OBJ=([stars]=$'\x1C\x1Dtype=object;&inner_object')

	bash_object.traverse-get object 'OBJ' '.stars'
	assert [ "${REPLY[cool]}" = 'Wolf 359' ]

	bash_object.traverse-get string 'OBJ' '.stars.cool'
	assert [ "$REPLY" = 'Wolf 359' ]
}


@test "correctly gets object in subobject" {
	declare -A SUB_SUB_OBJECT=([omicron]='pi')
	declare -A SUB_OBJECT=([delta]=$'\x1C\x1Dtype=object;&SUB_SUB_OBJECT')
	declare -A OBJ=([gamma]=$'\x1C\x1Dtype=object;&SUB_OBJECT')

	bash_object.traverse-get object 'OBJ' '.gamma.delta'
	assert [ "${REPLY[omicron]}" = pi ]

	bash_object.traverse-get string 'OBJ' '.gamma.delta.omicron'
	assert [ "$REPLY" = pi ]
}

@test "correctly gets multi-key object in subobject" {
	declare -A SUB_SUB_OBJECT=([omicron]=pi [rho]=sigma [tau]=upsilon)
	declare -A SUB_OBJECT=([delta]=$'\x1C\x1Dtype=object;&SUB_SUB_OBJECT')
	declare -A OBJ=([gamma]=$'\x1C\x1Dtype=object;&SUB_OBJECT')

	bash_object.traverse-get object 'OBJ' '.gamma.delta'
	assert [ "${REPLY[omicron]}" = pi ]
	assert [ "${REPLY[rho]}" = sigma ]
	assert [ "${REPLY[tau]}" = upsilon ]

	bash_object.traverse-get string 'OBJ' '.gamma.delta.omicron'
	assert [ "$REPLY" = pi ]

	bash_object.traverse-get string 'OBJ' '.gamma.delta.rho'
	assert [ "$REPLY" = sigma ]

	bash_object.traverse-get string 'OBJ' '.gamma.delta.tau'
	assert [ "$REPLY" = upsilon ]
}

@test "correctly gets object in subarray" {
	declare -A SUB_SUB_OBJECT=([pi]='rho')
	declare -a SUB_ARRAY=('foo' 'bar' $'\x1C\x1Dtype=object;&SUB_SUB_OBJECT')
	declare -A OBJ=([omicron]=$'\x1C\x1Dtype=array;&SUB_ARRAY')

	bash_object.traverse-get object 'OBJ' '.["omicron"].[2]'
	assert [ "${REPLY[pi]}" = rho ]

	bash_object.traverse-get string 'OBJ' '.["omicron"].[2].["pi"]'
	assert [ "$REPLY" = rho ]
}
