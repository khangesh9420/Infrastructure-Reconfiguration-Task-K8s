#!/bin/bash
set -e

: "${BUILD_ID:?BUILD_ID is not set}"

REGISTRY="khangeshmatte123"
TAG="$BUILD_ID"

BOOK_FILE="k8s_manifest/book-deployment.yaml"
USER_FILE="k8s_manifest/user-deployment.yaml"

echo "Updating image tags to tag: $TAG"

# Check files exist
if [[ ! -f "$BOOK_FILE" || ! -f "$USER_FILE" ]]; then
  echo "One of the manifest files is missing"
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
