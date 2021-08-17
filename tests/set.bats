# shellcheck shell=bash

load './util/init.sh'

@test "Error if random variable already exists" {
	declare -gA objj=()

	bash_object.util.generate_vobject_name() {
		REPLY="some_other_var"
	}
	declare -g some_other_var=

	run bash_object.traverse-set object 'OBJECT' '.obj' objj

	assert_failure
	assert_output -p 'ERROR_INTERNAL_MISCELLANEOUS'
	assert_output -p "Variable 'some_other_var' exists, but it shouldn't"
}
