#!/usr/bin/env bats

# @file Contains tests that ensure the positional
# parameters have been validated properly, when possible

load './util/init.sh'

@test "Error with \$# of 1" {
	run bash_object.traverse-get string

	assert_failure
	assert_line -p "ERROR_INVALID_ARGS"
	assert_line -p ", but received '1'"
}

@test "Error with \$# of 2" {
	run bash_object.traverse-get string 'OBJECT'

	assert_failure
	assert_line -p "ERROR_INVALID_ARGS"
	assert_line -p ", but received '2'"
}

@test "Error with \$# of 4" {
	run bash_object.traverse-get string 'OBJECT' '.obj' extraneous

	assert_failure
	assert_line -p "ERROR_INVALID_ARGS"
	assert_line -p ", but received '4'"
}

@test "Error on empty \$1" {
	run bash_object.traverse-get "" 'OBJECT' '.obj'

	assert_failure
	assert_line -p "ERROR_INVALID_ARGS"
	assert_line -p "'1' is empty"
}

@test "Error on empty \$2" {
	run bash_object.traverse-get string "" '.obj'

	assert_failure
	assert_line -p "ERROR_INVALID_ARGS"
	assert_line -p "'2' is empty"
}

@test "Error on empty \$3" {
	run bash_object.traverse-get string 'OBJECT' ""

	assert_failure
	assert_line -p "ERROR_INVALID_ARGS"
	assert_line -p "'3' is empty"
}
