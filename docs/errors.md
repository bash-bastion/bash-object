# Errors

Depending on your operation, your object transaction may fail. This details the reasons

In this context, value means either "member of object" or "index of array"

## Get

- `ERROR_NOT_FOUND`
  - Attempted to access a value that does not exist
- `ERROR_VALUE_INCORRECT_TYPE`
  - Attempted to access a value that has the wrong type. This can happen if the query uses `.[30]` to get an array index, but an object exists instead. It can also happen if the user writes `get-string`, and it found a non-string value after evaluating the query. It can also happen if the user writes `set-string`, and the place to write the new value already has a value of a different type
- `ERROR_VOBJ_INVALID_TYPE`
  - The virtual object (a string that contains a reference to the real global object) had keys with unexpected values. You shouldn't get this error unless something has seriously gone wrong

# Handling

Because Bash often does the wrong thing silently, it's important to fail early when any inputs are unexpected. `bash-object` does this at every level

Below, if any of the assurances do not pass, `bash-object` will fail with a non-zero exit code. For some of these, `VERIFY_BASH_OBJECT` must be a variable


1. Argument parsing

- Ensures the correct number of arguments are passed (when applicable)
- Ensures the arguments are not empty (when applicable)
- Ensures applicable arguments refers to real variables (ex. the root object in both set/get, and the final_value for set)
- Ensure applicable arguments refer to variables of the same type (for set)

2. Query parsing

- Ensures the query has the correct form

3. Tree traversing

- Ensure type specified in the virtual object matches that of the referenced object
- Ensure type implied in query string matches the one specified in the virtual object

4. Final operation (set/get)

- Ensure type specified in the virtual object matches that of the referenced object
- Ensure type implied in query string matches the one specified in the virtual object
- Ensure type specified in set/get matches the one specified in the virtual object
