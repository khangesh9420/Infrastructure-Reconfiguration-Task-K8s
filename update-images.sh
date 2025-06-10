#!/bin/bash

set -e

REGISTRY="khangeshmatte123"
TAG="$BUILD_ID"

BOOK_FILE="k8s_manifest/book-service.yaml"
USER_FILE="k8s_manifest/user-service.yaml"

# Update image tags in both manifests
sed -i "s|docker.io/$REGISTRY/book-service:[^\"']*|docker.io/$REGISTRY/book-service:$TAG|" "$BOOK_FILE"
sed -i "s|docker.io/$REGISTRY/user-service:[^\"']*|docker.io/$REGISTRY/user-service:$TAG|" "$USER_FILE"

# Git commit & push
git config --global user.name "khangesh9420"
git config --global user.email "khangeshmatte@gmail.com"

git add "$BOOK_FILE" "$USER_FILE"
git commit -m "ci: update image tags to $TAG"
git push origin main
