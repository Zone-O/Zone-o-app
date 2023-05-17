#!/bin/bash

function statusMessage() {
    if [ $1 -eq 0 ]; then
        echo $2
    else
        echo $3
        exit 1
    fi
}

docker build -t zone-o-app-test:latest . -f Dockerfile.test --no-cache
statusMessage $? "Flutter app tests passed" "Flutter app tests failed"

docker run --rm zone-o-app-test:latest
statusMessage $? "Flutter app tests passed" "Flutter app tests failed"