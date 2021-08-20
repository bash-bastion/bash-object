#!/usr/bin/env bats

load './util/init.sh'

@test "error on more than correct 'get' arguments" {
	local subcmds=(get-string get-array get-object)

	for subcmd in "${subcmds[@]}"; do
		declare -A OBJECT=()

		run bobject "$subcmd" 'OBJECT' '.zulu.yankee' 'invalid'

		assert_failure
		assert_line -p "Expected '3' arguments, but received '4'"
	done
}

@test "error on less than correct 'get' arguments" {
	local subcmds=(get-string get-array get-object)

	for subcmd in "${subcmds[@]}"; do
		declare -A OBJECT=()

		run bobject "$subcmd" 'invalid'

		assert_failure
		assert_failure
		assert_line -p "Expected '3' arguments, but received '2'"
	done
}

@test "error on more than correct 'set' arguments" {
	local subcmds=(set-string set-array set-object)

	for subcmd in "${subcmds[@]}"; do
		declare -A OBJECT=()

		run bobject "$subcmd" 'OBJECT' '.zulu.yankee' 'xray' 'invalid'

		assert_failure
		assert_line -p "Expected '4' arguments, but received '5'"
	done
}

@test "error on less than correct 'set' arguments" {
	local subcmds=(set-string set-array set-object)

	for subcmd in "${subcmds[@]}"; do
		declare -A OBJECT=()

		run bobject "$subcmd" 'OBJECT' '.zulu'

		assert_failure
		assert_line -p "Expected '4' arguments, but received '3'"
	done
}

@test "get-string simple parser" {
	declare -A OBJECT=()
	declare -A subobj=()
	str='MEOW'

	bobject set-object 'OBJECT' '.zulu' subobj
	bobject set-string 'OBJECT' '.zulu.yankee' str
	bobject get-string 'OBJECT' '.zulu.yankee'

	assert [ "$REPLY" = 'MEOW' ]
}

@test "get-string advanced parser" {
	declare -A OBJECT=()
	declare -A subobj=()
	str='MEOW'

	bobject set-object 'OBJECT' '.zulu' subobj
	bobject set-string 'OBJECT' '.["zulu"].["yankee"]' str
	bobject get-string 'OBJECT' '.["zulu"].["yankee"]'

	assert [ "$REPLY" = 'MEOW' ]
}

@test "readme code works" {
	declare -A root_object=([zulu=])
	declare -A zulu_object=([yankee]=)
	declare -A yankee_object=([xray]=)
	declare -A xray_object=([whiskey]=victor [foxtrot]=)
	declare -a foxtrot_array=(omicron pi rho sigma)

	bobject set-object root_object '.zulu' zulu_object
	bobject set-object root_object '.zulu.yankee' yankee_object
	bobject set-object root_object '.zulu.yankee.xray' xray_object
	bobject set-array root_object '.zulu.yankee.xray.foxtrot' foxtrot_array

	bobject get-object root_object '.zulu.yankee.xray'
	assert [ "${REPLY[whiskey]}" = victor ]

	bobject get-string root_object '.zulu.yankee.xray.whiskey'
	assert [ "$REPLY" = victor ]

	bobject get-array root_object '.zulu.yankee.xray.victor'
	assert [ ${#REPLY} -eq 4 ]

	bobject get-string root_object '.["zulu"].["yankee"].["xray"].["victor"].[2]'
	assert [ "$REPLY" = rho ]
}
