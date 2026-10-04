#!/bin/sh
# Invoke the official tester directly; make test builds both binaries first.
set -eu
cd "$(dirname "$0")/.."
project_dir=$(pwd -P)

# Required by Codecrafters test suite
export CODECRAFTERS_REPOSITORY_DIR="$project_dir"
export CODECRAFTERS_SUBMISSION_DIR="$project_dir"

# Prepare test cases to run with the helper
CODECRAFTERS_TEST_CASES_JSON=$(python3 ci/stages.py)
export CODECRAFTERS_TEST_CASES_JSON
printf 'Required stages: %s\n' "$CODECRAFTERS_TEST_CASES_JSON"

# Required by personal test harness
export REDIS_BIN="$project_dir/build/redis"

exec "$project_dir/build/redis-tester"
