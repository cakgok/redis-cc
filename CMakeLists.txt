cmake_minimum_required(VERSION 3.20)

project(redis-cc)

file(GLOB_RECURSE SOURCE_FILES src/*.cpp)

set(CMAKE_CXX_STANDARD 23) # Enable the C++23 standard
set(THREADS_PREFER_PTHREAD_FLAG ON)

find_package(Threads REQUIRED)

# vcpkg ships an asio config package (used on CodeCrafters cloud).
# Fall back to system headers (e.g. `pacman -S asio`) for local builds.
find_package(asio CONFIG QUIET)
if (NOT asio_FOUND)
  find_path(ASIO_INCLUDE_DIR NAMES asio.hpp REQUIRED)
  if (NOT TARGET asio::asio)
    add_library(asio::asio INTERFACE IMPORTED)
    target_include_directories(asio::asio INTERFACE ${ASIO_INCLUDE_DIR})
  endif()
endif()

# Profile-compatible sanitizer setting.
# The harness configures one build directory per profile
# (see harness/run.py PROFILES):
#   build-debug   -DCMAKE_BUILD_TYPE=Debug
#   build-asan    -DCMAKE_BUILD_TYPE=Debug -DREDIS_SANITIZER=address
#   build-tsan    -DCMAKE_BUILD_TYPE=Debug -DREDIS_SANITIZER=thread
#   build-release -DCMAKE_BUILD_TYPE=Release
# Release optimization/NDEBUG come from the standard build type,
# not handwritten flags. Plain `cmake -B build -S .`
# (CodeCrafters entrypoint keeps working: no sanitizer, default flags.
set(REDIS_SANITIZER "" CACHE STRING
    "Sanitizer: address or thread (empty for none)")

if (REDIS_SANITIZER STREQUAL "address")
  add_compile_options(-fsanitize=address,undefined -g -fno-omit-frame-pointer)
  add_link_options(-fsanitize=address,undefined)
elseif (REDIS_SANITIZER STREQUAL "thread")
  add_compile_options(-fsanitize=thread -g -fno-omit-frame-pointer)
  add_link_options(-fsanitize=thread)
elseif (REDIS_SANITIZER)
  message(FATAL_ERROR
          "Unknown REDIS_SANITIZER='${REDIS_SANITIZER}', want address|thread")
endif()

add_executable(redis ${SOURCE_FILES})

target_link_libraries(redis PRIVATE asio::asio)
target_link_libraries(redis PRIVATE Threads::Threads)
