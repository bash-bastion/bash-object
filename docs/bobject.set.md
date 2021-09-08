# bobject-set

The set family of bobject subcommands generally operate in two modes: ref and value

### ref

In ref mode, the third argument is a string that is the name of a variable that you want to use to set

### value

In value mode, there is no "third argument". After supplying the root object and the querytree, you pass `--`, and supply your value after the double hyphen. You can supply strings, arrays, and objects
