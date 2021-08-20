#!/usr/bin/env bats

load './util/init.sh'

@test "Correctly sets array" {
	declare -a arr=(omicron pi rho)
	declare -A OBJECT=()

	bash_object.traverse-set --pass-by-ref array 'OBJECT' '.arr' arr

	bash_object.traverse-get array 'OBJECT' '.arr'
	assert [ ${#REPLY[@]} -eq 3 ]
	assert [ "${REPLY[0]}" = omicron ]
	assert [ "${REPLY[1]}" = pi ]
	assert [ "${REPLY[2]}" = rho ]

	bash_object.traverse-get string 'OBJECT' '.["arr"].[0]'
	assert [ "$REPLY" = omicron ]

	bash_object.traverse-get string 'OBJECT' '.["arr"].[1]'
	assert [ "$REPLY" = pi ]

	bash_object.traverse-get string 'OBJECT' '.["arr"].[2]'
	assert [ "$REPLY" = rho ]
}
