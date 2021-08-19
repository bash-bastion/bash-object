#!/usr/bin/env bats

load './util/init.sh'

@test "ERROR_VALUE_INCORRECT_TYPE on set-string'ing object" {
	declare -A SUB_OBJECT=([nested]=woof)
	declare -A OBJECT=([my_key]=$'\x1C\x1Dtype=object;&SUB_OBJECT')

	run bash_object.traverse-set string 'OBJECT' '.my_key' 'my_value'

	assert_failure
	assert_line -p "ERROR_VALUE_INCORRECT_TYPE"
	assert_output -p "to set-string, but found existing object"
}

@test "ERROR_VALUE_INCORRECT_TYPE on set-string'ing object in object" {
	declare -A SUB_OBJECT=([nested]=woof)
	declare -A OBJECT=([my_key]=$'\x1C\x1Dtype=object;&SUB_OBJECT')

	run bash_object.traverse-set string 'OBJECT' '.my_key' 'my_value'

	assert_failure
	assert_line -p "ERROR_VALUE_INCORRECT_TYPE"
	assert_output -p "to set-string, but found existing object"
}

@test "ERROR_VALUE_INCORRECT_TYPE on set-string'ing array" {
	declare -A SUB_ARRAY=(omicron pi rho)
	declare -A OBJECT=([my_key]=$'\x1C\x1Dtype=array;&SUB_ARRAY')

	run bash_object.traverse-set string 'OBJECT' '.my_key' 'my_value'

	assert_failure
	assert_line -p "ERROR_VALUE_INCORRECT_TYPE"
	assert_output -p "to set-string, but found existing array"
}

@test "ERROR_VALUE_INCORRECT_TYPE on set-string'ing array in object" {
	declare -A SUB_SUB_ARRAY=(omicron pi rho)
	declare -A SUB_OBJECT=([nested]=$'\x1C\x1Dtype=array;&SUB_SUB_ARRAY')
	declare -A OBJECT=([my_key]=$'\x1C\x1Dtype=object;&SUB_OBJECT')

	run bash_object.traverse-set string 'OBJECT' '.my_key.nested' 'my_value'

	assert_failure
	assert_line -p "ERROR_VALUE_INCORRECT_TYPE"
	assert_output -p "to set-string, but found existing array"
}

@test "correctly sets string at root" {
	declare -A OBJECT=()

	bash_object.traverse-set string 'OBJECT' '.my_key' 'my_value'
	assert [ "${OBJECT[my_key]}" = 'my_value' ]

	bash_object.traverse-get string 'OBJECT' '.my_key'
	assert [ "$REPLY" = 'my_value' ]
}

@test "correctly sets string in object" {
	declare -A SUB_OBJECT=()
	declare -A OBJECT=([tau]=$'\x1C\x1Dtype=object;&SUB_OBJECT')

	bash_object.traverse-set string 'OBJECT' '.tau.upsilon' 'phi'
	bash_object.traverse-get string 'OBJECT' '.tau.upsilon'
	assert [ "$REPLY" = 'phi' ]
}

@test "correctly sets string in object 2" {
	declare -A obj=()
	declare -A OBJECT=()

	bash_object.traverse-set object 'OBJECT' '.tau' obj

	bash_object.traverse-set string 'OBJECT' '.tau.upsilon' 'phi'
	bash_object.traverse-get string 'OBJECT' '.tau.upsilon'
	assert [ "$REPLY" = 'phi' ]
}

# @test "correctly sets string in subobject" {
# 	declare -A SUB_SUB_OBJECT=()
# 	declare -A SUB_OBJECT=([pi]=$'\x1C\x1Dtype=object;&SUB_SUB_OBJECT')
# 	declare -A OBJECT=([omicron]=$'\x1C\x1Dtype=object;&SUB_OBJECT')

# 	bash_object.traverse-set string 'OBJECT' '.omicron.pi.rho' 'sigma'
# 	bash_object.traverse-get string 'OBJECT' '.omicron.pi.rho'
# 	assert [ "$REPLY" = 'sigma' ]
# }

# @test "correctly sets string in subobject 2" {
# 	declare -A obj=()

# 	bash_object.traverse-set object 'OBJECT' '.omicron' obj
# 	bash_object.traverse-set object 'OBJECT' '.omicron.pi' obj

# 	bash_object.traverse-set string 'OBJECT' '.omicron.pi.rho' 'sigma'
# 	bash_object.traverse-get string 'OBJECT' '.omicron.pi.rho'
# 	assert [ "$REPLY" = 'sigma' ]
# }

# @test "correctly sets 2 strings in subobject" {
# 	declare -A SUB_SUB_OBJECT=()
# 	declare -A SUB_OBJECT=([pi]=$'\x1C\x1Dtype=object;&SUB_SUB_OBJECT')
# 	declare -A OBJECT=([omicron]=$'\x1C\x1Dtype=object;&SUB_OBJECT')

# 	bash_object.traverse-set string 'OBJECT' '.omicron.pi.rho' 'sigma'
# 	bash_object.traverse-set string 'OBJECT' '.omicron.pi.tau' 'upsilon'

# 	bash_object.traverse-get string 'OBJECT' '.omicron.pi.rho'
# 	assert [ "$REPLY" = 'sigma' ]

# 	bash_object.traverse-get string 'OBJECT' '.omicron.pi.tau'
# 	assert [ "$REPLY" = 'upsilon' ]

# 	bash_object.traverse-get object 'OBJECT' '.omicron.pi'

# 	assert [ "${REPLY[rho]}" = 'sigma' ]
# 	assert [ "${REPLY[tau]}" = 'upsilon' ]
# }

# @test "correctly sets 2 strings in subobject 2" {
# 	declare -A obj=()

# 	bash_object.traverse-set object 'OBJECT' '.omicron' obj
# 	bash_object.traverse-set object 'OBJECT' '.omicron.pi' obj

# 	bash_object.traverse-set string 'OBJECT' '.omicron.pi.rho' 'sigma'
# 	bash_object.traverse-set string 'OBJECT' '.omicron.pi.tau' 'upsilon'

# 	bash_object.traverse-get string 'OBJECT' '.omicron.pi.rho'
# 	assert [ "$REPLY" = 'sigma' ]

# 	bash_object.traverse-get string 'OBJECT' '.omicron.pi.tau'
# 	assert [ "$REPLY" = 'upsilon' ]

# 	bash_object.traverse-get object 'OBJECT' '.omicron.pi'

# 	assert [ "${REPLY[rho]}" = 'sigma' ]
# 	assert [ "${REPLY[tau]}" = 'upsilon' ]
# }
