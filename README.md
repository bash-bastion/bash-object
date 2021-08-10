# bash-object

Bash library for imperatively constructing and deconstructing data structures in pure Bash

This is meant to be a low level API providing primitives for libraries. My own `bash-toml` and `bash-json` Bash parsers will use this library

## Summary

```sh
# {
#   "alfa": {
#     "bravo": {
#       "charlie": {
#         "delta": {
#           "echo": "final_value"
#         }
#       }
#     }
#   }
# }

# Imperatively declaring the above JSON
# TODO: Update this when 'do-object-set' is implemented
declare -A obj_echo=([echo]="final_value")
declare -A obj_delta=([delta]="!'\`\"!type=string;&obj_echo")
declare -A obj_charlie=([charlie]="!'\`\"!type=string;&obj_delta")
declare -A obj_bravo=([bravo]="!'\`\"!type=string;&obj_charlie")
declare -A OBJ=([alfa]="!'\`\"!type=string;&obj_bravo")

bash_object.traverse get object 'OBJ' '.alfa.bravo.charlie.delta.echo'
assert [ "$REPLY" = 'final_value' ]
```

## Installation

STATUS: IN DEVELOPMENT!

```sh
# With bpm (recommended)
bpm --global install hyperupcall/bash-object

# With Git
```
