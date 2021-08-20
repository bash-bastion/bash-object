#!/usr/bin/env bats

load './util/init.sh'

# get
@test "get errors on missing flags" {
	run bobject get-string

	assert_failure
	assert_line -p 'ERROR_ARGUMENTS_INVALID'
	assert_line -p "Must pass either the '--as-ref' or '--as-value' flag"
}

@test "get errors on combining mutually exclusive flags" {
	run bobject get-string --as-value --as-ref

	assert_failure
	assert_line -p 'ERROR_ARGUMENTS_INVALID'
	assert_line -p "Flags '--as-ref' and '--as-value' are mutually exclusive"
}

@test "error on unimplemented --as-ref" {
	run bobject get-string --as-ref

	assert_failure
	assert_line -p 'ERROR_ARGUMENTS_INVALID'
	assert_line -p "--as-ref not implemented"
}

# set
@test "set errors on missing flags" {
	run bobject set-string

	assert_failure
	assert_line -p 'ERROR_ARGUMENTS_INVALID'
	assert_line -p "Must pass either the '--by-ref' or '--by-value' flag"
}

@test "set errors on combining mutually exclusive flags" {
	run bobject set-string --by-value --by-ref

	assert_failure
	assert_line -p 'ERROR_ARGUMENTS_INVALID'
	assert_line -p "Flags '--by-ref' and '--by-value' are mutually exclusive"
}

@test "error on unimplemented --by-value" {
	run bobject set-string --by-value

	assert_failure
	assert_line -p 'ERROR_ARGUMENTS_INVALID'
	assert_line -p "--by-value not implemented"
}
