#!/usr/bin/env bats

load './util/init.sh'

# @test "Correctly get-object --ref" {
# 	declare -A OBJECT=()
# 	declare -A obj=([upsilon]=phi [alfa]=beta)

# 	bobject set-object --ref 'OBJECT' '.obj' obj
# 	bobject get-object --ref 'OBJECT' '.obj'
# 	assert [ "${REPLY[upsilon]}" = phi ]
# 	assert [ "${REPLY[alfa]}" = beta ]

# 	# REPLY[upsilon]=omega
# 	bobject get-object --value 'OBJECT' '.obj'
# 	echo sssss "${!REPLY[@]}" >&3
# 	assert [ "${REPLY[upsilon]}" = phi ]
# }

# @test "Correctly get-array --ref" {
# 	declare -A OBJECT=()
# 	declare -a arr=(seven eight nine ten)

# 	bobject set-array --ref 'OBJECT' '.obj' str
# 	bobject get-array --ref 'OBJECT' '.obj'
# 	assert [ "${REPLY[1]}" = eight ]
# 	assert [ "${REPLY[2]}" = nine ]
# }

# @test "Correctly get-string --value" {
# 	declare -A OBJECT=()
# 	str='woof'

# 	bobject set-string --ref 'OBJECT' '.obj' str

# 	bobject get-string --value 'OBJECT' '.obj'
# 	assert [ "$REPLY" = eight ]
# }
