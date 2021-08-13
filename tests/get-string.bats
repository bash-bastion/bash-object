#!/usr/bin/env bats

load './util/init.sh'

@test "ERROR_VALUE_INCORRECT_TYPE on get-string'ing object" {
	declare -A SUB_OBJECT=([omicron]='pi')
	declare -A OBJECT=([my_key]=$'\x1C\x1Dtype=object;&SUB_OBJECT')

	run bash_object.traverse-get string OBJECT '.my_key'

	assert_failure
	assert_line -p "ERROR_VALUE_INCORRECT_TYPE"
	assert_line -p 'Queried for string, but found object'
}

@test "ERROR_VALUE_INCORRECT_TYPE on get-string'ing object in object" {
	declare -A SUB_SUB_OBJECT=([omicron]='pi')
	declare -A SUB_OBJECT=([nested]=$'\x1C\x1Dtype=object;&SUB_SUB_OBJECT')
	declare -A OBJECT=([my_key]=$'\x1C\x1Dtype=object;&SUB_OBJECT')

	run bash_object.traverse-get string OBJECT '.my_key.nested'

	assert_failure
	assert_line -p "ERROR_VALUE_INCORRECT_TYPE"
	assert_line -p 'Queried for string, but found object'
}

@test "ERROR_VALUE_INCORRECT_TYPE on get-string'ing array" {
	declare -a SUB_ARRAY=(omicron pi rho)
	declare -A OBJECT=([my_key]=$'\x1C\x1Dtype=array;&SUB_ARRAY')

	run bash_object.traverse-get string OBJECT '.my_key'

	assert_failure
	assert_line -p "ERROR_VALUE_INCORRECT_TYPE"
	assert_line -p 'Queried for string, but found array'
}

@test "ERROR_VALUE_INCORRECT_TYPE on get-string'ing array in object" {
	declare -a SUB_SUB_ARRAY=(omicron pi rho)
	declare -A SUB_OBJECT=([nested]=$'\x1C\x1Dtype=array;&SUB_SUB_ARRAY')
	declare -A OBJECT=([my_key]=$'\x1C\x1Dtype=array;&SUB_OBJECT')

	run bash_object.traverse-get string OBJECT '.my_key.nested'

	assert_failure
	assert_line -p "ERROR_VALUE_INCORRECT_TYPE"
	assert_line -p 'Queried for string, but found array'
}

@test "properly gets string in root" {
	declare -A OBJECT=([my_key]='my_value')

	bash_object.traverse-get string OBJECT '.my_key'
	assert [ "$REPLY" = 'my_value' ]
}

@test "properly gets string in nested object" {
	declare -A EPSILON_OBJECT=([my_key]='my_value2')
	declare -A OBJECT=([epsilon]=$'\x1C\x1Dtype=object;&EPSILON_OBJECT')

	bash_object.traverse-get string OBJECT '.epsilon.my_key'
	assert [ "$REPLY" = 'my_value2' ]
}

# { "stars": { "cool": "Wolf 359" } }
@test "properly gets string in nested object 2" {
	declare -A inner_object=([cool]='Wolf 359')
	declare -A OBJ=([stars]=$'\x1C\x1Dtype=object;&inner_object')

	bash_object.traverse-get string 'OBJ' '.stars.cool'
	assert [ "$REPLY" = 'Wolf 359' ]
}

# # { "alfa": { "bravo": { "charlie": { "delta": { "echo": "final_value" } } } } }
@test "properly gets string in nested object 3" {
	declare -A obj_delta=([echo]="final_value")
	declare -A obj_charlie=([delta]=$'\x1C\x1Dtype=object;&obj_delta')
	declare -A obj_bravo=([charlie]=$'\x1C\x1Dtype=object;&obj_charlie')
	declare -A obj_alfa=([bravo]=$'\x1C\x1Dtype=object;&obj_bravo')
	declare -A OBJ=([alfa]=$'\x1C\x1Dtype=object;&obj_alfa')

	bash_object.traverse-get string 'OBJ' '.alfa.bravo.charlie.delta.echo'
	assert [ "$REPLY" = 'final_value' ]
}
