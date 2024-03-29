#!/usr/bin/env bash

AUTIFY="${INPUT_AUTIFY_PATH}"

ACCESS_TOKEN="${!INPUT_ACCESS_TOKEN}"

if [ -z "${ACCESS_TOKEN}" ]; then
  echo "Missing access-token."
  exit 1
fi

ARGS=()

function add_args() {
  ARGS+=("$1")
}

if [ -n "${INPUT_AUTIFY_TEST_URL}" ]; then
  add_args "${INPUT_AUTIFY_TEST_URL}"
else
  echo "Missing autify-test-url."
  exit 1
fi

if [ "${INPUT_VERBOSE}" -eq 1 ]; then
  add_args "--verbose"
fi

if [ "${INPUT_WAIT}" -eq 1 ]; then
  add_args "--wait"
fi

if [ "${INPUT_TIMEOUT}" -ne -1 ]; then
  add_args "-t=${INPUT_TIMEOUT}"
fi

if [ -n "${INPUT_URL_REPLACEMENTS}" ]; then
  IFS=',' read -ra URL_REPLACEMENTS <<< "${INPUT_URL_REPLACEMENTS}"
  for url_replacement in "${URL_REPLACEMENTS[@]}"; do
    add_args "-r=${url_replacement}"
  done
fi

if [ "${INPUT_MAX_RETRY_COUNT}" -ne -1 ]; then
  add_args "--max-retry-count=${INPUT_MAX_RETRY_COUNT}"
fi

if [ -n "${INPUT_TEST_EXECUTION_NAME}" ]; then
  add_args "--name=${INPUT_TEST_EXECUTION_NAME}"
fi

if [ -n "${INPUT_BROWSER}" ]; then
  add_args "--browser=${INPUT_BROWSER}"
fi

if [ -n "${INPUT_DEVICE}" ]; then
  add_args "--device=${INPUT_DEVICE}"
fi

if [ -n "${INPUT_DEVICE_TYPE}" ]; then
  add_args "--device-type=${INPUT_DEVICE_TYPE}"
fi

if [ -n "${INPUT_OS}" ]; then
  add_args "--os=${INPUT_OS}"
fi

if [ -n "${INPUT_OS_VERSION}" ]; then
  add_args "--os-version=${INPUT_OS_VERSION}"
fi

if [ -n "${INPUT_AUTIFY_CONNECT}" ]; then
  add_args "--autify-connect=${INPUT_AUTIFY_CONNECT}"
fi

if [ "${INPUT_AUTIFY_CONNECT_CLIENT}" -eq 1 ]; then
  add_args "--autify-connect-client"
fi

if [ -n "${INPUT_AUTIFY_CONNECT_CLIENT_EXTRA_ARGUMENTS}" ]; then
  add_args "--autify-connect-client-extra-arguments=${INPUT_AUTIFY_CONNECT_CLIENT_EXTRA_ARGUMENTS}"
fi

export AUTIFY_CLI_USER_AGENT_SUFFIX="${AUTIFY_CLI_USER_AGENT_SUFFIX:=circleci-orb-web-test-run}"

AUTIFY_WEB_ACCESS_TOKEN="${ACCESS_TOKEN}" "${AUTIFY}" web test run "${ARGS[@]}"
