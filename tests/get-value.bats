#!/usr/bin/env bats

load './util/init.sh'

@test "Correctly get-object --value" {
	declare -A OBJECT=()
	declare -A obj=([upsilon]=phi [alfa]=beta)

	bobject set-object --ref 'OBJECT' '.obj' obj
	bobject get-object --value 'OBJECT' '.obj'
	assert [ "${REPLY[upsilon]}" = phi ]
	assert [ "${REPLY[alfa]}" = beta ]

	REPLY[upsilon]=omega

	bobject get-object --value 'OBJECT' '.obj'
	assert [ "${REPLY[upsilon]}" = phi ]
}

@test "Correctly get-array --value" {
	declare -A OBJECT=()
	declare -a arr=(seven eight nine ten)

	bobject set-array --ref 'OBJECT' '.obj' arr
	bobject get-array --value 'OBJECT' '.obj'
	assert [ "${REPLY[1]}" = eight ]
	assert [ "${REPLY[2]}" = nine ]

	REPLY[2]=thousand

	bobject get-array --value 'OBJECT' '.obj'
	assert [ "${REPLY[2]}" = nine ]
}

@test "Correctly get-string --value" {
	declare -A OBJECT=()
	str='woof'

	bobject set-string --ref 'OBJECT' '.obj' str

	bobject get-string --value 'OBJECT' '.obj'
	assert [ "$REPLY" = woof ]

	REPLY='meow'

	bobject get-string --value 'OBJECT' '.obj'
	assert [ "$REPLY" = woof ]
}
