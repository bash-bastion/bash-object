#!/usr/bin/env bats

# @brief These were the initial tests for 'get-object', 'get-array', and
# 'get-string' before their respective 'set' functions were implemented.
# With the 'set' functions working, future tests should use them to keep
# things clean

load './util/init.sh'

# object
@test "Correctly gets object" {
	declare -A inner_object=([cool]='Wolf 359')
	declare -A OBJ=([stars]=$'\x1C\x1Dtype=object;&inner_object')

	bobject get-object --as-value 'OBJ' '.stars'
	assert [ "${REPLY[cool]}" = 'Wolf 359' ]

	bobject get-string --as-value 'OBJ' '.stars.cool'
	assert [ "$REPLY" = 'Wolf 359' ]
}

@test "Correctly gets object in subobject" {
	declare -A SUB_SUB_OBJECT=([omicron]='pi')
	declare -A SUB_OBJECT=([delta]=$'\x1C\x1Dtype=object;&SUB_SUB_OBJECT')
	declare -A OBJ=([gamma]=$'\x1C\x1Dtype=object;&SUB_OBJECT')

	bobject get-object --as-value 'OBJ' '.gamma.delta'
	assert [ "${REPLY[omicron]}" = pi ]

	bobject get-string --as-value 'OBJ' '.gamma.delta.omicron'
	assert [ "$REPLY" = pi ]
}

@test "Correctly gets multi-key object in subobject" {
	declare -A SUB_SUB_OBJECT=([omicron]=pi [rho]=sigma [tau]=upsilon)
	declare -A SUB_OBJECT=([delta]=$'\x1C\x1Dtype=object;&SUB_SUB_OBJECT')
	declare -A OBJ=([gamma]=$'\x1C\x1Dtype=object;&SUB_OBJECT')

	bobject get-object --as-value 'OBJ' '.gamma.delta'
	assert [ "${REPLY[omicron]}" = pi ]
	assert [ "${REPLY[rho]}" = sigma ]
	assert [ "${REPLY[tau]}" = upsilon ]

	bobject get-string --as-value 'OBJ' '.gamma.delta.omicron'
	assert [ "$REPLY" = pi ]

	bobject get-string --as-value 'OBJ' '.gamma.delta.rho'
	assert [ "$REPLY" = sigma ]

	bobject get-string --as-value 'OBJ' '.gamma.delta.tau'
	assert [ "$REPLY" = upsilon ]
}

@test "Correctly gets object in subarray" {
	declare -A SUB_SUB_OBJECT=([pi]='rho')
	declare -a SUB_ARRAY=('foo' 'bar' $'\x1C\x1Dtype=object;&SUB_SUB_OBJECT')
	declare -A OBJ=([omicron]=$'\x1C\x1Dtype=array;&SUB_ARRAY')

	bobject get-object --as-value 'OBJ' '.["omicron"].[2]'
	assert [ "${REPLY[pi]}" = rho ]

	bobject get-string --as-value 'OBJ' '.["omicron"].[2].["pi"]'
	assert [ "$REPLY" = rho ]
}

# array
@test "Correctly gets array" {
	declare -a SUB_ARRAY=(omicron pi rho)
	declare -A OBJECT=([my_key]=$'\x1C\x1Dtype=array;&SUB_ARRAY')

	bobject get-array --as-value OBJECT '.my_key'
	assert [ ${#REPLY[@]} -eq 3 ]
	assert [ "${REPLY[0]}" = omicron ]
	assert [ "${REPLY[1]}" = pi ]
	assert [ "${REPLY[2]}" = rho ]

	bobject get-string --as-value OBJECT '.["my_key"].[2]'
	assert [ "$REPLY" = rho ]
}

@test "Correctly gets array in subobject" {
	declare -a SUB_SUB_ARRAY=(pi rho sigma)
	declare -A SUB_OBJECT=([subkey]=$'\x1C\x1Dtype=array;&SUB_SUB_ARRAY')
	declare -A OBJECT=([my_key]=$'\x1C\x1Dtype=object;&SUB_OBJECT')

	bobject get-array --as-value OBJECT '.my_key.subkey'
	assert [ ${#REPLY[@]} -eq 3 ]
	assert [ "${REPLY[0]}" = pi ]
	assert [ "${REPLY[1]}" = rho ]
	assert [ "${REPLY[2]}" = sigma ]

	bobject get-string --as-value OBJECT '.["my_key"].["subkey"].[2]'
	assert [ "$REPLY" = sigma ]
}

@test "Correctly gets array in subarray" {
	declare -a SUB_SUB_ARRAY=(omicron pi rho)
	declare -a SUB_ARRAY=('foo' 'bar' $'\x1C\x1Dtype=array;&SUB_SUB_ARRAY')
	declare -A OBJECT=([my_key]=$'\x1C\x1Dtype=array;&SUB_ARRAY')

	bobject get-array --as-value OBJECT '.["my_key"].[2]'
	assert [ ${#REPLY[@]} -eq 3 ]
	assert [ "${REPLY[0]}" = omicron ]
	assert [ "${REPLY[1]}" = pi ]
	assert [ "${REPLY[2]}" = rho ]


	bobject get-string --as-value OBJECT '.["my_key"].[2].[0]'
	assert [ "$REPLY" = omicron ]
}

@test "Correctly gets string at root" {
	declare -A OBJECT=([my_key]='my_value')

	bobject get-string --as-value OBJECT '.my_key'
	assert [ "$REPLY" = 'my_value' ]
}

@test "Correctly gets string" {
	declare -A EPSILON_OBJECT=([my_key]='my_value2')
	declare -A OBJECT=([epsilon]=$'\x1C\x1Dtype=object;&EPSILON_OBJECT')

	bobject get-string --as-value OBJECT '.epsilon.my_key'
	assert [ "$REPLY" = 'my_value2' ]
}

@test "Correctly gets string in subobject" {
	declare -A obj_bravo=([charlie]=delta)
	declare -A obj_alfa=([bravo]=$'\x1C\x1Dtype=object;&obj_bravo')
	declare -A OBJ=([alfa]=$'\x1C\x1Dtype=object;&obj_alfa')

	bobject get-object --as-value 'OBJ' '.alfa.bravo'
	assert [ "${REPLY[charlie]}" = 'delta' ]

	bobject get-string --as-value 'OBJ' '.alfa.bravo.charlie'
	assert [ "$REPLY" = 'delta' ]
}

@test "Correctly gets string in subobject highly nested" {
	declare -A obj_delta=([echo]="final_value")
	declare -A obj_charlie=([delta]=$'\x1C\x1Dtype=object;&obj_delta')
	declare -A obj_bravo=([charlie]=$'\x1C\x1Dtype=object;&obj_charlie')
	declare -A obj_alfa=([bravo]=$'\x1C\x1Dtype=object;&obj_bravo')
	declare -A OBJ=([alfa]=$'\x1C\x1Dtype=object;&obj_alfa')

	bobject get-object --as-value 'OBJ' '.alfa.bravo.charlie.delta'
	assert [ "${REPLY[echo]}" = 'final_value' ]

	bobject get-string --as-value 'OBJ' '.alfa.bravo.charlie.delta.echo'
	assert [ "$REPLY" = 'final_value' ]
}
