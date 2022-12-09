set -u

######################################################################
### run command : http://www.clear-code.com/blog/2012/10/11.html

gray=30
red=31
green=32
yellow=33
cyan=36

@colorize() {
  color=$1
  shift
  echo -e "\033[1;${color}m$@\033[0m"
}

pending() {
  echo $(@colorize $yellow "pending: $@")
}

# If arg1 is "-1", the content of stdout is also displayed in case of an error.
@run() {
  local show_stdout_when_error=0
  if [[ "$1" = "-1" ]]; then
    shift
    show_stdout_when_error=1
  fi

  rm -f run.out run.err run.exit_status
  set +e
  set -o pipefail
  "$@" 1> run.out 2> run.err
  result=$?
  set +o pipefail
  set -e
  echo $result > run.exit_status
  if [ $result -ne 0 ]; then
    echo -n $(@colorize $red "Failed: ($result) ")
    echo -n $(@colorize $cyan "$@")
    echo $(@colorize $yellow " [$PWD]")
    if [[ $show_stdout_when_error -eq 1 ]]; then
      sed -e 's/^/    /' run.out
    fi
    sed -e 's/^/    /' run.err
    exit $result
  else
    sed -e 's/^/    /' run.err
  fi
  return 0
}

@grep() {
  cp run.out run.out.grep
  @run  grep "$@" run.out.grep
}

# Compare the result of the last run with the specified string
@assert() {
  local exp=$1

  if [[ $exp =~ ^-([0-9]+)$ ]]; then
    head $exp run.out > run.exp
    shift
    exp=$1
  else
    cp run.out run.exp
  fi

  # add new line when the run.exp is empty
  if [ ! -s run.exp ]; then
    echo "" > run.exp
  fi
  
  set +e
  set -o pipefail
  INPUT="${exp}"
  diff <(echo "$INPUT") run.exp | sed 's/^/    /' > assert.out
  result=$?
  set +o pipefail
  set -e
  if [ $result -ne 0 ]
  then
    echo -n $(@colorize $red "Assertion Failed: expected ")
    echo -ne "\033[1;${cyan}m$INPUT\033[0m"
    echo $(@colorize $yellow " [$PWD]")
    echo -e "\033[1;${red}m"
    cat assert.out
    exit $result
  fi
  return 0
}

######################################################################
### test functions

describe() {
  @colorize $green "$@"
}

# If it starts with "-N", put N spaces. (default: 2)
it() {
  local n=2
  if [[ $1 =~ ^-([0-9]+)$ ]]; then
    n=${BASH_REMATCH[1]}
    shift
  fi
  if [[ $n -gt 0 ]]; then
    printf "%0.s " {1..$n}
  fi
  @colorize $cyan "$@"
}

# Guarantees that the execution of the code passed in arguments will fail.
# If the first arg is "-N", it also guarantees that the status code is "N".
@expect_error() {
  local given_code
  if [[ $1 =~ ^-([0-9]+)$ ]]; then
    given_code=${BASH_REMATCH[1]}
    shift
  else
    given_code=""
  fi

  set +e
  set -o pipefail
  #  "$@" 2>&1 | sed 's/^/    /' | sed -r "s:\x1B\[[0-9;]*[mK]::g"
  "$@" 1> run.out 2> run.err
    # sed1: indenting
    # sed2: remove ANSI colors
  result=$?
  cat run.err | sed 's/^/    /' | sed -r "s:\x1B\[[0-9;]*[mK]::g"
  set +o pipefail
  set -e

  if [ $result -eq 0 ] ; then
    echo -n $(@colorize $red "Expected failure, but succeeded: ")
    echo -n $(@colorize $cyan "$@")
    echo $(@colorize $yellow " [$PWD]")
    exit -1
  fi

  if [[ ! -z $given_code ]] && [ $result -ne $given_code ]; then
    echo -n $(@colorize $red "Expected exit code=${given_code}, but got ${result}: ")
    echo -n $(@colorize $cyan "$@")
    echo $(@colorize $yellow " [$PWD]")
    exit -1
  fi
}
