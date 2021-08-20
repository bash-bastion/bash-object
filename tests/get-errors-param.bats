#!/usr/bin/env bats

# @brief Contains tests that ensure the positional
# parameters have been validated properly, when possible. \$1 is not
# tested because bobject.sh always sets the first positional parameter

load './util/init.sh'

@test "Error with \$# of 2" {
	run bobject get-string 'OBJECT'

	assert_failure
	assert_line -p "ERROR_ARGUMENTS_INVALID"
	assert_line -p ", but received '2'"
}

@test "Error with \$# of 4" {
	run bobject get-string 'OBJECT' '.obj' extraneous

	assert_failure
	assert_line -p "ERROR_ARGUMENTS_INVALID"
	assert_line -p ", but received '4'"
}

@test "Error on empty \$2" {
	run bobject get-string "" '.obj'

	assert_failure
	assert_line -p "ERROR_ARGUMENTS_INVALID"
	assert_line -p "'2' is empty"
}

@test "Error on empty \$3" {
	run bobject get-string 'OBJECT' ""

	assert_failure
	assert_line -p "ERROR_ARGUMENTS_INVALID"
	assert_line -p "'3' is empty"
}