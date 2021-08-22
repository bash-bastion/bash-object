#!/usr/bin/env bats

load './util/init.sh'

@test "Advanced errors with no start dot 1" {
	run bash_object.parse_querytree --simple ''

	assert_failure
	assert_line -p "Querytree must begin with a dot"
}

@test "Advanced errors with no start dot 2" {
	run bash_object.parse_querytree --advanced '["sub"]'

	assert_failure
	assert_line -p "Querytree must begin with a dot"
}

@test "Advanced errors with missing dot" {
	run bash_object.parse_querytree --advanced '.["one"]["two"]'

	assert_failure
	assert_line -p "Each part in a querytree must be deliminated by a dot"
}

@test "Advanced errors with trailing dot" {
	run bash_object.parse_querytree --advanced '.["one"].["ab"].'

	assert_failure
	assert_line -p "A dot MUST be followed by an opening bracket"
}

@test "Advanced errors with trailing double dot" {
	run bash_object.parse_querytree --advanced '.["one"].["ab"]..'

	assert_failure
	assert_line -p "A dot MUST be followed by an opening bracket"
}

@test "Advanced errors on incomplete 1" {
	run bash_object.parse_querytree --advanced '.['

	assert_failure
	assert_line -p "A number or opening quote must follow an open bracket"
}

@test "Advanced errors on incomplete 2" {
	run bash_object.parse_querytree --advanced '.["'

	assert_failure
	assert_line -p "Querytree is not complete"
}

@test "Advanced errors on incomplete 3" {
	run bash_object.parse_querytree --advanced '.[""'

	assert_failure
	assert_line -p "Key cannot be empty"
}

@test "Advanced errors on incomplete 4" {
	run bash_object.parse_querytree --advanced '.["bottom"].["'

	assert_failure
	assert_line -p "Querytree is not complete"
}

@test "Advanced errors on incomplete 5" {
	run bash_object.parse_querytree --advanced '.["top"].[""'

	assert_failure
	assert_line -p "Key cannot be empty"
}

@test "Advanced errors on empty key" {
	run bash_object.parse_querytree --advanced '.[""]'

	assert_failure
	assert_line -p "Key cannot be empty"
}

@test "Advanced errors on empty key as subkey" {
	run bash_object.parse_querytree --advanced '.["subkey"].[""]'

	assert_failure
	assert_line -p "Key cannot be empty"
}

@test "Advanced errors on empty number key" {
	run bash_object.parse_querytree --advanced '.[]'

	assert_failure
	assert_line -p "Key cannot be empty"
}

@test "Advanced errors on empty key as number subkey" {
	run bash_object.parse_querytree --advanced '.["subkey"].[]'

	assert_failure
	assert_line -p "Key cannot be empty"
}

@test "Correctly parses advanced prop" {
	bash_object.parse_querytree --advanced '.["one"]'

	assert [ "${#REPLIES[@]}" -eq 1 ]
	assert [ "${REPLIES[0]}" = 'one' ]
}

@test "Correctly parses advanced prop and escape sequence" {
	bash_object.parse_querytree --advanced '.["esca\\p\"\]e"]'

	assert [ "${#REPLIES[@]}" -eq 1 ]
	assert [ "${REPLIES[0]}" = 'esca\p"]e' ]
}

@test "Correctly parses advanced double prop" {
	bash_object.parse_querytree --advanced '.["aone"].["a\\two"]'

	assert [ "${#REPLIES[@]}" -eq 2 ]
	assert [ "${REPLIES[0]}" = 'aone' ]
	assert [ "${REPLIES[1]}" = 'a\two' ]
}

@test "Correctly parses advanced number single" {
	bash_object.parse_querytree --advanced '.[3]'

	assert [ "${#REPLIES[@]}" -eq 1 ]
	assert [ "${REPLIES[0]}" = $'\x1C3' ]
}

@test "Correctly parses advanced number" {
	bash_object.parse_querytree --advanced '.[341]'

	assert [ "${#REPLIES[@]}" -eq 1 ]
	assert [ "${REPLIES[0]}" = $'\x1C341' ]
}

@test "Correctly parses advanced number nested" {
	bash_object.parse_querytree --advanced '.[341].[7]'

	assert [ "${#REPLIES[@]}" -eq 2 ]
	assert [ "${REPLIES[0]}" = $'\x1C341' ]
	assert [ "${REPLIES[1]}" = $'\x1C7' ]
}

@test "Correctly parses advanced number then string" {
	bash_object.parse_querytree --advanced '.[3].["subprop"]'

	assert [ "${#REPLIES[@]}" -eq 2 ]
	assert [ "${REPLIES[0]}" = $'\x1C3' ]
	assert [ "${REPLIES[1]}" = 'subprop' ]
}

@test "Correctly parses advanced string then number" {
	bash_object.parse_querytree --advanced '.["subprop"].[9]'

	assert [ "${#REPLIES[@]}" -eq 2 ]
	assert [ "${REPLIES[0]}" = 'subprop' ]
	assert [ "${REPLIES[1]}" = $'\x1C9' ]
}
