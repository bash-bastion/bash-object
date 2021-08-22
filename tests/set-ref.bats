#!/usr/bin/env bats

load './util/init.sh'

# object
@test "Correctly sets object" {
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
@test "Correctly sets array" {
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
@test "Correctly sets string at root" {
	declare -A OBJECT=()
	str='my_value'

	bobject set-string --ref 'OBJECT' '.my_key' str
	assert [ "${OBJECT[my_key]}" = 'my_value' ]

	bobject get-string --value 'OBJECT' '.my_key'
	assert [ "$REPLY" = 'my_value' ]
}

@test "Correctly sets string in object" {
	declare -A SUB_OBJECT=()
	declare -A OBJECT=([tau]=$'\x1C\x1Dtype=object;&SUB_OBJECT')
	str='phi'

	bobject set-string --ref 'OBJECT' '.tau.upsilon' str
	bobject get-string --value 'OBJECT' '.tau.upsilon'
	assert [ "$REPLY" = 'phi' ]
}

@test "Correctly sets string in object 2" {
	declare -A obj=()
	declare -A OBJECT=()
	str='phi'

	bobject set-object --ref 'OBJECT' '.tau' obj

	bobject set-string --ref 'OBJECT' '.tau.upsilon' str
	bobject get-string --value 'OBJECT' '.tau.upsilon'
	assert [ "$REPLY" = 'phi' ]
}

@test "Correctly sets string in subobject" {
	declare -A SUB_SUB_OBJECT=()
	declare -A SUB_OBJECT=([pi]=$'\x1C\x1Dtype=object;&SUB_SUB_OBJECT')
	declare -A OBJECT=([omicron]=$'\x1C\x1Dtype=object;&SUB_OBJECT')
	str='sigma'

	bobject set-string --ref 'OBJECT' '.omicron.pi.rho' str
	bobject get-string --value 'OBJECT' '.omicron.pi.rho'
	assert [ "$REPLY" = 'sigma' ]
}

@test "Correctly sets string in subobject 2" {
	declare -A obj=()
	str='sigma'

	bobject set-object --ref 'OBJECT' '.omicron' obj
	bobject set-object --ref 'OBJECT' '.omicron.pi' obj

	bobject set-string --ref 'OBJECT' '.omicron.pi.rho' str
	bobject get-string --value 'OBJECT' '.omicron.pi.rho'
	assert [ "$REPLY" = 'sigma' ]
}

@test "Correctly sets 2 strings in subobject" {
	declare -A SUB_SUB_OBJECT=()
	declare -A SUB_OBJECT=([pi]=$'\x1C\x1Dtype=object;&SUB_SUB_OBJECT')
	declare -A OBJECT=([omicron]=$'\x1C\x1Dtype=object;&SUB_OBJECT')
	str1='sigma'
	str2='upsilon'

	bobject set-string --ref 'OBJECT' '.omicron.pi.rho' str1
	bobject set-string --ref 'OBJECT' '.omicron.pi.tau' str2

	bobject get-string --value 'OBJECT' '.omicron.pi.rho'
	assert [ "$REPLY" = 'sigma' ]

	bobject get-string --value 'OBJECT' '.omicron.pi.tau'
	assert [ "$REPLY" = 'upsilon' ]

	bobject get-object --value 'OBJECT' '.omicron.pi'

	assert [ "${REPLY[rho]}" = 'sigma' ]
	assert [ "${REPLY[tau]}" = 'upsilon' ]
}

@test "Correctly sets 2 strings in subobject 2" {
	declare -A obj=()
	str1='sigma'
	str2='upsilon'

	bobject set-object --ref 'OBJECT' '.omicron' obj
	bobject set-object --ref 'OBJECT' '.omicron.pi' obj

	bobject set-string --ref 'OBJECT' '.omicron.pi.rho' str1
	bobject set-string --ref 'OBJECT' '.omicron.pi.tau' str2

	bobject get-string --value 'OBJECT' '.omicron.pi.rho'
	assert [ "$REPLY" = 'sigma' ]

	bobject get-string --value 'OBJECT' '.omicron.pi.tau'
	assert [ "$REPLY" = 'upsilon' ]

	bobject get-object --value 'OBJECT' '.omicron.pi'

	assert [ "${REPLY[rho]}" = 'sigma' ]
	assert [ "${REPLY[tau]}" = 'upsilon' ]
}
