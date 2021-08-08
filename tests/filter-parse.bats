#!/usr/bin/env bats

load './util/init.sh'

@test "properly parses 1" {
	bash_object.filter_parse '.'

	assert [ "${#REPLIES[@]}" -eq 0 ]
}

@test "properly parses 2" {
	bash_object.filter_parse '.my_key'

	assert [ "${#REPLIES[@]}" -eq 1 ]
	assert [ "${REPLIES[0]}" = 'my_key' ]
}

@test "properly parses 3" {
	bash_object.filter_parse '.my_key.sub_key'

	assert [ "${#REPLIES[@]}" -eq 2 ]
	assert [ "${REPLIES[0]}" = 'my_key' ]
	assert [ "${REPLIES[1]}" = 'sub_key' ]
}
