# Errors

Depending on your operation, your object transaction may fail. This details the reasons

In this context, value means either "member of object" or "index of array"

## Get

- `ERROR_VALUE_NOT_FOUND`
  - Attempted to access a value that does not exist
- `ERROR_VALUE_INCORRECT_TYPE`
  - Attempted to access a value that has the wrong type. This can happen if the query uses `.[30]` to get an array index, but an object exists instead. It can also happen if the user writes `get-string`, and it found a non-string value after evaluating the query. It can also happen if the user writes `set-string`, and the place to write the new value already has a value of a different type
- `ERROR_INTERNAL_INVALID_VOBJ`
  - The virtual object (a string that contains a reference to the real global object) had keys with unexpected values. You shouldn't get this error unless something has seriously gone wrong
