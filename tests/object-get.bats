#!/usr/bin/env bats

load './util/init.sh'

@test "properly gets top level string" {
	declare -A OBJ=([my_key]='my_value')

	bash_object.do-object-get 'OBJ' '.my_key'
	assert [ "$REPLY" = 'my_value' ]
}

@test "properly gets top level array" {
	declare -a global_aa_1=([cat_goes]='WOOF')
	declare -A OBJ=([my_key]='my_value')

	bash_object.do-object-get 'OBJ' '.my_key'
	assert [ "$REPLY" = 'my_value' ]
}

@test "properly gets 2" {
	declare -A global_aa_1=([cat_goes]='WOOF')
	declare -A OBJ=([my_pet]=$'\x1C\x1Dtype=object;&global_aa_1')

	bash_object.do-object-get 'OBJ' '.my_pet.cat_goes'
	assert [ "$REPLY" = 'WOOF' ]
}

# { "stars": { "cool": "Wolf 359" } }
@test "properly gets 3" {
	declare -A inner_object=([cool]='Wolf 359')
	declare -A OBJ=([stars]=$'\x1C\x1Dtype=object;&inner_object')

	bash_object.do-object-get 'OBJ' '.stars.cool'
	assert [ "$REPLY" = 'Wolf 359' ]
}

# # { "stars": { "cool": "Wolf 359" } }
@test "properly gets 4" {
	declare -A inner_object=([cool]='Wolf 359')
	declare -A OBJ=([stars]=$'\x1C\x1Dtype=object;&inner_object')

	bash_object.do-object-get 'OBJ' '.stars'
	assert [ "${REPLY[cool]}" = 'Wolf 359' ]
}

# # { "stars": { "cool": "Wolf 359" } }
@test "properly gets 5" {
	# TODO: remove 'type=string' from tests
	declare -a inner_array=('Alpha Centauri A' 'Proxima Centauri')
	declare -A OBJ=([nearby]=$'\x1C\x1Dtype=object;&inner_array')

	bash_object.do-object-get 'OBJ' '.nearby'
	assert [ "${#REPLY[@]}" -eq 2 ]
	assert [ "${REPLY[0]}" = 'Alpha Centauri A' ]
	assert [ "${REPLY[1]}" = 'Proxima Centauri' ]
}

# # { "alfa": { "bravo": { "charlie": { "delta": { "echo": "final_value" } } } } }
@test "properly gets 6" {
	declare -A obj_echo=([echo]="final_value")
	declare -A obj_delta=([delta]=$'\x1C\x1Dtype=object;&obj_echo')
	declare -A obj_charlie=([charlie]=$'\x1C\x1Dtype=object;&obj_delta')
	declare -A obj_bravo=([bravo]=$'\x1C\x1Dtype=object;&obj_charlie')
	declare -A OBJ=([alfa]=$'\x1C\x1Dtype=object;&obj_bravo')

	bash_object.do-object-get 'OBJ' '.alfa.bravo.charlie.delta.echo'
	assert [ "$REPLY" = 'final_value' ]
}
