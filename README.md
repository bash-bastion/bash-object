# bash-object

The _first_ Bash library for imperatively constructing heterogenously hierarchical data structures

This is meant to be a low level API providing primitives for other libraries.

In the coming days, I will release never seen before parsers written in Bash called [bash-toml](https://github.com/hyperupcall/bash-toml) and [bash-json](https://github.com/hyperupcall/bash-json) that use this library

## Exhibition

```sh
# How to represent the following in Bash?
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

declare -A root_object=()
declare -A zulu_object=()
declare -A yankee_object=()
declare -A xray_object=([whiskey]=victor)
declare -a foxtrot_array=(omicron pi rho sigma)

bobject set-object --by-ref root_object '.zulu' zulu_object
bobject set-object --by-ref root_object '.zulu.yankee' yankee_object
bobject set-object --by-ref root_object '.zulu.yankee.xray' xray_object
bobject set-array --by-ref root_object '.zulu.yankee.xray.foxtrot' foxtrot_array

bobject get-object root_object '.zulu.yankee.xray'
assert [ "${REPLY[whiskey]}" = victor ]

bobject get-string root_object '.zulu.yankee.xray.whiskey'
assert [ "$REPLY" = victor ]

bobject get-array root_object '.zulu.yankee.xray.foxtrot'
assert [ ${#REPLY[@]} -eq 4 ]

bobject get-string root_object '.["zulu"].["yankee"].["xray"].["foxtrot"].[2]'
assert [ "$REPLY" = rho ]
```

## Installation

STATUS: ALPHA

```sh
echo "dependencies = [ 'hyperupcall/bash-object' ]" > 'bpm.toml'
bpm install
```

## TODO
- error on invalid references (`type=object` in virtual object metadata, when it is referencing an array)
- ensure error (for set primarily) if the virtual object references a variable that does not exist
- "queried for X, but found existing object": print object in error (same with indexed arrays)
--reply-with-value
