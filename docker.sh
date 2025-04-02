#!/bin/bash

IMAGE_NAME="gtest_env"
CONTAINER_NAME="gtest_container"
DOCKERFILE_DIR="."
PROJECT_DIR=$(pwd)
MOUNT_DIR="/home/tester/Workspace/gtest"

# Get the current user ID
USER_ID=$(id -u)

function build_image() {
    echo "Building image $IMAGE_NAME with USER_ID=$USER_ID."
    sudo docker build --build-arg USER_ID=$USER_ID -t $IMAGE_NAME $DOCKERFILE_DIR
}

function run_container() {
    if [ -z "$1" ]; then
        echo "Please provide a directory to mount."
        exit 1
    fi
    MOUNT_PATH=$(realpath "$1")
    echo "Running container $CONTAINER_NAME with mounted directory: $MOUNT_PATH."
    sudo docker run -it --rm \
        -v $MOUNT_PATH:$MOUNT_DIR \
        --name $CONTAINER_NAME $IMAGE_NAME bash   
}

function check_image_exists() {
    sudo docker image inspect $IMAGE_NAME > /dev/null 2>&1
}

case "$1" in
    build)
        build_image
        ;;
    run)
        if check_image_exists; then
            run_container "$2"
        else
            echo "Image $IMAGE_NAME does not exist. Please build the image first."
        fi
        ;;
    build_and_run)
        build_image
        run_container "$2"
        ;;
    *)
        echo "Usage: $0 {build|run|build_and_run} <host_directory_to_mount>"
        exit 1
        ;;
esac
