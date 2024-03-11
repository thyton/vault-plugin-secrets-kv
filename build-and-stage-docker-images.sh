#!/usr/bin/env bash

set -eo pipefail

# usage:
#     ./build-and-stage-docker-images.sh vault-auth-plugin-example 0.7.0 --latest

if [[ "$#" < 2 ]]; then
  echo "
usage:
     ./build-and-stage-docker-images.sh vault-auth-plugin-example 0.7.0 --latest
  "
  exit 1
fi

PLUGIN_NAME="$1"

if [[ ! $PLUGIN_NAME = vault-plugin-* && ! $PLUGIN_NAME = vault-auth-plugin-example ]]; then
  echo "::error:: invalid plugin name"; exit 1
fi

[[ $PLUGIN_VERSION = v* ]] && PLUGIN_VERSION="${PLUGIN_VERSION:1}"

# Promote the staged images on $STAGING_REGISTRY registry that were built
# and published by the goreleaser docker feature

STAGING_REGISTRY="205325629577.dkr.ecr.us-east-1.amazonaws.com"
# Check if $STAGING_REGISTRY has the staged images and ensure we will build-and-stage the correct staged images
BASE_TAGS=( $PLUGIN_VERSION )
if [[ "$3" == "--latest" ]]; then
  BASE_TAGS+=( "latest" )
fi

ARCHS=( "amd64" "arm64" )

for base_tag in "${BASE_TAGS[@]}"; do
  for arch in "${ARCHS[@]}"; do
    docker pull "$STAGING_REGISTRY/$PLUGIN_NAME:$base_tag-$arch"
    done
done

# Promote the images on $STAGING_REGISTRY to $PROD_REGISTRIES
PROD_REGISTRIES=( "thytonhcp" )
for registry in "${PROD_REGISTRIES[@]}"; do
  for base_tag in "${BASE_TAGS[@]}"; do
    for arch in "${ARCHS[@]}"; do
      docker tag $STAGING_REGISTRY/$PLUGIN_NAME:$base_tag-$arch $registry/$PLUGIN_NAME:$base_tag-$arch
      docker push $registry/$PLUGIN_NAME:$base_tag-$arch
    done

    echo "creating docker manifest $registry/$PLUGIN_NAME:$base_tag"

    args=$(for arch in "${ARCHS[@]}"; do echo -n "--amend $registry/$PLUGIN_NAME:$base_tag-$arch "; done)
    docker manifest create $registry/$PLUGIN_NAME:$base_tag $args

    echo "pushing docker manifest $registry/$PLUGIN_NAME:$base_tag"
    docker manifest push $registry/$PLUGIN_NAME:$base_tag
  done
done