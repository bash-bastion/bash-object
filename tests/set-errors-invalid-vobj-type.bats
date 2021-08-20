#!/usr/bin/env bats

# @brief Ensures errors are thrown when the type of the vobject
# does not match up with the specified type (as in set-array, set-object, etc.). This can occur if a vobject already exists, but
# it is the wrong type

load './util/init.sh'

# set-object
@test "Error on set-object'ing array" {
	declare -a SUB_ARRAY=(omicron pi rho)
	declare -A OBJECT=([my_key]=$'\x1C\x1Dtype=array;&SUB_ARRAY')
	declare -A obj=([upsilon]=phi)

	run bobject set-object --pass-by-ref OBJECT '.my_key' obj

	assert_failure
	assert_line -p "ERROR_ARGUMENTS_INCORRECT_TYPE"
	assert_line -p 'Assigning an object, but found existing array'
}

@test "Error on set-object'ing array inside object" {
	declare -a SUB_SUB_ARRAY=(omicron pi rho)
	declare -A SUB_OBJECT=([nested]=$'\x1C\x1Dtype=array;&SUB_SUB_ARRAY')
	declare -A OBJECT=([my_key]=$'\x1C\x1Dtype=array;&SUB_OBJECT')
	declare -A obj=([upsilon]=phi)

	run bobject set-object --pass-by-ref OBJECT '.my_key.nested' obj

	assert_failure
	assert_line -p "ERROR_ARGUMENTS_INCORRECT_TYPE"
	assert_line -p 'Assigning an object, but found existing array'
}

@test "Error on set-object'ing array in array" {
	declare -a SUB_SUB_ARRAY=(rho sigma tau)
	declare -a SUB_ARRAY=(omicron pi $'\x1C\x1Dtype=array;&SUB_SUB_ARRAY')
	declare -A OBJECT=([my_key]=$'\x1C\x1Dtype=array;&SUB_ARRAY')
	declare -A obj=([upsilon]=phi)

	run bobject set-object --pass-by-ref OBJECT '.["my_key"].[2]' obj

	assert_failure
	assert_line -p "ERROR_ARGUMENTS_INCORRECT_TYPE"
	assert_line -p 'Assigning an object, but found existing array'
}

@test "Error on set-object'ing string" {
	declare -A OBJECT=([my_key]='string_value2')
	declare -A obj=([upsilon]=phi)

	run bobject set-object --pass-by-ref OBJECT '.my_key' obj

	assert_failure
	assert_line -p "ERROR_ARGUMENTS_INCORRECT_TYPE"
	assert_line -p 'Assigning an object, but found existing string'
}

@test "Error on set-object'ing string inside object" {
	declare -A SUB_OBJECT=([nested]='string_value')
	declare -A OBJECT=([my_key]=$'\x1C\x1Dtype=object;&SUB_OBJECT')
	declare -A obj=([upsilon]=phi)

	run bobject set-object --pass-by-ref OBJECT '.my_key.nested' obj

	assert_failure
	assert_line -p "ERROR_ARGUMENTS_INCORRECT_TYPE"
	assert_line -p 'Assigning an object, but found existing string'
}

@test "Error on set-object'ing string in array" {
	declare -a SUB_ARRAY=(omicron pi rho)
	declare -A OBJECT=([my_key]=$'\x1C\x1Dtype=array;&SUB_ARRAY')
	declare -A obj=([upsilon]=phi)

	run bobject set-object --pass-by-ref OBJECT '.["my_key"].[2]' obj

	assert_failure
	assert_line -p "ERROR_ARGUMENTS_INCORRECT_TYPE"
	assert_line -p 'Assigning an object, but found existing string'
}

# set-array
@test "Error on set-array'ing object" {
	declare -A SUB_SUB_OBJECT=([phi]=chi)
	declare -A OBJECT=([my_key]=$'\x1C\x1Dtype=object;&SUB_OBJECT')
	declare -a arr=(upsilon phi chi psi)

	run bobject set-array --pass-by-ref OBJECT '.my_key' arr

	assert_failure
	assert_line -p "ERROR_ARGUMENTS_INCORRECT_TYPE"
	assert_line -p 'Assigning an array, but found existing object'
}

@test "Error on set-array'ing object inside object" {
	declare -A SUB_SUB_OBJECT=([phi]=chi)
	declare -A SUB_OBJECT=([nested]=$'\x1C\x1Dtype=object;&SUB_SUB_OBJECT')
	declare -A OBJECT=([my_key]=$'\x1C\x1Dtype=object;&SUB_OBJECT')
	declare -a arr=(upsilon phi chi psi)

	run bobject set-array --pass-by-ref OBJECT '.my_key.nested' arr

	assert_failure
	assert_line -p "ERROR_ARGUMENTS_INCORRECT_TYPE"
	assert_line -p 'Assigning an array, but found existing object'
}

@test "Error on set-array'ing object in array" {
	declare -A SUB_SUB_OBJECT=([phi]=chi)
	declare -a SUB_ARRAY=(omicron pi $'\x1C\x1Dtype=object;&SUB_SUB_OBJECT')
	declare -A OBJECT=([my_key]=$'\x1C\x1Dtype=array;&SUB_ARRAY')
	declare -a arr=(upsilon phi chi psi)

	run bobject set-array --pass-by-ref OBJECT '.["my_key"].[2]' arr

	assert_failure
	assert_line -p "ERROR_ARGUMENTS_INCORRECT_TYPE"
	assert_line -p 'Assigning an array, but found existing object'
}

