#!/usr/bin/env bats

load './util/init.sh'

@test "Correctly sets object" {
	declare -A obj=([omicron]=pi [rho]=sigma [tau]=upsilon)
	declare -A OBJECT=()

	bobject set-object --by-ref 'OBJECT' '.obj' obj

	bobject get-object 'OBJECT' '.obj'
	assert [ ${#REPLY[@]} -eq 3 ]
	assert [ "${REPLY[omicron]}" = pi ]
	assert [ "${REPLY[rho]}" = sigma ]
	assert [ "${REPLY[tau]}" = upsilon ]

	bobject get-string 'OBJECT' '.obj.rho'
	assert [ "$REPLY" = sigma ]
}
