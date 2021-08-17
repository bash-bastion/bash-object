#!/usr/bin/env bats

load './util/init.sh'

@test "advanced errors with no start dot 1" {
	run bash_object.parse_filter -s ''

	assert_failure
	assert_line -p "Filter must begin with a dot"
}

@test "advanced errors with no start dot 2" {
	run bash_object.parse_filter -a '["sub"]'

	assert_failure
	assert_line -p "Filter must begin with a dot"
}

@test "advanced errors with missing dot" {
	run bash_object.parse_filter -a '.["one"]["two"]'

	assert_failure
	assert_line -p "Each part in a filter must be deliminated by a dot"
}

@test "advanced errors with trailing dot" {
	run bash_object.parse_filter -a '.["one"].["ab"].'

	assert_failure
	assert_line -p "A dot MUST be followed by an opening bracket"
}

@test "advanced errors with trailing double dot" {
	run bash_object.parse_filter -a '.["one"].["ab"]..'

	assert_failure
	assert_line -p "A dot MUST be followed by an opening bracket"
}

@test "advanced errors on incomplete 1" {
	run bash_object.parse_filter -a '.['

	assert_failure
	assert_line -p "A number or opening quote must follow an open bracket"
}

@test "advanced errors on incomplete 2" {
	run bash_object.parse_filter -a '.["'

	assert_failure
	assert_line -p "Filter is not complete"
}

@test "advanced errors on incomplete 3" {
	run bash_object.parse_filter -a '.[""'

	assert_failure
	assert_line -p "Key cannot be empty"
}

@test "advanced errors on incomplete 4" {
	run bash_object.parse_filter -a '.["bottom"].["'

	assert_failure
	assert_line -p "Filter is not complete"
}

@test "advanced errors on incomplete 5" {
	run bash_object.parse_filter -a '.["top"].[""'

	assert_failure
	assert_line -p "Key cannot be empty"
}

@test "advanced errors on empty key" {
	run bash_object.parse_filter -a '.[""]'

	assert_failure
	assert_line -p "Key cannot be empty"
}

@test "advanced errors on empty key as subkey" {
	run bash_object.parse_filter -a '.["subkey"].[""]'

	assert_failure
	assert_line -p "Key cannot be empty"
}

@test "advanced errors on empty number key" {
	run bash_object.parse_filter -a '.[]'

	assert_failure
	assert_line -p "Key cannot be empty"
}

@test "advanced errors on empty key as number subkey" {
	run bash_object.parse_filter -a '.["subkey"].[]'

	assert_failure
	assert_line -p "Key cannot be empty"
}

@test "correctly parses advanced prop" {
	bash_object.parse_filter -a '.["one"]'

	assert [ "${#REPLIES[@]}" -eq 1 ]
	assert [ "${REPLIES[0]}" = 'one' ]
}

@test "correctly parses advanced prop and escape sequence" {
	bash_object.parse_filter -a '.["esca\\p\"\]e"]'

	assert [ "${#REPLIES[@]}" -eq 1 ]
	assert [ "${REPLIES[0]}" = 'esca\p"]e' ]
}

@test "correctly parses advanced double prop" {
	bash_object.parse_filter -a '.["aone"].["a\\two"]'

	assert [ "${#REPLIES[@]}" -eq 2 ]
	assert [ "${REPLIES[0]}" = 'aone' ]
	assert [ "${REPLIES[1]}" = 'a\two' ]
}

@test "correctly parses advanced number single" {
	bash_object.parse_filter -a '.[3]'

	assert [ "${#REPLIES[@]}" -eq 1 ]
	assert [ "${REPLIES[0]}" = $'\x1C3' ]
}

@test "correctly parses advanced number" {
	bash_object.parse_filter -a '.[341]'

	assert [ "${#REPLIES[@]}" -eq 1 ]
	assert [ "${REPLIES[0]}" = $'\x1C341' ]
}

@test "correctly parses advanced number nested" {
	bash_object.parse_filter -a '.[341].[7]'

	assert [ "${#REPLIES[@]}" -eq 2 ]
	assert [ "${REPLIES[0]}" = $'\x1C341' ]
	assert [ "${REPLIES[1]}" = $'\x1C7' ]
}

@test "correctly parses advanced number then string" {
	bash_object.parse_filter -a '.[3].["subprop"]'

	assert [ "${#REPLIES[@]}" -eq 2 ]
	assert [ "${REPLIES[0]}" = $'\x1C3' ]
	assert [ "${REPLIES[1]}" = 'subprop' ]
}

@test "correctly parses advanced string then number" {
	bash_object.parse_filter -a '.["subprop"].[9]'

	assert [ "${#REPLIES[@]}" -eq 2 ]
	assert [ "${REPLIES[0]}" = 'subprop' ]
	assert [ "${REPLIES[1]}" = $'\x1C9' ]
}
