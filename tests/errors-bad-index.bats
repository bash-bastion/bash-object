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
