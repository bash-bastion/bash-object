# shellcheck shell=bash

load './util/init.sh'

@test "Error if random variable already exists" {
	declare -A OBJECT=()
	declare -A objj=()

	bash_object.util.generate_vobject_name() {
		REPLY="some_other_var"
	}
	declare -g some_other_var=

	run bobject set-object --by-ref 'OBJECT' '.obj' objj

	assert_failure
	assert_output -p 'ERROR_INTERNAL'
	assert_output -p "Variable 'some_other_var' exists, but it shouldn't"
}
