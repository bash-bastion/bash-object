#!/usr/bin/env bats

load './util/init.sh'

# object
@test "Corretly get-object --value" {
	declare -A OBJECT=()

	bobject set-object --value 'OBJECT' '.uwu' -- keyy valuee

	bobject get-string --value 'OBJECT' '.uwu.keyy'
	assert [ "$REPLY" = 'valuee' ]
}

# array
@test "Correctly set-array --value" {
	declare -A OBJECT=()

	bobject set-array --value 'OBJECT' '.uwu' -- one two three

	bobject get-array --value 'OBJECT' '.uwu'
	assert [ "${#REPLY[@]}" -eq 3 ]
	assert [ "${REPLY[0]}" = one ]
	assert [ "${REPLY[1]}" = two ]
	assert [ "${REPLY[2]}" = three ]
}

# string
@test "Correctly set-string --value" {
	declare -A OBJECT=()

	bobject set-string --value 'OBJECT' '.uwu' -- content

	bobject get-string --value 'OBJECT' '.uwu'
	assert [ "$REPLY" = content ]
}
