# Errors

Because Bash often does the wrong thing silently, it's important to fail early. This page documents the types of errors `bash-object` catches when using its functionality

Export the `VERIFY_BASH_OBJECT` variable if you want to perform extra validation checks on input. On newer Bash versions this will incur little overhead; on older ones this will spawn subshells (which is why it's not by default enabled)

## Error Categories

Generally, there are three categories of errors

### 1. Arguments

Prefixed with `ERROR_ARGUMENTS_`, these error codes will show when there is something wrong with the passed flags or arguments. We will check to ensure the correct number of arguments have been passed (and are non empty). Additionally, we will ensure that the passed arguments have continuity with whatever you reference. For example, if you want to `--ref set-object`, we will ensure that the variable you specify is a defined variable, and actually is an object (associative array). Another example, if you wish to `set` or `get` a variable, it will check to ensure the variable at the place you specify with the querystring is the same type as you specified as an argument (e.g. `set-array`)

### 2. Querytree

Prefixed with `ERROR_QUERYTREE_`, these error codes will show when there is something wrong with parsing the querytree, namely syntax errors. A message associated with the error code will specify why the querytree couldn't be fixed, along with possible solutions

### 3. Virtual objects

Prefixed with `ERROR_VOBJ_`, these error codes will show when the virtual object does not match up with its reference. For example, if a virtual object looks like `$'\x1C\x1Dtype=array;&SUB_OBJECT'`, an error will show because it is referencing an object with the variable name `SUB_OBJECT`, but `type=array` is specified
