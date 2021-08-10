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
declare -A zulu_object([yankee]=)
declare -A yankee_object=([xray]=)
declare -A xray_object([whiskey]=victor [foxtrot]=)
declare -A foxtrot_array=(omicron pi rho sigma)

bobject set-object root_object '.zulu' zulu_object
bobject set-object root_object '.zulu.yankee' yankee_object
bobject set-object root_object '.zulu.yankee.xray' xray_object
bobject set-string root_object '.zulu.yankee.xray.foxtrot' foxtrot_array

bobject get-string '.zulu.yankee.xray.whiskey'
assert [ "$REPLY" = victor ]

bobject get-array '.zulu.yankee.xray.victor'
assert [ ${#REPLY} -eq 4 ]

bobject get-string '.["zulu"].["yankee"].["xray"].["victor"].[2]'
assert [ "$REPLY" = 'rho' ]
```

## Installation

STATUS: IN DEVELOPMENT! (right now, there are _many_ known bugs)

```sh
# With bpm (highly recommended)
bpm --global install hyperupcall/bash-object
```
