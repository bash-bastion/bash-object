#!/usr/bin/env bats

load './util/init.sh'

@test "Correctly gets object" {
	declare -A inner_object=([cool]='Wolf 359')
	declare -A OBJ=([stars]=$'\x1C\x1Dtype=object;&inner_object')

	bobject set-object --value
	bobject get-object --value 'OBJ' '.stars'
	assert [ "${REPLY[cool]}" = 'Wolf 359' ]

	bobject get-string --value 'OBJ' '.stars.cool'
	assert [ "$REPLY" = 'Wolf 359' ]
}
