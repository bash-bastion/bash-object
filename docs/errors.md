# Errors

Because Bash often does the wrong thing silently, it's important to fail early when any inputs are unexpected. Extra checks that require spawning subshells require setting the `VERIFY_BASH_OBJECT` variable. We recommend exporting it so any child Bash processes keep the verification behavior

The following checks are performed

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
