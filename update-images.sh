#!/bin/bash
set -e

# Check that BUILD_ID is set
: "${BUILD_ID:?BUILD_ID is not set. Make sure Jenkins sets it.}"

REGISTRY="khangeshmatte123"
TAG="$BUILD_ID"

BOOK_FILE="k8s_manifest/book-deployment.yaml"
USER_FILE="k8s_manifest/user-deployment.yaml"

echo "Updating image tags in manifests to tag: $TAG"

# Update image tags using sed
sed -i "s|docker.io/$REGISTRY/book-service:[^\"']*|docker.io/$REGISTRY/book-service:$TAG|" "$BOOK_FILE"
sed -i "s|docker.io/$REGISTRY/user-service:[^\"']*|docker.io/$REGISTRY/user-service:$TAG|" "$USER_FILE"

echo "Image tags updated successfully."
