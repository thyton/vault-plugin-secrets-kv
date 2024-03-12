#!/usr/bin/env bash

set -eu

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

PLUGIN_VERSION="$2"

[[ $PLUGIN_VERSION = v* ]] && PLUGIN_VERSION="${PLUGIN_VERSION:1}"

STAGING_REGISTRY="thytonhcp"
tags=( $STAGING_REGISTRY/$PLUGIN_NAME:$PLUGIN_VERSION )
if [[ "$3" == "--latest" ]]; then
  tags+=( $STAGING_REGISTRY/$PLUGIN_NAME:latest )
fi

platforms=( "linux/amd64" "linux/arm64" )

echo "building and staging multi-platform images"
echo -e "\t platforms:$(printf " %s" "${platforms[@]}")"
echo -e "\t tags:$(printf " %s" "${tags[@]}")"

docker buildx create --name staging --driver=docker-container --use --bootstrap
platform_val=$(printf -- "--platform %s " "${platforms[@]}")
tag_val=$(printf -- "--tag %s " "${tags[@]}")
docker buildx build $platform_val $tag_val --push .

docker buildx rm staging