#!/bin/bash

function statusMessage() {
    if [ $1 -eq 0 ]; then
        echo $2
    else
        echo $3
        exit 1
    fi
}

statusMessage $? "Flutter tests passed" "Flutter tests failed"