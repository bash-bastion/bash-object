#!/usr/bin/env bats

load './util/init.sh'

# object
@test "Correctly set-object --ref" {
	declare -A obj=([omicron]=pi [rho]=sigma [tau]=upsilon)
	declare -A OBJECT=()

	bobject set-object --ref 'OBJECT' '.obj' obj

	bobject get-object --value 'OBJECT' '.obj'
	assert [ ${#REPLY[@]} -eq 3 ]
	assert [ "${REPLY[omicron]}" = pi ]
	assert [ "${REPLY[rho]}" = sigma ]
	assert [ "${REPLY[tau]}" = upsilon ]

	bobject get-string --value 'OBJECT' '.obj.rho'
	assert [ "$REPLY" = sigma ]
}

# array
@test "Correctly set-array --ref" {
	declare -a arr=(omicron pi rho)
	declare -A OBJECT=()

	bobject set-array --ref 'OBJECT' '.arr' arr

	bobject get-array --value 'OBJECT' '.arr'
	assert [ ${#REPLY[@]} -eq 3 ]
	assert [ "${REPLY[0]}" = omicron ]
	assert [ "${REPLY[1]}" = pi ]
	assert [ "${REPLY[2]}" = rho ]

	bobject get-string --value 'OBJECT' '.["arr"].[0]'
	assert [ "$REPLY" = omicron ]

	bobject get-string --value 'OBJECT' '.["arr"].[1]'
	assert [ "$REPLY" = pi ]

	bobject get-string --value 'OBJECT' '.["arr"].[2]'
	assert [ "$REPLY" = rho ]
}

# string
@test "Correctly set-string --ref" {
	declare -A OBJECT=()
	str=content

	bobject set-string --ref 'OBJECT' '.uwu' str

	bobject get-string --value 'OBJECT' '.uwu'
	assert [ "$REPLY" = content ]
}
