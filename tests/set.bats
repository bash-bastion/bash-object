# shellcheck shell=bash

load './util/init.sh'

@test "Error if random variable already exists for set-object" {
	declare -A OBJECT=()
	declare -A obj=()

	bash_object.util.generate_vobject_name() {
		REPLY="some_other_var"
	}
	declare -g some_other_var=

	run bobject set-object --ref 'OBJECT' '.obj' obj

	assert_failure
	assert_output -p 'ERROR_INTERNAL'
	assert_output -p "Variable 'some_other_var' exists, but it shouldn't"
}

@test "Error if random variable already exists for set-array" {
	declare -A OBJECT=()
	declare -a arr=()

	bash_object.util.generate_vobject_name() {
		REPLY="some_other_var"
	}
	declare -g some_other_var=

	run bobject set-array --ref 'OBJECT' '.obj' arr

	assert_failure
	assert_output -p 'ERROR_INTERNAL'
	assert_output -p "Variable 'some_other_var' exists, but it shouldn't"
}

@test "Error if setting more than a string" {
	declare -A OBJECT=()
	str='golf'

	bobject set-string --ref OBJECT '.foxtrot' str
	run bobject set-string --ref OBJECT '.foxtrot.omega' str

	assert_failure
	assert_line -p 'ERROR_NOT_FOUND'
	assert_line -p "The passed querytree implies that 'foxtrot' accesses an object or array, but a string with a value of 'golf' was found instead"
}

# TODO: move
@test "Error if getting more than a string" {
	declare -A OBJECT=()
	str='golf'

	bobject set-string --ref OBJECT '.foxtrot' str
	run bobject get-string --ref OBJECT '.foxtrot.omega'

	assert_failure
	assert_line -p 'ERROR_NOT_FOUND'
	assert_line -p "The passed querytree implies that 'foxtrot' accesses an object or array, but a string with a value of 'golf' was found instead"
}
