#!/bin/bash

function statusMessage() {
    if [ $1 -eq 0 ]; then
        echo $2
    else
        echo $3
        exit 1
    fi
}

# Check if one of the arguments is "mobile"
if [[ "$@" =~ "mobile" ]]; then
    echo "Building Flutter app"
    docker build -t zone-o-app:latest . -f Dockerfile.mobile --no-cache
    docker run zone-o-app:latest
    statusMessage $? "Flutter app built successfully" "Flutter app build failed"
fi

# Check if one of the arguments is "web"
if [[ "$@" =~ "web" ]]; then
    echo "Building Flutter web"
    docker build -t zone-o-web:latest . -f Dockerfile.web --no-cache
    docker run zone-o-web:latest
    statusMessage $? "Flutter web built successfully" "Flutter web build failed"
fi