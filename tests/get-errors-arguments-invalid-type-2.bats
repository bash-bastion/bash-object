#!/usr/bin/env bats

# @brief '-2' tests the same things as 1, but uses the native subcommands
# rather than constructing the objects and arrays manually

load './util/init.sh'

# get-object
@test "Error on get-object'ing string" {
	declare -A OBJECT=([my_key]='string_value2')

	run bobject get-object --as-value OBJECT '.my_key'

	assert_failure
	assert_line -p "ERROR_ARGUMENTS_INCORRECT_TYPE"
	assert_line -p 'Queried for object, but found existing string'
}

@test "Error on get-object'ing string inside object" {
	declare -A SUB_OBJECT=([nested]='string_value')
	declare -A OBJECT=()

	bobject set-object --by-ref OBJECT '.my_key' SUB_OBJECT
	run bobject get-object --as-value OBJECT '.my_key.nested'

	assert_failure
	assert_line -p "ERROR_ARGUMENTS_INCORRECT_TYPE"
	assert_line -p 'Queried for object, but found existing string'
}

@test "Error on get-object'ing string inside array" {
	declare -a SUB_ARRAY=(upsilon phi chi psi omicron)
	declare -A OBJECT=()

	bobject set-array --by-ref OBJECT '.my_key' SUB_ARRAY
	run bobject get-object --as-value OBJECT '.["my_key"].[3]'

	assert_failure
	assert_line -p "ERROR_ARGUMENTS_INCORRECT_TYPE"
	assert_line -p 'Queried for object, but found existing string'
}

@test "Error on get-object'ing array" {
	declare -a SUB_ARRAY=(omicron pi rho)
	declare -A OBJECT=()

	bobject set-array --by-ref OBJECT '.my_key' SUB_ARRAY
	run bobject get-object --as-value OBJECT '.my_key'

	assert_failure
	assert_line -p "ERROR_ARGUMENTS_INCORRECT_TYPE"
	assert_line -p 'Queried for object, but found existing array'
}

@test "Error on get-object'ing array inside object" {
	declare -a SUB_SUB_ARRAY=(omicron pi rho)
	declare -A SUB_OBJECT=()
	declare -A OBJECT=()

	bobject set-object --by-ref OBJECT '.my_key' SUB_OBJECT
	bobject set-array --by-ref OBJECT '.my_key.nested' SUB_SUB_ARRAY
	run bobject get-object --as-value OBJECT '.my_key.nested'

	assert_failure
	assert_line -p "ERROR_ARGUMENTS_INCORRECT_TYPE"
	assert_line -p 'Queried for object, but found existing array'
}

@test "Error on get-object'ing array inside array" {
	declare -a SUB_SUB_ARRAY=(alpha beta gamma delta)
	declare -a SUB_ARRAY=(upsilon phi chi)
	declare -A OBJECT=()

	bobject set-array --by-ref OBJECT '.my_key' SUB_ARRAY
	bobject set-array --by-ref OBJECT '.["my_key"].[3]' SUB_SUB_ARRAY
	run bobject get-object --as-value OBJECT '.["my_key"].[3]'

	assert_failure
	assert_line -p "ERROR_ARGUMENTS_INCORRECT_TYPE"
	assert_line -p 'Queried for object, but found existing array'
}

# get-array
@test "Error on get-array'ing string" {
	declare -A OBJECT=([my_key]='string_value2')

	run bobject get-array --as-value OBJECT '.my_key'

	assert_failure
	assert_line -p "ERROR_ARGUMENTS_INCORRECT_TYPE"
	assert_line -p 'Queried for array, but found existing string'
}

@test "Error on get-array'ing string in object" {
	declare -A SUB_OBJECT=([nested]='string_value')
	declare -A OBJECT=()

	bobject set-object --by-ref OBJECT '.my_key' SUB_OBJECT
	run bobject get-array --as-value OBJECT '.my_key.nested'

	assert_failure
	assert_line -p "ERROR_ARGUMENTS_INCORRECT_TYPE"
	assert_line -p 'Queried for array, but found existing string'
}

@test "Error on get-array'ing string in array" {
	declare -a SUB_ARRAY=(epsilon zeta eta)
	declare -A OBJECT=()

	bobject set-array --by-ref OBJECT '.my_key' SUB_ARRAY
	run bobject get-array --as-value OBJECT '.["my_key"].[2]'

	assert_failure
	assert_line -p "ERROR_ARGUMENTS_INCORRECT_TYPE"
	assert_line -p 'Queried for array, but found existing string'
}

@test "Error on get-array'ing object" {
	declare -A SUB_OBJECT=([omicron]='pi')
	declare -A OBJECT=()

	bobject set-object --by-ref OBJECT '.my_key' SUB_OBJECT
	run bobject get-array --as-value OBJECT '.my_key'

	assert_failure
	assert_line -p "ERROR_ARGUMENTS_INCORRECT_TYPE"
	assert_line -p 'Queried for array, but found existing object'
}

