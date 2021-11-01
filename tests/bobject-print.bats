#!/usr/bin/env bats

load './util/init.sh'

@test "Errors if first parameter is invalid" {
	run bobject.print

	assert_failure
	assert_line -p 'ERROR_ARGUMENTS_INVALID'
	assert_line -p 'Positional parameter 1 is empty. Please check passed parameters'
}

@test "Errors if passed parameter is not a variable" {
	run bobject.print 'variable'

	assert_failure
	assert_line -p 'ERROR_NOT_FOUND'
	assert_line -p "The variable 'variable' does not exist"
}

@test "Errors if passed parameter is neither an object nor an array" {
	variable=
	run bobject.print 'variable'

	assert_failure
	assert_line -p 'ERROR_ARGUMENTS_INVALID_TYPE'
	assert_line -p "is neither an array nor an object"
}
