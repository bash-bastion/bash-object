#!/usr/bin/env bash

load './util/init.sh'

@test "Simple errors on no starting dot 1" {
	run bash_object.parse_querytree --simple ''

	assert_failure
	assert_line -p "Querytree must begin with a dot"
}

@test "Simple errors on no starting dot 2" {
	run bash_object.parse_querytree --simple 'something.here'

	assert_failure
	assert_line -p "Querytree must begin with a dot"
}

@test "Simple succeeds on period" {
	bash_object.parse_querytree --simple '.'

	assert [ "${#REPLIES[@]}" -eq 0 ]
}

@test "Simple succeeds on key" {
	bash_object.parse_querytree --simple '.my_key'

	assert [ "${#REPLIES[@]}" -eq 1 ]
	assert [ "${REPLIES[0]}" = 'my_key' ]
}

@test "Simple succeeds on key and subkey" {
	bash_object.parse_querytree --simple '.my_key.sub_key'

	assert [ "${#REPLIES[@]}" -eq 2 ]
	assert [ "${REPLIES[0]}" = 'my_key' ]
	assert [ "${REPLIES[1]}" = 'sub_key' ]
}

@test "Simple succeeds on key with weird characters" {
	bash_object.parse_querytree --simple '.12fNe-	=='\\n'\+_m}\y.su/b []"_ke]y'\'

	assert [ "${#REPLIES[@]}" -eq 2 ]
	assert [ "${REPLIES[0]}" = '12fNe-	=='\\n'\+_m}\y' ]
	assert [ "${REPLIES[1]}" = 'su/b []"_ke]y'\' ]
}

@test "Simple succeeds on key with many periods" {
	bash_object.parse_querytree --simple '...lima...mike.....oscar'

	assert [ "${#REPLIES[@]}" -eq 3 ]
	assert [ "${REPLIES[0]}" = 'lima' ]
	assert [ "${REPLIES[1]}" = 'mike' ]
	assert [ "${REPLIES[2]}" = 'oscar' ]
}
