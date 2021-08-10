#!/usr/bin/env bats

load './util/init.sh'

@test "get-string" {
	declare -A OBJ=()

	bobject set-string 'OBJ' '.zulu.yankee' 'MEOW'
	bobject get-string 'OBJ' '.zulu.yankee'

	assert [ "$REPLY" = 'MEOW' ]
}
