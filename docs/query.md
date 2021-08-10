# Query

Queries are modeled from `jq`'s filter mechanism. The featureset compared to `jq` is significantly less

Both quering modes listed below are are mutually exclusive. By default, the 'simple' method is used by defualt; only if your query contains a `[` will the 'advanced' method be used

# Simple query

This mode is meant to be fast, and simply splits the dot deliminated string into an array, skipping any empty elements

```sh
query='.my_key.sub_key'
# => ('my_key' 'sub_key')
```

Since this is mean to be fast, no checks are made. This means any particular query element could contain any character except `.` and `[`

```sh
query='..m!y_k@e y.....su\\]b_"ke\y'
# => ('m!y_k@e y' 'su\\]b_"ke\y')
```

Obviously, writing the query in that way is undesirable, so like `jq`, please ensure keys are made up of alphanumeric characters and underscore (while not starting with a digit)

# Advanced query

In this mode, query elements are contained within square brackets. You must use this syntax if you wish to obtain a particular index from an array

- Use quotes for strings (accessing keys in associative arrays)
  - Everything inside quotes is literal, excluding three characters that have escape sequences: `\\`, `\"`, and `\]`
- Do not use quotes for numbers (accessing indexes in indexed arrays)

```sh
query='.["my.key"].["s\\ub\"_key\]"]'
# => ('my.key' 's\ub"_key]')

query='.["my_key"].[3]'
# => ('my_key' $'\x1C3')
```

A word of caution, remember there are three different quoting behaviors (`"string"`, `'string'`, `$'string'`), some of which have escape sequences as well. I recommend surrounding queries with `''`

Lastly, the prepended `$'\x1C'` exists so `bash-object` knows the key is a number without having to re-check it. This might be removed at a later point since it's not required - it's an implementation detail so you don't have to worry about it