@test "Error on get-array'ing object in object" {
	declare -A SUB_SUB_OBJECT=([omicron]='pi')
	declare -A SUB_OBJECT=()
	declare -A OBJECT=()

	bobject set-object --by-ref OBJECT '.my_key' SUB_OBJECT
	bobject set-object --by-ref OBJECT '.my_key.nested' SUB_SUB_OBJECT
	run bobject get-array --as-value OBJECT '.my_key.nested'

	assert_failure
	assert_line -p "ERROR_ARGUMENTS_INCORRECT_TYPE"
	assert_line -p 'Queried for array, but found existing object'
}

@test "Error on get-array'ing object in array" {
	declare -A SUB_SUB_OBJECT=([omicron]='pi')
	declare -a SUB_ARRAY=(epsilon)
	declare -A OBJECT=()

	bobject set-array --by-ref OBJECT '.my_key' SUB_ARRAY
	bobject set-object --by-ref OBJECT '.["my_key"].[1]' SUB_SUB_OBJECT
	run bobject get-array --as-value OBJECT '.["my_key"].[1]'

	assert_failure
	assert_line -p "ERROR_ARGUMENTS_INCORRECT_TYPE"
	assert_line -p 'Queried for array, but found existing object'
}

# get-string
@test "Error on get-string'ing object" {
	declare -A SUB_OBJECT=([omicron]='pi')
	declare -A OBJECT=()

	bobject set-object --by-ref OBJECT '.my_key' SUB_OBJECT
	run bobject get-string --as-value OBJECT '.my_key'

	assert_failure
	assert_line -p "ERROR_ARGUMENTS_INCORRECT_TYPE"
	assert_line -p 'Queried for string, but found existing object'
}

@test "Error on get-string'ing object in object" {
	declare -A SUB_SUB_OBJECT=([omicron]='pi')
	declare -A SUB_OBJECT=()
	declare -A OBJECT=()

	bobject set-object --by-ref OBJECT '.my_key' SUB_OBJECT
	bobject set-object --by-ref OBJECT '.my_key.nested' SUB_SUB_OBJECT
	run bobject get-string --as-value OBJECT '.my_key.nested'

	assert_failure
	assert_line -p "ERROR_ARGUMENTS_INCORRECT_TYPE"
	assert_line -p 'Queried for string, but found existing object'
}

@test "Error on get-string'ing object in array" {
	declare -A SUB_SUB_OBJECT=([omicron]='pi')
	declare -a SUB_ARRAY=(epislon zeta eta )
	declare -A OBJECT=()

	bobject set-array --by-ref OBJECT '.my_key' SUB_ARRAY
	bobject set-object --by-ref OBJECT '.["my_key"].[3]' SUB_SUB_OBJECT
	run bobject get-string --as-value OBJECT '.["my_key"].[3]'

	assert_failure
	assert_line -p "ERROR_ARGUMENTS_INCORRECT_TYPE"
	assert_line -p 'Queried for string, but found existing object'
}

@test "Error on get-string'ing array" {
	declare -a SUB_ARRAY=(omicron pi rho)
	declare -A OBJECT=()

	bobject set-array --by-ref OBJECT '.my_key' SUB_ARRAY
	run bobject get-string --as-value OBJECT '.my_key'

	assert_failure
	assert_line -p "ERROR_ARGUMENTS_INCORRECT_TYPE"
	assert_line -p 'Queried for string, but found existing array'
}

@test "Error on get-string'ing array in object" {
	declare -a SUB_SUB_ARRAY=(omicron pi rho)
	declare -A SUB_OBJECT=()
	declare -A OBJECT=()

	bobject set-object --by-ref OBJECT '.my_key' SUB_OBJECT
	bobject set-array --by-ref OBJECT '.my_key.nested' SUB_SUB_ARRAY
	run bobject get-string --as-value OBJECT '.my_key.nested'

	assert_failure
	assert_line -p "ERROR_ARGUMENTS_INCORRECT_TYPE"
	assert_line -p 'Queried for string, but found existing array'
}

@test "Error on get-string'ing array in array" {
	declare -a SUB_SUB_ARRAY=(omicron pi rho)
	declare -a SUB_ARRAY=(omicron pi)
	declare -A OBJECT=()

	bobject set-array --by-ref OBJECT '.my_key' SUB_ARRAY
	bobject set-array --by-ref OBJECT '.["my_key"].[2]' SUB_SUB_ARRAY
	run bobject get-string --as-value OBJECT '.["my_key"].[2]'

	assert_failure
	assert_line -p "ERROR_ARGUMENTS_INCORRECT_TYPE"
	assert_line -p 'Queried for string, but found existing array'
}
