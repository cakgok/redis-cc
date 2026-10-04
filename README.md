# Redis CC

C++ implementation of the CodeCrafters Redis challenge.

Requires Git, CMake, a C++23 compiler, Asio (system headers or vcpkg), Go,
Python 3, and Make.

```sh
make build
make test
```

## Tests and CI

`make test` fetches the pinned official tester, builds Redis and the tester,
then invokes the tester directly. It runs every stage listed in
`ci/stages.txt`, in order.
Advance the target by appending stages while keeping the earlier ones:

```text
jm1  # Bind to a port
rg2  # Respond to PING
wy1  # Respond to multiple PINGs
etc.
```

The valid slugs are in `vendor/redis-tester/internal/tester_definition.go`.\
Blank lines and comments are allowed.\
Empty selections, duplicate stages, and unknown slugs fail.

GitHub Actions builds and tests Debug, ASan, TSan, and Release on
pushes, PRs, and manual dispatch. \
Each profile runs the stages in `ci/stages.txt` in a separate job.\
Sanitizer errors stop the server, and test output is available in the job logs.

## Official tester

`vendor/redis-tester.version` records the repository and commit to use.\
`ci/fetch-tester.sh` downloads that commit from
[codecrafters-io/redis-tester](https://github.com/codecrafters-io/redis-tester)
into the ignored `vendor/redis-tester/` directory.\
Both `make tester` and CI use this script.\
A checkout already at the pinned commit is reused without contacting the remote.\
Local changes in the checkout cause an error.

The first fetch needs network access.\
Its Go version and dependencies are declared in the downloaded `go.mod` and `go.sum`.\
To update the tests, change the commit in `vendor/redis-tester.version` and run `make tester`.
