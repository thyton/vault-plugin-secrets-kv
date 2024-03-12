#!/usr/bin/env bash

set -eu

# usage:
#     ./generate-dockerfile.sh vault-auth-plugin-example path/to/output/Dockerfile

if [[ "$#" != 2 ]]; then
  echo "
usage:
     ./generate-dockerfile.sh vault-auth-plugin-example path/to/output/Dockerfile
  "
  exit 1
fi

PLUGIN_NAME="$1"

if [[ ! $PLUGIN_NAME = vault-plugin-* && ! $PLUGIN_NAME = vault-auth-plugin-example ]]; then
  echo "::error:: invalid plugin name"; exit 1
fi

DOCKERFILE_PATH="$2"

if [[ ! $DOCKERFILE_PATH = */Dockerfile ]]; then
  echo "::error:: invalid Dockerfile output path"; exit 1
fi

# generate Dockerfile
BASE_IMAGE=gcr.io/distroless/static-debian12

cat <<EOF >$DOCKERFILE_PATH

FROM $BASE_IMAGE

ARG TARGETPLATFORM

COPY dist/$TARGETPLATFORM/$PLUGIN_NAME /bin/$PLUGIN_NAME

ENTRYPOINT [ "/bin/$PLUGIN_NAME" ]

EOF
