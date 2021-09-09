# Interface

The `bobject` command generally allows you to 'set' and 'get' different types of variables from some object hierarchy (think JSON object)

## `bobject get-*`

Get operations have two mutually exclusive modes, specified with either `--ref` or `--value` as flags. If you are not sure which to use, pass `--value`

### ref

In ref mode, `REPLY` is a string that is set with the value of the global variable that contains the content you queried for. This functionality is not yet implemented

### value

In value mode, the `REPLY` contains the actual value you want

## `bobject-set-*`

Set operations have two mutually exclusive modes, specified with either `--ref` or `--value` as flags. If you are not sure which to use, pass `--ref`

### ref

In ref mode, a third argument is passed, which is a string that is set to the name of a variable. When setting a field in the object hierarchy, the contents of that particular variable is copied into the hierarchy

### value

In value mode, there is no third argument. After supplying the first two arguments, add `--`, then supply whatever value you want to be used when setting a field in the object hierarchy. This works with variable types `string`, `array`, and `object`
