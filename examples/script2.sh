#!/usr/bin/env bash
set -eo pipefail

eval "$(basalt-package-init)"
basalt.package-init
basalt.package-load

BASH_OBJECT_FORCE_SET=yes
VERIFY_BASH_OBJECT=

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

bobject.print 'root_object'
