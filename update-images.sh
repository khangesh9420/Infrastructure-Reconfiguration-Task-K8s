#!/bin/bash

#!/bin/bash
set -e

: "${BUILD_ID:?BUILD_ID is not set}"

REGISTRY="khangeshmatte123"
TAG="$BUILD_ID"

BOOK_FILE="k8s_manifest/book-deployment.yaml"
USER_FILE="k8s_manifest/user-deployment.yaml"

echo "Updating image tags to $TAG"

# Update image tags
sed -i "s|docker.io/$REGISTRY/book-service:[^\"']*|docker.io/$REGISTRY/book-service:$TAG|" "$BOOK_FILE"
sed -i "s|docker.io/$REGISTRY/user-service:[^\"']*|docker.io/$REGISTRY/user-service:$TAG|" "$USER_FILE"

# Configure Git
git config --global user.name "khangesh9420"
git config --global user.email "khangeshmatte@gmail.com"

# Commit & push
git add "$BOOK_FILE" "$USER_FILE"
git commit -m "ci: update image tags to $TAG"
git push origin main
