# Unmarshaling

Unmarshaling strings representing highly structured data in Bash in a reliable and easy to use way has historically been impossible - until now

The following examples will use JSON format, which represents the data that Bash will encode in-memory

## Motivation

Bash allows for simple/flat mapping via an associative array

```json
{
	"atom": "Hydrogen"
}
```

```bash
assert [ "${OBJECT[atom]}" = 'Hydrogen' ]
```

But, when it comes to even the slightest of more complicated structures, Bash cannot cope: associative arrays do not nest inside one another

```json
{
	"stars": {
		"cool": "Wolf 359"
	}
}
```

Note only that, but indexed arrays cannot nest inside associative arrays

```json
{
	"nearby": [
		"Alpha Centauri A",
		"Alpha Centauri B",
		"Proxima Centauri",
		"Barnard's Star",
		"Luhman 16"
	]
}
```

## Solution

`bash-object` solves this problem, in the most general case. The repository contains functions for storing and retreiving strings, indexed arrays, and associative arrays in a heterogenous hierarchy

Let's take a look at the most basic case

```json
{
	"xray": {
		"yankee": "zulu"
	}
}
```

In Bash, it will be stored in memory eventually using declarations similar to the following

```sh
declare -A unique_global_variable_xray=([yankee]='zulu')
declare -A OBJECT=([xray]=$'\x1C\x1Dtype=object;&unique_global_variable_xray')
```

You can retrieve the data with

```sh
bobject get-object --value 'OBJECT' 'xray'
assert [ "${REPLY[yankee]}" = zulu ]
```

The implementation hinges on Bash's `declare -n`. When using `get-object`, this is what would happen behind the scenes at the lowest level

```sh
local current_object_name='unique_global_variable_xray'
local -n current_object="$current_object_name"

declare -gA REPLY=()
local key=
for key in "${!current_object[@]}"; do
	REPLY["$key"]="${current_object["$key"]}"
done
```

Another implementation detail is how a new variable is created in the global scope. This can occur when you are setting an array (indexed array) or object (associative array) at some place in the object hierarchy. In the previous example, `unique_global_variable_xray` is the new variable created in the global scope; in practice, the name looks a lot different, as seen in the example below

```sh
local global_object_name=
printf -v global_object_name '%q' "__bash_object_${root_object_name}_${root_object_query}_${RANDOM}_${RANDOM}"

if ! eval "declare -gA $global_object_name=()"; then
	bash_object.util.die 'ERROR_INTERNAL' 'Eval declare failed'
	return
fi
```

Unfortunately, it must use eval, but the `%q` should properly escape any escape sequences, since `root_object_name` and `root_object_query` are user-defined
