#!/usr/bin/env zsh

set -e # 어느 명령이든 실패하면 즉시 스크립트 중단

[ -f ./entry ] && rm ./entry
as -g -arch arm64 entry.S -o entry.o
ld -lSystem -syslibroot $(xcrun --show-sdk-path) -e _main -arch arm64 entry.o -o entry
./entry

./entry 1 2 3 4 5 6
