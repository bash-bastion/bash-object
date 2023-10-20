# Virtual Object

Virtual objects are implemented as a string that contains some metadata and a reference to a variable. For example, in `$'\x1C\x1Dtype=array;&SUB_OBJECT'`, the metadata is `type=array`, and the reference is to the (global) variable `SUB_OBJECT`. Virtual objects always start with `$'\x1C\x1D`, to identify them amongst regular strings

The `type=<type>` may look redundant since the type can be checked without subshell creation with `${var@a}` or `${var@A}`. However, this only works on newer Bash versions. Additionally, it is faster to check the types when setting the object and then saving that data as a string, rather than re-checking the type on every access. Lastly, `bash-object` may be extended in the future to support custom objects, so a field for it in the meatdata is useful
