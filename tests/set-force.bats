#!/usr/bin/env bats

load './util/init.sh'

@test "Correctly force set object on string within array" {
	BASH_OBJECT_FORCE_SET=yes

	declare -A root_object=()
	declare -a arr=(y z)
	declare -A obj=([key1]=value1 [key2]=value2)

	bobject set-array --ref root_object '.a' 'arr'
	bobject set-object --ref root_object '.["a"].[1]' 'obj'

	bobject get-array --value 'root_object' '.["a"]'
	assert [ "${#REPLY[@]}" = 2 ]

	bobject get-string --value 'root_object' '.["a"].[0]'
	assert [ "$REPLY" = y ]

	bobject get-object --value 'root_object' '.["a"].[1]'
	assert [ "${#REPLY[@]}" = 2 ]
	assert [ "${REPLY[key1]}" = value1 ]
	assert [ "${REPLY[key2]}" = value2 ]
}

@test "Correctly force set object on string within object" {
	BASH_OBJECT_FORCE_SET=yes

	declare -A root_object=()
	declare -A p_obj=([a]=b [c]=d [e]=f)
	declare -A sub_obj=([key1]=value1 [key2]=value2)

	bobject set-object --ref root_object '.a' 'p_obj'
	bobject set-object --ref root_object '.["a"].["e"]' 'sub_obj'

	bobject get-object --value 'root_object' '.["a"]'
	assert [ "${#REPLY[@]}" = 3 ]
	assert [ "${REPLY[a]}" = b ]
	assert [ "${REPLY[c]}" = d ]

	bobject get-object --value 'root_object' '.["a"].["e"]'
	assert [ "${#REPLY[@]}" = 2 ]
	assert [ "${REPLY[key1]}" = value1 ]
	assert [ "${REPLY[key2]}" = value2 ]
}

@test "Correctly force set array on string within array" {
	BASH_OBJECT_FORCE_SET=yes

	declare -A root_object=()
	declare -a p_arr=(y z)
	declare -a sub_arr=(a b c d e f)

	bobject set-array --ref root_object '.a' 'p_arr'
	bobject set-array --ref root_object '.["a"].[1]' 'sub_arr'

	bobject get-array --value 'root_object' '.["a"]'
	assert [ "${#REPLY[@]}" = 2 ]

	bobject get-array --value 'root_object' '.["a"].[1]'
	assert [ "${#REPLY[@]}" = 6 ]
	assert [ "${REPLY[0]}" = a ]
	assert [ "${REPLY[1]}" = b ]
	assert [ "${REPLY[5]}" = f ]
}

@test "Correctly force set array on string within object" {
	BASH_OBJECT_FORCE_SET=yes

	declare -A root_object=()
	declare -A p_obj=([w]=x [y]=z)
	declare -a sub_arr=(a b c d e f)

	bobject set-object --ref root_object '.a' 'p_obj'
	bobject set-array --ref root_object '.["a"].["w"]' 'sub_arr'

	bobject get-object --value 'root_object' '.["a"]'
	assert [ "${#REPLY[@]}" = 2 ]
	assert [ "${REPLY[y]}" = z ]

	bobject get-array --value 'root_object' '.["a"].["w"]'
	assert [ "${#REPLY[@]}" = 6 ]
	assert [ "${REPLY[0]}" = a ]
	assert [ "${REPLY[1]}" = b ]
	assert [ "${REPLY[5]}" = f ]
}

@test "Correctly force set nested objects and arrays on string" {
	BASH_OBJECT_FORCE_SET=yes

	declare -A root_object=()
	declare -a tl_arr=()
	declare -a arr_0=(1 2 3 4 5 6)
	declare -a arr_1=(1 2 4 8 this_will_be_replaced_too 32)
	declare -a arr_1_2=(0 1 0)
	declare -A obj_1_4=([and]=epic [so]=cool [this]=is)
	declare -a arr_2=(1 10 100 1000 10000 100000)

	bobject set-array --ref root_object '.arr' 'tl_arr'
	bobject set-array --ref root_object '.["arr"].[0]' 'arr_0'
	bobject set-array --ref root_object '.["arr"].[1]' 'arr_1'
	bobject set-array --ref root_object '.["arr"].[1].[2]' 'arr_1_2'
	bobject set-object --ref root_object '.["arr"].[1].[4]' 'obj_1_4'
	bobject set-array --ref root_object '.["arr"].[2]' 'arr_2'

	bobject get-array --value 'root_object' '.["arr"].[0]'
	assert [ "${#REPLY[@]}" = 6 ]

	bobject get-string --value 'root_object' '.["arr"].[1].[1]'
	assert [ "$REPLY" = 2 ]

	bobject get-array --value 'root_object' '.["arr"].[1].[2]'
	assert [ "${#REPLY[@]}" = 3 ]
	assert [ "${REPLY[0]}" = 0 ]
	assert [ "${REPLY[1]}" = 1 ]
	assert [ "${REPLY[2]}" = 0 ]
}
