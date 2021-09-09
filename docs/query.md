# Query

Queries are similar to `jq`'s filter mechanism

Both quering modes listed below are are mutually exclusive. By default, the 'simple' method is used by default. The parser will automatically switch to 'advanced' mode if your query contains a `[`

A word of caution, remember there are three different quoting behaviors within Bash itself (`"string"`, `'string'`, `$'string'`), some of which have escape sequences as well. I recommend surrounding queries with `''` where possible

## Simple query

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

Obviously, writing the query in that way is highly undesirable, so like `jq`, _please_ ensure keys are made up of alphanumeric characters and underscores (without starting with a digit)

## Advanced query

In this mode, all query elements are contained within square brackets. You must use this syntax if you wish to obtain a particular index from an array

The rules follow

- Use quotes for strings (accessing keys in associative arrays)
  - Everything inside quotes is literal, excluding three characters that have escape sequences: `\\`, `\"`, and `\]`
  - The string _cannot_ begin with `$'\x1C'`, as that is how `bash-object` differentiates between a string and a number
- Do not use quotes for numbers (accessing indexes in indexed arrays)

```sh
query='.["my.key"].["s\\ub\"_key\]"]'
# => ('my.key' 's\ub"_key]')

query='.["my_key"].[3]'
# => ('my_key' $'\x1C3')
```

## Invalid queries

The following query is invalid because it mixes the 'simple' and 'advanced' query types within the same query

```sh
query='.my_key.[3]'
```
