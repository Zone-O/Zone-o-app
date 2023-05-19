#!/bin/bash

function statusMessage() {
    if [ $1 -eq 0 ]; then
        echo $2
    else
        echo $3
        exit 1
    fi
}

flutter test --coverage --coverage-path=coverage/lcov.info
statusMessage $? "Flutter tests passed" "Flutter tests failed"