# Bash Scripting

---

Include the following at the start of your `.sh` script.

The options below do the following

- `errexit` - Exit immediately if a pipeline (…) returns a non-zero status.
- `nounset` - Return an error code if a variable is not set and its value is attempted to be read.

```#bash
#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail
```

A Shorthand way to write the above is like this

```#bash
#!/usr/bin/env bash

set -euxo pipefail
```

`-e` - Shorthand for `errexit`
`-u` - Shorthand for `onunset`
`-x` - Prints each command to the terminal before running it (Can be disabled with `set -x`)

I recommend the following page for further reading https://www.gnu.org/software/bash/manual/html_node/The-Set-Builtin.html

---

## Detecting the shell script is being called from

When writing cross platform scripts such as those for MacOS and Linux we want to ensure that we can detect the shell and act occordingly, using the following snippet we can achieve this:

```#bash
CURRENT_BASH=$(ps -p $$ | awk '{ print $4 }' | tail -n 1)
case "${CURRENT_BASH}" in
-zsh | zsh)
  CURRENT_DIR=$(cd "$(dirname "${0}")" && pwd)
  ;;
-bash | bash)
  CURRENT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
  ;;
*)
  echo 1>&2
  echo -e "\033[0;31m\`${CURRENT_BASH}\` does not seems to be supported\033[0m" 1>&2
  echo 1>&2
  return 1
  ;;
esac
```

---

## Making command-like bash scripts

In bash we can define methods, its normal to have a `main()` method that ties your program together:

```#bash
main() {
    //your code here
}
```

From there we need to be able to run that main command using:

`main "${@}"` - Will act as the entrypoint of a command, include this at the bottom of a script.

---

Defining and passing in commands

Within our `main()` function we can detect and execute various commands that we set through the use of a simple loop

```#bash
main() {
 if [ $# -eq 1 ]; then
    readonly command=${1:-'help'}
 fi
 case ${command} in
 help)
    usage
    ;;
  our-cool-command)
    our-cool-command()
    ;;
  *)
    if [ -z "$*" ]; then
      printf '\e[4;33mWARN: No ARGs given %s\n\e[0m' >&2
    else
      printf '\e[4;33mWARN: Unknown arg : %s\n\e[0m' "${command}" >&2
    fi

    usage
    exit 1
    ;;
  esac
}
 
```

In the above function we run a case statement on `${command}` - We get the command through use of the entrypoint `main ${@}` which we discussed earlier.

Specifically `${@}` allows us to take in user input;

Before the case statment do a check for for the total number of arguments (`$#`) and make sure its equal (`-eq` or `==`) to `1`.
We then assign the result into a readonly variable called `command` 

Notice the assignment of `command=${1:-'help'}`, we are using a concept known Parameter Expansion, to check for the existance of `1` and then assigning `help` if it isn't set.

The final case `*)` is our catch all if previous cases are not matched.

We do a check to see if arguments are an empty string using `if [ -z "$*" ]; then`

Finaly we call a `usage()` method which prints out a list of commands we accept and briefly explains their usage.

---

If you would like to see a full example of a script such as describe above check my [global-functions.sh example](examples/global-functions.sh)

To be continued :)
