# bash-object

The first and only Bash library for manipulating heterogenous data hierarchies. This is meant to be a low level API providing primitives for other libraries.

## Exhibition

```sh
# Problem: How to represent the following in Bash?

# {
#   "zulu": {
#     "yankee": {
#       "xray": {
#         "whiskey": "victor",
#         "foxtrot": ["omicron", "pi", "rho", "sigma"]
#       }
#     }
#   }
# }


# Solution: Use bash-object to construct the hierarchy

declare -A root_object=()
declare -A zulu_object=()
declare -A yankee_object=()
declare -A xray_object=([whiskey]=victor)
declare -a foxtrot_array=(omicron pi rho sigma)

bobject set-object --ref root_object '.zulu' zulu_object
bobject set-object --ref root_object '.zulu.yankee' yankee_object
bobject set-object --ref root_object '.zulu.yankee.xray' xray_object
bobject set-array --ref root_object '.zulu.yankee.xray.foxtrot' foxtrot_array

bobject get-object --value root_object '.zulu.yankee.xray'
assert [ "${REPLY[whiskey]}" = victor ]

bobject get-string --value root_object '.zulu.yankee.xray.whiskey'
assert [ "$REPLY" = victor ]

bobject get-array --value root_object '.zulu.yankee.xray.foxtrot'
assert [ ${#REPLY[@]} -eq 4 ]

bobject get-string --value root_object '.["zulu"].["yankee"].["xray"].["foxtrot"].[2]'
assert [ "$REPLY" = rho ]

bobject.print 'root_object'
# |__ zulu (__bash_object_root_object___zulu_24092_8313_29963_14301_14535)
#    |__ yankee (__bash_object_root_object___zulu_yankee_15383_14163_12814_23488_13779)
#       |__ xray (__bash_object_root_object___zulu_yankee_xray_18071_28791_7790_539_19231)
#          |__ whiskey
#          |__ foxtrot (__bash_object_root_object___zulu_yankee_xray_foxtrot_26606_15833_10655_7208_16587)
#             |- omicron
#             |- pi
#             |- rho
#             |- sigma
```

## Installation

Use [Basalt](https://github.com/hyperupcall/basalt), a Bash package manager, to add this project as a dependency

```sh
basalt add hyperupcall/bash-object
```
