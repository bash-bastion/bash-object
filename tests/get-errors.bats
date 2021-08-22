#!/usr/bin/env bats

load './util/init.sh'

@test "Error if getting more than a string" {
	declare -A OBJECT=()
	str='golf'

	bobject set-string --ref OBJECT '.foxtrot' str
	run bobject get-string --ref OBJECT '.foxtrot.omega'

	assert_failure
	assert_line -p 'ERROR_NOT_FOUND'
	assert_line -p "The passed querytree implies that 'foxtrot' accesses an object or array, but a string with a value of 'golf' was found instead"
}
