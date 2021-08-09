# Marshaling

Unmarshaling highly structured data in Bash in a reliable and easy to use way has historically been impossible - until now

The following examples will use JSON format, which represents the data we wish to encode in-memory in Bash

## Precursor

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

`bash-object` solves this problem, at the most general level. The repository contains a methodology for storing these constructs in memory as well as functions for accessing and setting these values

Let's take a look at the most basic case

```json
{
	"stars": {
		"cool": "Wolf 359"
	}
}
```

It will be stored in the following way

The key will be the respective key on the respective parent object
The value will be the following

- Each property of the object is stored, deliminated by the null character
- This is called a virtual object
```txt
# \0key=value;key1=value2;&refff\0type=string;&refff\0
```

<!-- ```sh
assert [ "${OBJECT[stars]}" = 'type=object;#__bash_object_<objectName>_<keyName>_<randomNumber>_<fileNameAtCallSite>_<randomNumber>' ]
assert [ "${__bash_object_<objectName>_<keyName>_<randomNumber>_<fileNameAtCallSite>_<randomNumber>[cool]}" = 'Wolf 359' ]
``` -->

TODO: fileNameAtCallSite should perhaps be modified and make it per-package

More specifically, given a consumer of the library

```sh
# consumer.sh
declare -A innerArr=([cool]='Wolf 359')

bash_object.do-object-set 'OBJECT' 'object' '.stars' "${innerArr[@]}"

# 'innerArr' has now been copied into an associate array (in the global context) called (remember, numbers are _random_)
# '__bash_object_OBJECT_cool_4093202_consumersh_5232020'

unset innerArr

# We can now access the array
bash_object.do-object-get 'OBJECT' 'string' '.stars.cool'
echo "$REPLY"
# => Wolf 359
```

In both cases, the 'object' is optional and can be inferred from the passed arguments. However, passing it gives extra validation that the data is of the correct type. It is recommended to pass the type whenever doing operatings to prevent unexpected results
