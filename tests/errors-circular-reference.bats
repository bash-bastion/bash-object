#!/usr/bin/env bats

load './util/init.sh'

# get
@test "get-object stops on circular reference" {
	declare -A SUB_OBJECT=([nested]=$'\x1C\x1Dtype=object;&SUB_OBJECT')
	declare -A OBJECT=([my_key]=$'\x1C\x1Dtype=object;&SUB_OBJECT')

	run bobject get-object --value OBJECT '.my_key.nested'

	assert_failure
	assert_line -p "ERROR_SELF_REFERENCE"
	assert_line -p "Virtual object 'SUB_OBJECT' cannot reference itself"
}

@test "get-object stops on circular reference 2" {
	declare -A SUB_OBJECT=([nested]=$'\x1C\x1Dtype=object;&SUB_OBJECT')
	declare -A OBJECT=([my_key]=$'\x1C\x1Dtype=object;&SUB_OBJECT')

	run bobject get-object --value OBJECT '.my_key.nested.nested'

	assert_failure
	assert_line -p "ERROR_SELF_REFERENCE"
	assert_line -p "Virtual object 'SUB_OBJECT' cannot reference itself"
}

@test "get-array stops on circular reference" {
	declare -a SUB_ARRAY=($'\x1C\x1Dtype=array;&SUB_ARRAY')
	declare -A OBJECT=([my_key]=$'\x1C\x1Dtype=array;&SUB_ARRAY')

	run bobject get-array --value OBJECT '.["my_key"].[0]'

	assert_failure
	assert_line -p "ERROR_SELF_REFERENCE"
	assert_line -p "Virtual object 'SUB_ARRAY' cannot reference itself"
}

@test "get-array stops on circular reference 2" {
	declare -a SUB_ARRAY=($'\x1C\x1Dtype=array;&SUB_ARRAY')
	declare -A OBJECT=([my_key]=$'\x1C\x1Dtype=array;&SUB_ARRAY')

	run bobject get-array --value OBJECT '.["my_key"].[0].[0]'

	assert_failure
	assert_line -p "ERROR_SELF_REFERENCE"
	assert_line -p "Virtual object 'SUB_ARRAY' cannot reference itself"
}

# set
@test "set-object stops on circular reference" {
	declare -A SUB_OBJECT=([nested]=$'\x1C\x1Dtype=object;&SUB_OBJECT')
	declare -A OBJECT=([my_key]=$'\x1C\x1Dtype=object;&SUB_OBJECT')
	declare -A obj=()

	run bobject set-object OBJECT --ref '.my_key.nested' obj

	assert_failure
	assert_line -p "ERROR_SELF_REFERENCE"
	assert_line -p "Virtual object 'SUB_OBJECT' cannot reference itself"
}

@test "set-object stops on circular reference 2" {
	declare -A SUB_OBJECT=([nested]=$'\x1C\x1Dtype=object;&SUB_OBJECT')
	declare -A OBJECT=([my_key]=$'\x1C\x1Dtype=object;&SUB_OBJECT')
	declare -A obj=()

	run bobject set-object OBJECT --ref '.my_key.nested.gone' obj

	assert_failure
	assert_line -p "ERROR_SELF_REFERENCE"
	assert_line -p "Virtual object 'SUB_OBJECT' cannot reference itself"
}

@test "set-array stops on circular reference" {
	declare -a SUB_ARRAY=($'\x1C\x1Dtype=array;&SUB_ARRAY')
	declare -A OBJECT=([my_key]=$'\x1C\x1Dtype=array;&SUB_ARRAY')
	declare -a arr=()

	run bobject set-array OBJECT --ref '.["my_key"].[0]' arr

	assert_failure
	assert_line -p "ERROR_SELF_REFERENCE"
	assert_line -p "Virtual object 'SUB_ARRAY' cannot reference itself"
}

@test "set-array stops on circular reference 2" {
	declare -a SUB_ARRAY=($'\x1C\x1Dtype=array;&SUB_ARRAY')
	declare -A OBJECT=([my_key]=$'\x1C\x1Dtype=array;&SUB_ARRAY')
	declare -a arr=()

	run bobject set-array OBJECT --ref '.["my_key"].[0].[0]' arr

	assert_failure
	assert_line -p "ERROR_SELF_REFERENCE"
	assert_line -p "Virtual object 'SUB_ARRAY' cannot reference itself"
}
