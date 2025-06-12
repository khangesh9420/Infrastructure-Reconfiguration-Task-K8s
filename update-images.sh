#!/bin/bash
set -e

: "${BUILD_ID:?BUILD_ID is not set}"

REGISTRY="khangeshmatte123"
TAG="$BUILD_ID"
BASE_DIR="${1:-.}"  # Use first argument or default to current directory

BOOK_FILE="$BASE_DIR/k8s_manifest/book-deployment.yaml"
USER_FILE="$BASE_DIR/k8s_manifest/user-deployment.yaml"

echo "Updating image tags to tag: $TAG"

if [[ ! -f "$BOOK_FILE" || ! -f "$USER_FILE" ]]; then
  echo "One of the manifest files is missing: $BOOK_FILE or $USER_FILE"
  exit 1
fi

echo "Before:"
grep 'image:' "$BOOK_FILE"
grep 'image:' "$USER_FILE"

sed -i "s|docker.io/$REGISTRY/book-service:[^[:space:]]*|docker.io/$REGISTRY/book-service:$TAG|" "$BOOK_FILE"
sed -i "s|docker.io/$REGISTRY/user-service:[^[:space:]]*|docker.io/$REGISTRY/user-service:$TAG|" "$USER_FILE"

echo "After:"
grep 'image:' "$BOOK_FILE"
grep 'image:' "$USER_FILE"

echo "Image tags updated."
