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

	assert [ "${#REPLY_QUERYTREE[@]}" -eq 0 ]
}

@test "Simple succeeds on key" {
	bash_object.parse_querytree --simple '.my_key'

	assert [ "${#REPLY_QUERYTREE[@]}" -eq 1 ]
	assert [ "${REPLY_QUERYTREE[0]}" = 'my_key' ]
}

@test "Simple succeeds on key and subkey" {
	bash_object.parse_querytree --simple '.my_key.sub_key'

	assert [ "${#REPLY_QUERYTREE[@]}" -eq 2 ]
	assert [ "${REPLY_QUERYTREE[0]}" = 'my_key' ]
	assert [ "${REPLY_QUERYTREE[1]}" = 'sub_key' ]
}

@test "Simple succeeds on key with weird characters" {
	bash_object.parse_querytree --simple '.12fNe-	=='\\n'\+_m}\y.su/b []"_ke]y'\'

	assert [ "${#REPLY_QUERYTREE[@]}" -eq 2 ]
	assert [ "${REPLY_QUERYTREE[0]}" = '12fNe-	=='\\n'\+_m}\y' ]
	assert [ "${REPLY_QUERYTREE[1]}" = 'su/b []"_ke]y'\' ]
}

@test "Simple succeeds on key with many periods" {
	bash_object.parse_querytree --simple '...lima...mike.....oscar'

	assert [ "${#REPLY_QUERYTREE[@]}" -eq 3 ]
	assert [ "${REPLY_QUERYTREE[0]}" = 'lima' ]
	assert [ "${REPLY_QUERYTREE[1]}" = 'mike' ]
	assert [ "${REPLY_QUERYTREE[2]}" = 'oscar' ]
}