@test "Error on set-array'ing string" {
	declare -A OBJECT=([my_key]='string_value2')
	declare -a arr=(upsilon phi chi psi)

	run bobject set-array --pass-by-ref OBJECT '.my_key' arr

	assert_failure
	assert_line -p "ERROR_ARGUMENTS_INCORRECT_TYPE"
	assert_line -p 'Assigning an array, but found existing string'
}

@test "Error on set-array'ing string inside object" {
	declare -A SUB_OBJECT=([nested]='string_value')
	declare -A OBJECT=([my_key]=$'\x1C\x1Dtype=object;&SUB_OBJECT')
	declare -a arr=(upsilon phi chi psi)

	run bobject set-array --pass-by-ref OBJECT '.my_key.nested' arr

	assert_failure
	assert_line -p "ERROR_ARGUMENTS_INCORRECT_TYPE"
	assert_line -p 'Assigning an array, but found existing string'
}

@test "Error on set-array'ing string in array" {
	declare -a SUB_ARRAY=(omicron pi 'string value')
	declare -A OBJECT=([my_key]=$'\x1C\x1Dtype=array;&SUB_ARRAY')
	declare -a arr=(upsilon phi chi psi)

	run bobject set-array --pass-by-ref OBJECT '.["my_key"].[2]' arr

	assert_failure
	assert_line -p "ERROR_ARGUMENTS_INCORRECT_TYPE"
	assert_line -p 'Assigning an array, but found existing string'
}

# set-string
@test "Error on set-string'ing array" {
	declare -a SUB_ARRAY=(omicron pi rho)
	declare -A OBJECT=([my_key]=$'\x1C\x1Dtype=array;&SUB_ARRAY')
	str='psi-omega'

	run bobject set-string --pass-by-ref OBJECT '.my_key' str

	assert_failure
	assert_line -p "ERROR_ARGUMENTS_INCORRECT_TYPE"
	assert_line -p 'Assigning an string, but found existing array'
}

@test "Error on set-string'ing array inside object" {
	declare -a SUB_SUB_ARRAY=(omicron pi rho)
	declare -A SUB_OBJECT=([nested]=$'\x1C\x1Dtype=array;&SUB_SUB_ARRAY')
	declare -A OBJECT=([my_key]=$'\x1C\x1Dtype=array;&SUB_OBJECT')
	str='psi-omega'

	run bobject set-string --pass-by-ref OBJECT '.my_key.nested' str

	assert_failure
	assert_line -p "ERROR_ARGUMENTS_INCORRECT_TYPE"
	assert_line -p 'Assigning an string, but found existing array'
}

@test "Error on set-string'ing array in array" {
	declare -a SUB_SUB_ARRAY=(rho sigma tau)
	declare -a SUB_ARRAY=(omicron pi $'\x1C\x1Dtype=array;&SUB_SUB_ARRAY')
	declare -A OBJECT=([my_key]=$'\x1C\x1Dtype=array;&SUB_ARRAY')
	str='psi-omega'

	run bobject set-string --pass-by-ref OBJECT '.["my_key"].[2]' str

	assert_failure
	assert_line -p "ERROR_ARGUMENTS_INCORRECT_TYPE"
	assert_line -p 'Assigning an string, but found existing array'
}

@test "Error on set-string'ing object" {
	declare -A SUB_SUB_OBJECT=([phi]=chi)
	declare -A OBJECT=([my_key]=$'\x1C\x1Dtype=object;&SUB_OBJECT')
	str='psi-omega'

	run bobject set-string --pass-by-ref OBJECT '.my_key' str

	assert_failure
	assert_line -p "ERROR_ARGUMENTS_INCORRECT_TYPE"
	assert_line -p 'Assigning an string, but found existing object'
}

@test "Error on set-string'ing object inside object" {
	declare -A SUB_SUB_OBJECT=([phi]=chi)
	declare -A SUB_OBJECT=([nested]=$'\x1C\x1Dtype=object;&SUB_SUB_OBJECT')
	declare -A OBJECT=([my_key]=$'\x1C\x1Dtype=object;&SUB_OBJECT')
	str='psi-omega'

	run bobject set-string --pass-by-ref OBJECT '.my_key.nested' str

	assert_failure
	assert_line -p "ERROR_ARGUMENTS_INCORRECT_TYPE"
	assert_line -p 'Assigning an string, but found existing object'
}

@test "Error on set-string'ing object in array" {
	declare -A SUB_SUB_OBJECT=([phi]=chi)
	declare -a SUB_ARRAY=(omicron pi $'\x1C\x1Dtype=object;&SUB_SUB_OBJECT')
	declare -A OBJECT=([my_key]=$'\x1C\x1Dtype=array;&SUB_ARRAY')
	str='psi-omega'

	run bobject set-string --pass-by-ref OBJECT '.["my_key"].[2]' str

	assert_failure
	assert_line -p "ERROR_ARGUMENTS_INCORRECT_TYPE"
	assert_line -p 'Assigning an string, but found existing object'
}
