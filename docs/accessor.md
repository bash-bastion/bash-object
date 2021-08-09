# Filter

Filters are modeled from `jq`'s filter mechanism. Although, the featureset has heavily been reduced

Both accessing modes require you to use the access methods homogenously for any particular list of repeated accessors - in other words, they are mutually exclusive for each property accessor in the filter

An internal representation is listed as a comment under each filter

If multiple flags are passed, the last one "wins"

# Normal accessing

To keep things fast, there is a fast mode, allows you to get nested values, separated by periods. Pass `--simple` or `-s` to activate this method

```sh
filter='.my_key.sub_key'
# => ('my_key' 'sub_key')
```

Note that unlike JQ, this fast mode works with ANY key characters, as long as they are not a period. Everything is interpreted as is - no escaping is done

```sh
filter='.m!y_k@e y.su\\b_"ke\y'
# => ('m!y_k@e y' 'su\\b_"ke\y')
```

Obviously, writing in the previous syntax is undesirable, so please use the below option

# More advanced accessing

Accessors are contained within brackets. You must use this syntax if you wish to obtain a particular element from an array. Pass `--advanced` or `-a` to activate this method

- Put quotes around strings
- Don't use quotes for numbers
- Everything contained within the brackets or quotes is interpreted as is (excluding quotes and brackets)
- Use the following escape sequences when writing a string: `\\`, `\"`, and `\]`

```sh
filter='.["my.key"].["sub_key"]'
# => ('my.key' 'sub_key')

filter='.["my_key"].[3]'
# => ('my_key' $'\x1C3')
```

# Other accessing

You might have noticed that both methods of activating require an option. This is because both are completely abysmal and horrifyingly gross. It would be good to have a nice, fast default if both are possible or rework both methods under a new flag name (and optionall make one the default)
