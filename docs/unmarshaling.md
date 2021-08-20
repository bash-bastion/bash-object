# Unmarshaling

Unmarshaling strings representing highly structured data in Bash in a reliable and easy to use way has historically been impossible - until now

The following examples will use JSON format, which represents the data we wish to encode in-memory in Bash

## Motivation

Bash allows for simple mapping via an associative array

```json
{
	"atom": "Hydrogen"
}
```

```bash
assert [ "${OBJECT[atom]}" = 'Hydrogen' ]
```

But, when it comes to even the slightest of more complicated structures, Bash cannot cope: Associative arrays do not nest inside one another

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

`bash-object` solves this problem, at the most general level. The repository contains a functions for storing and retreiving strings, indexed arrays, and associative arrays in a heterogenous hierarchy

Let's take a look at the most basic case

```json
{
	"xray": {
		"yankee": "zulu"
	}
}
```

It will be stored in the following way

```sh
declare -A unique_global_variable_xray=([yankee]='zulu')
declare -A OBJECT=([xray]=$'\x1C\x1Dtype=object;&unique_global_variable_xray')
```

You can retrieve the data with

```sh
bobject get-object --as-value 'OBJECT' 'xray'
assert [ "${REPLY[yankee]}" = zulu ]
```

The implementation hinges on Bash's `declare -n`. This is what would happen behind the scenes at the lowest level

```sh
local current_object_name='unique_global_variable_xray'
local -n current_object="$current_object_name"

REPLY=("${current_object[@]}")
```
