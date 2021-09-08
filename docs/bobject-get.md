# bobject-get

The get family of bobject subcommands generally operate in two modes: ref and value

# TODO: ensure string is ref and not just a ref of a copy of the original ref (behavior same as array/object)

### ref

In ref mode, `REPLY` is a string with the value of the global variable that contains the content you queried for.

### value

In value mode, the `REPLY` contains the actual value you want (object, array, or string).

Currently, only 'value' mode is implemented. PR's welcome for 'ref' mode
