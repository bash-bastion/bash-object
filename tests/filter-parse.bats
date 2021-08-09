#!/usr/bin/env bats

load './util/init.sh'

@test "errors when simple does not begin with dot 1" {
	run bash_object.filter_parse -s ''

	assert_failure
	assert_line -p "Filter must begin with a dot"
}

@test "errors when simple does not begin with dot 2" {
	run bash_object.filter_parse -s 'something.here'

	assert_failure
	assert_line -p "Filter must begin with a dot"
}

@test "correctly parses simple period" {
	bash_object.filter_parse -s '.'

	assert [ "${#REPLIES[@]}" -eq 0 ]
}

@test "correctly parses simple 1" {
	bash_object.filter_parse -s '.my_key'

	assert [ "${#REPLIES[@]}" -eq 1 ]
	assert [ "${REPLIES[0]}" = 'my_key' ]
}

@test "correctly parses simple 2" {
	bash_object.filter_parse -s '.my_key.sub_key'

	assert [ "${#REPLIES[@]}" -eq 2 ]
	assert [ "${REPLIES[0]}" = 'my_key' ]
	assert [ "${REPLIES[1]}" = 'sub_key' ]
}

@test "correctly parses simple 3" {
	bash_object.filter_parse -s '.my_key.sub_key'

	assert [ "${#REPLIES[@]}" -eq 2 ]
	assert [ "${REPLIES[0]}" = 'my_key' ]
	assert [ "${REPLIES[1]}" = 'sub_key' ]
}

@test "correctly parses simple 4" {
	bash_object.filter_parse -s '.12fNe-	=='\\n'\+_m}\y.su/b []"_ke]y'\'

	assert [ "${#REPLIES[@]}" -eq 2 ]
	assert [ "${REPLIES[0]}" = '12fNe-	=='\\n'\+_m}\y' ]
	assert [ "${REPLIES[1]}" = 'su/b []"_ke]y'\' ]
}

@test "errors when advanced does not begin with dot 1" {
	run bash_object.filter_parse -s ''

	assert_failure
	assert_line -p "Filter must begin with a dot"
}

@test "errors when advanced does not begin with dot 2" {
	run bash_object.filter_parse -s 'something.here'

	assert_failure
	assert_line -p "Filter must begin with a dot"
}

@test "correctly parses advanced 1" {
	bash_object.filter_parse -a '.["one"]'

	assert [ "${#REPLIES[@]}" -eq 1 ]
	assert [ "${REPLIES[0]}" = 'one' ]
}

@test "errors when no dot present" {
	run bash_object.filter_parse -a '.["one"]["two"]'

	assert_failure
	assert_line -p "Each part in a filter must be deliminated by a dot"
}

@test "correctly parses advanced 2" {
	bash_object.filter_parse -a '.["esca\\p\"\]e"]'

	assert [ "${#REPLIES[@]}" -eq 1 ]
	assert [ "${REPLIES[0]}" = 'esca\p"]e' ]
}

@test "correctly parses advanced 2.5" {
	bash_object.filter_parse -a '.["aone"].["atwo"]'

	assert [ "${#REPLIES[@]}" -eq 2 ]
	assert [ "${REPLIES[0]}" = 'aone' ]
	assert [ "${REPLIES[1]}" = 'atwo' ]
}

@test "correctly parses advanced 3" {
	bash_object.filter_parse -a '.[3]'

	assert [ "${#REPLIES[@]}" -eq 1 ]
	assert [ "${REPLIES[0]}" = $'\x1C3' ]
}

@test "correctly parses advanced 4" {
	bash_object.filter_parse -a '.[341]'

	assert [ "${#REPLIES[@]}" -eq 1 ]
	assert [ "${REPLIES[0]}" = $'\x1C341' ]
}

# @test "correctly parses advanced 5" {
# 	bash_object.filter_parse -a '.[341].[7]'

# 	assert [ "${#REPLIES[@]}" -eq 2 ]
# 	assert [ "${REPLIES[0]}" = $'\x1C341' ]
# 	assert [ "${REPLIES[0]}" = $'\x1C7' ]
# }

# @test "correctly parses advanced 5" {
# 	bash_object.filter_parse -a '.[3].["subprop"]'

# 	assert [ "${#REPLIES[@]}" -eq 2 ]
# 	assert [ "${REPLIES[0]}" = $'\x1C3' ]
# 	assert [ "${REPLIES[1]}" = 'subprop' ]
# }
