#!/usr/bin/env bats

load './util/init.sh'

# object
@test "Correctly errors when indexing an object with an integer (get)" {
	declare -A OBJECT=()

	bobject set-object --value 'OBJECT' '.uwu' -- one two three four

	run bobject get-string --value 'OBJECT' '.["uwu"].[3]'
	assert_failure
	assert_line -p "ERROR_ARGUMENTS_INCORRECT_TYPE"
	assert_line -p "Cannot index an object with an integer"
}

@test "Correctly errors when indexing an object with an integer (set)" {
	declare -A OBJECT=()

	bobject set-object --value 'OBJECT' '.uwu' -- one two three four

	run bobject set-string --value 'OBJECT' '.["uwu"].[3]' -- value
	assert_failure
	assert_line -p "ERROR_ARGUMENTS_INCORRECT_TYPE"
	assert_line -p "Cannot index an object with an integer"
}

# array
@test "Correctly errors when indexing an array with a non-integer (get)" {
	declare -A OBJECT=()

	bobject set-array --value 'OBJECT' '.uwu' -- one two three

	run bobject get-string --value 'OBJECT' '.["uwu"].["f"]'
	assert_failure
	assert_line -p "ERROR_ARGUMENTS_INCORRECT_TYPE"
	assert_line -p "Cannot index an array with a non-integer"
}

@test "Correctly errors when indexing an array with a non-integer (set)" {
	declare -A OBJECT=()

	bobject set-array --value 'OBJECT' '.uwu' -- one two three

	run bobject set-string --value 'OBJECT' '.["uwu"].["f"]' -- value
	assert_failure
	assert_line -p "ERROR_ARGUMENTS_INCORRECT_TYPE"
	assert_line -p "Cannot index an array with a non-integer"
}

# misc
@test "Correctly indexes an object with a number string" {
	declare -A OBJECT=()

	bobject set-object --value 'OBJECT' '.["2"]' -- keyy valuee a b
	bobject set-array --value 'OBJECT' '.["3"]' -- one two three
	bobject set-string --value 'OBJECT' '.["4"]' -- zeta

	bobject get-object --value 'OBJECT' '.["2"]'
	local keys=("${!REPLY[@]}")
	assert [ "${#REPLY[@]}" = 2 ]
	assert [ "${keys[0]}" = 'keyy' ]
	assert [ "${keys[1]}" = 'a' ]

	bobject get-array --value 'OBJECT' '.["3"]'
	assert [ ${#REPLY[@]} -eq 3 ]

	bobject get-string --value 'OBJECT' '.["3"].[0]'
	assert [ "$REPLY" = 'one' ]

	bobject get-string --value 'OBJECT' '.["4"]'
	assert [ "$REPLY" = 'zeta' ]
}
