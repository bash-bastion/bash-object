#!/usr/bin/env bash

load './util/init.sh'

@test "simple errors on no starting dot 1" {
	run bash_object.parse_filter -s ''

	assert_failure
	assert_line -p "Filter must begin with a dot"
}

@test "simple errors on no starting dot 2" {
	run bash_object.parse_filter -s 'something.here'

	assert_failure
	assert_line -p "Filter must begin with a dot"
}

@test "simple succeeds on period" {
	bash_object.parse_filter -s '.'

	assert [ "${#REPLIES[@]}" -eq 0 ]
}

@test "simple succeeds on key" {
	bash_object.parse_filter -s '.my_key'

	assert [ "${#REPLIES[@]}" -eq 1 ]
	assert [ "${REPLIES[0]}" = 'my_key' ]
}

@test "simple succeeds on key and subkey" {
	bash_object.parse_filter -s '.my_key.sub_key'

	assert [ "${#REPLIES[@]}" -eq 2 ]
	assert [ "${REPLIES[0]}" = 'my_key' ]
	assert [ "${REPLIES[1]}" = 'sub_key' ]
}

@test "simple succeeds on key with weird characters" {
	bash_object.parse_filter -s '.12fNe-	=='\\n'\+_m}\y.su/b []"_ke]y'\'

	assert [ "${#REPLIES[@]}" -eq 2 ]
	assert [ "${REPLIES[0]}" = '12fNe-	=='\\n'\+_m}\y' ]
	assert [ "${REPLIES[1]}" = 'su/b []"_ke]y'\' ]
}

@test "simple succeeds on key with many periods" {
	bash_object.parse_filter -s '...lima...mike.....oscar'

	assert [ "${#REPLIES[@]}" -eq 3 ]
	assert [ "${REPLIES[0]}" = 'lima' ]
	assert [ "${REPLIES[1]}" = 'mike' ]
	assert [ "${REPLIES[2]}" = 'oscar' ]
}
