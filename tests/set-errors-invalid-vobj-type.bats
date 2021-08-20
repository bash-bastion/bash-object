#!/usr/bin/env bats

# @brief Ensures errors are thrown when the type of the vobject
# does not match up with the specified type (as in set-array, set-object, etc.). This can occur if a vobject already exists, but
# it is the wrong type

load './util/init.sh'
