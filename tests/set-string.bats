#!/usr/bin/env bats

load './util/init.sh'

@test "errors if setting string on existing object" {
	declare -A SUB_OBJECT=([nested]=woof)
	declare -A OBJECT=([my_key]=$'\x1C\x1Dtype=object;&SUB_OBJECT')

	run bash_object.traverse set string 'OBJECT' '.my_key' 'my_value'

	assert_failure
	assert_output -p "Cannot set string on object"
}

@test "errors if setting string on existing object 1" {
	declare -A SUB_OBJECT=([nested]=woof)
	declare -A OBJECT=([my_key]=$'\x1C\x1Dtype=object;&SUB_OBJECT')

	run bash_object.traverse set string 'OBJECT' '.my_key' 'my_value'

	assert_failure
	assert_output -p "Cannot set string on object"
}

@test "properly sets 1" {
	declare -A OBJECT=()

	bash_object.traverse set string 'OBJECT' '.my_key' 'my_value'
	assert [ "${OBJECT[my_key]}" = 'my_value' ]

	bash_object.traverse get string 'OBJECT' '.my_key'
	assert [ "$REPLY" = 'my_value' ]
}

@test "properly sets 2" {
	declare -A OBJECT=()

	bash_object.traverse set string 'OBJECT' '.xray.yankee.zulu' 'boson'
	bash_object.traverse set string 'OBJECT' '.xray.yankee.alfa' 'lithography'

	bash_object.traverse get string 'OBJECT' '.xray.yankee.zulu'
	assert [ "$REPLY" = 'boson' ]

	bash_object.traverse get string 'OBJECT' '.xray.yankee.alfa'
	assert [ "$REPLY" = 'lithography' ]
}
