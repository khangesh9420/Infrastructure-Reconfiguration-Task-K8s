#!/bin/bash
set -e

# Check that BUILD_ID is set
: "${BUILD_ID:?BUILD_ID is not set. Make sure Jenkins sets it.}"

REGISTRY="khangeshmatte123"
TAG="$BUILD_ID"

BOOK_FILE="k8s_manifest/book-service.yaml"
USER_FILE="k8s_manifest/user-service.yaml"

echo "Updating image tags in manifests to tag: $TAG"

# Update image tags using sed
sed -i "s|docker.io/$REGISTRY/book-service:[^\"']*|docker.io/$REGISTRY/book-service:$TAG|" "$BOOK_FILE"
sed -i "s|docker.io/$REGISTRY/user-service:[^\"']*|docker.io/$REGISTRY/user-service:$TAG|" "$USER_FILE"

echo "Image tags updated successfully."

# Set Git user identity (only needed in CI)
git config --global user.name "khangesh9420"
git config --global user.email "khangeshmatte@gmail.com"

# Fetch branch info (necessary if clone was shallow or detached)
git fetch origin

# Determine the default branch dynamically (main, master, etc.)
echo "On branch: $CURRENT_BRANCH"
git checkout "$CURRENT_BRANCH"

# Stage, commit, and push changes
git add "$BOOK_FILE" "$USER_FILE"
git commit -m "ci: update image tags to $TAG"

echo "Pushing to origin $DEFAULT_BRANCH"
git push origin HEAD

echo "✅ Image tag update script completed successfully."
