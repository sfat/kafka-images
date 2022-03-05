#!/bin/bash

# Script creates cp-base-new docker image
# It will first build using maven, then it will perform pushing of the image on Docker Hub
#
# Example of how to run the script:
# $ ./docker-build.sh 7.0.1
#
# Note: this will not take into consideration configuration made in common-docker/base/pom.xml
# regarding libraries being used in Dockerfile, but instead use latest.

version=$1
export DOCKER_USER='sfat'
echo "Logging in Docker. Please enter your password below."
docker login -u "$DOCKER_USER"

docker_image_name="cp-zookeeper"
docker_base_image="$DOCKER_USER/$docker_image_name"

echo "Building and Pushing Confluent Zookeeper Docker images for version $version"

echo "Building Docker Buildx Starter"
export DOCKER_CLI_EXPERIMENTAL=enabled
docker buildx create --use

echo "Building and Pushing images"

docker buildx build -f Dockerfile.ubi8 -t "$docker_base_image:latest" -t "$docker_base_image:$version" \
   --build-arg ARTIFACT_ID="$docker_image_name" \
   --build-arg PROJECT_VERSION="$version" \
   --build-arg DOCKER_UPSTREAM_REGISTRY="docker.io/" \
   --build-arg DOCKER_UPSTREAM_TAG="$version" \
   --build-arg CONFLUENT_PACKAGES_REPO="https://packages.confluent.io/rpm/7.0" \
   --build-arg CONFLUENT_VERSION="$version" \
    --platform linux/amd64,linux/arm64 --push .

echo "Built and Pushed Images successfully."
