#!/usr/bin/env bash

log_file=$(dirname "$0")/log


function before() {
  export ACCESS_TOKEN=test
  unset INPUT_AUTIFY_PATH
  unset INPUT_ACCESS_TOKEN
  unset INPUT_AUTIFY_TEST_URL
  export INPUT_VERBOSE=0
  export INPUT_WAIT=0
  unset INPUT_TIMEOUT
  unset INPUT_URL_REPLACEMENTS
  unset INPUT_MAX_RETRY_COUNT
  unset INPUT_TEST_EXECUTION_NAME
  unset INPUT_BROWSER
  unset INPUT_DEVICE
  unset INPUT_DEVICE_TYPE
  unset INPUT_OS
  unset INPUT_OS_VERSION
  unset INPUT_AUTIFY_CONNECT
  export INPUT_AUTIFY_CONNECT_CLIENT=0
  unset INPUT_AUTIFY_CONNECT_CLIENT_EXTRA_ARGUMENTS
  echo "=== TEST ==="
}

function test_command() {
  local expected=$1
  local result
  result=$(bash ./src/scripts/test-run.sh | head -1)

  if [ "$result" == "$expected" ]; then
    echo "Passed command: $expected"
  else
    echo "Failed command:"
    echo "  Expected: $expected"
    echo "  Result  : $result"
    exit 1
  fi
}

function test_code() {
  local expected=$1
  bash ./src/scripts/test-run.sh > /dev/null
  local result=$?

  if [ "$result" == "$expected" ]; then
    echo "Passed code: $expected"
  else
    echo "Failed code:"
    echo "  Expected: $expected"
    echo "  Result  : $result"
    exit 1
  fi
}

function test_log() {
  local result
  result=$(mktemp)
  bash ./src/scripts/test-run.sh | tail -n+2 > "$result"

  if (git diff --no-index --quiet -- "$log_file" "$result"); then
    echo "Passed log:"
  else
    echo "Failed log:"
    git --no-pager diff --no-index -- "$log_file" "$result"
    exit 1
  fi
}

{
  before
  export INPUT_AUTIFY_PATH="./test/autify-mock"
  export INPUT_ACCESS_TOKEN=ACCESS_TOKEN
  export INPUT_AUTIFY_TEST_URL=a
  test_command "autify web test run a"
  test_code 0
  test_log
}

{
  before
  export INPUT_AUTIFY_PATH="./test/autify-mock"
  export INPUT_ACCESS_TOKEN=ACCESS_TOKEN
  export INPUT_AUTIFY_TEST_URL=a
  export INPUT_VERBOSE=1
  export INPUT_WAIT=1
  export INPUT_TIMEOUT=300
  export INPUT_URL_REPLACEMENTS="https://example.com https://example.net,https://example.net https://example.com?foo=bar"
  export INPUT_MAX_RETRY_COUNT=1
  export INPUT_TEST_EXECUTION_NAME=d
  export INPUT_BROWSER=e
  export INPUT_DEVICE=f
  export INPUT_DEVICE_TYPE=g
  export INPUT_OS=h
  export INPUT_OS_VERSION=i
  export INPUT_AUTIFY_CONNECT=j
  export INPUT_AUTIFY_CONNECT_CLIENT=1
  export INPUT_AUTIFY_CONNECT_CLIENT_EXTRA_ARGUMENTS=k
  test_command "autify web test run a --verbose --wait -t=300 -r=\"https://example.com https://example.net\" -r=\"https://example.net https://example.com?foo=bar\" --max-retry-count=1 --name=d --browser=e --device=f --device-type=g --os=h --os-version=i --autify-connect=j --autify-connect-client --autify-connect-client-extra-arguments=k"
  test_code 0
  test_log
}

{
  before
  export INPUT_AUTIFY_PATH="./test/autify-mock-fail"
  export INPUT_ACCESS_TOKEN=ACCESS_TOKEN
  export INPUT_AUTIFY_TEST_URL=a
  test_command "autify-fail web test run a"
  test_code 1
  test_log
}
