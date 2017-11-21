#!/bin/bash

# Usage:
# ./build.sh [users's GOPATH]
#
# Example:
# ./build.sh /Users/erezh/work/go

user_gopath=$1

GOPATH=$user_gopath:`pwd`/vendor:`pwd`:`pwd`/src

make container
make push


