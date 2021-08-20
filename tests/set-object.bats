#!/usr/bin/env bats

load './util/init.sh'

@test "correctly sets object" {
	declare -A obj=([omicron]=pi [rho]=sigma [tau]=upsilon)
	declare -A OBJECT=()

	bash_object.traverse-set --pass-by-ref object 'OBJECT' '.obj' obj

	bash_object.traverse-get object 'OBJECT' '.obj'
	assert [ ${#REPLY[@]} -eq 3 ]
	assert [ "${REPLY[omicron]}" = pi ]
	assert [ "${REPLY[rho]}" = sigma ]
	assert [ "${REPLY[tau]}" = upsilon ]

	bash_object.traverse-get string 'OBJECT' '.obj.rho'
	assert [ "$REPLY" = sigma ]
}
