# bash-object

The _first_ Bash library for imperatively constructing data of nested and heterogeneous form

This is meant to be a low level API providing primitives for other libraries.

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
```

## Installation

```sh
printf '%s\n' "dependencies = [ 'hyperupcall/bash-object' ]" > 'basalt.toml'
basalt install
```
