#! /usr/bin/env bash

set -o errexit || exit
set -o nounset
set -o pipefail

# Guard dependencies
>/dev/null type vim
>/dev/null type nvim
>/dev/null type diff

# Change directory to the directory of this script
DIR=$(dirname -- "${BASH_SOURCE[0]}")
cd -- "$DIR"

tests_total=0
tests_failed=0
tests_failed_names=()

for test_dir in test???; do
  TEST_NAME=$(basename -- "$test_dir")
  (( tests_total+=1 ))
  >/dev/null pushd -- "$test_dir"

  printf 'Running %s...\n' "$TEST_NAME"
  nvim --headless -s test.vim test.hs 2>/dev/null

  if diff expected.hs result.hs; then
    printf '%s succeded\n' "$TEST_NAME"
    rm result.hs
  else
    >&2 printf '%s failed!\n' "$TEST_NAME"
    (( tests_failed+=1 ))
    tests_failed_names+=("$TEST_NAME")
  fi

  >/dev/null popd
done

if (( tests_failed > 0 )); then
  TESTS_FAILED_NAMES_AS_STR="${tests_failed_names[*]}"
  >&2 printf \
    '%d of %d tests (%s) have FAILED!\n' \
    "$tests_failed" \
    "$tests_total" \
    "${TESTS_FAILED_NAMES_AS_STR// /, }"
  exit 1
fi

echo SUCCESS
