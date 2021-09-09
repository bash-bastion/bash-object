#!/usr/bin/env bats

load './util/init.sh'

@test "get-string simple parser" {
	declare -A OBJECT=()
	declare -A subobj=()
	str='MEOW'

	bobject set-object --ref 'OBJECT' '.zulu' subobj
	bobject set-string --ref 'OBJECT' '.zulu.yankee' str
	bobject get-string --value 'OBJECT' '.zulu.yankee'

	assert [ "$REPLY" = 'MEOW' ]
}

@test "get-string advanced parser" {
	declare -A OBJECT=()
	declare -A subobj=()
	str='MEOW'

	bobject set-object --ref 'OBJECT' '.zulu' subobj
	bobject set-string --ref 'OBJECT' '.["zulu"].["yankee"]' str
	bobject get-string --value 'OBJECT' '.["zulu"].["yankee"]'

	assert [ "$REPLY" = 'MEOW' ]
}

@test "readme code works" {
	declare -A root_object=()
	declare -A zulu_object=()
	declare -A yankee_object=()
	declare -A xray_object=([whiskey]=victor)
	declare -a foxtrot_array=(omicron pi rho sigma)

	bobject set-object --ref root_object '.zulu' zulu_object
	bobject set-object --ref root_object '.zulu.yankee' yankee_object
	bobject set-object --ref root_object '.zulu.yankee.xray' xray_object
	bobject set-array --ref root_object '.zulu.yankee.xray.foxtrot' foxtrot_array

	bobject get-object --value root_object '.zulu.yankee.xray'
	assert [ "${REPLY[whiskey]}" = victor ]

	bobject get-string --value root_object '.zulu.yankee.xray.whiskey'
	assert [ "$REPLY" = victor ]

	bobject get-array --value root_object '.zulu.yankee.xray.foxtrot'
	assert [ ${#REPLY[@]} -eq 4 ]

	bobject get-string --value root_object '.["zulu"].["yankee"].["xray"].["foxtrot"].[2]'
	assert [ "$REPLY" = rho ]
}
