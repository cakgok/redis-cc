#!/bin/sh

# Check out the official tester at the committed version.
set -eu
cd "$(dirname "$0")/.."
project_dir=$(pwd -P)

. "$project_dir/vendor/redis-tester.version"
tester_dir="$project_dir/vendor/redis-tester"

if [ ! -e "$tester_dir/.git" ]; then
    if [ -e "$tester_dir" ]; then
        printf 'Move %s aside first: it is not a Git checkout.\n' "$tester_dir" >&2
        exit 1
    fi

    mkdir -p "$tester_dir"
    git -C "$tester_dir" init --quiet
    git -C "$tester_dir" remote add origin "$repository"
fi

if [ -n "$(git -C "$tester_dir" status --porcelain)" ]; then
    printf 'Tester checkout has local changes: %s\n' "$tester_dir" >&2
    exit 1
fi

current_commit=$(git -C "$tester_dir" rev-parse --verify HEAD 2>/dev/null || true)
if [ "$current_commit" = "$commit" ]; then
    exit 0
fi

printf 'Fetching CodeCrafters tester at %s\n' "$commit"
git -C "$tester_dir" fetch --quiet --depth=1 "$repository" "$commit"
git -C "$tester_dir" checkout --quiet --detach "$commit"
