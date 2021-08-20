#!/usr/bin/env bats

load './util/init.sh'

@test "Correctly sets array" {
	declare -a arr=(omicron pi rho)
	declare -A OBJECT=()

	bobject set-array --pass-by-ref 'OBJECT' '.arr' arr

	bobject get-array 'OBJECT' '.arr'
	assert [ ${#REPLY[@]} -eq 3 ]
	assert [ "${REPLY[0]}" = omicron ]
	assert [ "${REPLY[1]}" = pi ]
	assert [ "${REPLY[2]}" = rho ]

	bobject get-string 'OBJECT' '.["arr"].[0]'
	assert [ "$REPLY" = omicron ]

	bobject get-string 'OBJECT' '.["arr"].[1]'
	assert [ "$REPLY" = pi ]

	bobject get-string 'OBJECT' '.["arr"].[2]'
	assert [ "$REPLY" = rho ]
}
