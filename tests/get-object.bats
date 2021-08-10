#!/usr/bin/env bats

load './util/init.sh'

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
