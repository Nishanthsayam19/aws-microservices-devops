#!/usr/bin/env bash

set -u
set -o pipefail

APP_DIR="$HOME/aws-microservices-devops"
STATE_FILE="$APP_DIR/.deployed_version"
REGION="ap-south-1"
NEW_VERSION="${1:-}"

cd "$APP_DIR" || exit 1

if [[ ! "$NEW_VERSION" =~ ^[0-9]+$ ]]; then
    echo "ERROR: Invalid deployment version"
    exit 1
fi

if [[ ! -f "$STATE_FILE" ]]; then
    echo "ERROR: Previous deployment version not found"
    exit 1
fi

PREVIOUS_VERSION=$(tr -d '[:space:]' < "$STATE_FILE")

if [[ ! "$PREVIOUS_VERSION" =~ ^[0-9]+$ ]]; then
    echo "ERROR: Invalid previous deployment version"
    exit 1
fi

echo "Previous version: $PREVIOUS_VERSION"
echo "New version: $NEW_VERSION"

if [[ "$NEW_VERSION" == "$PREVIOUS_VERSION" ]]; then
    echo "Already running requested version."
    exit 0
fi

echo "Logging in to Amazon ECR..."

if ! aws ecr get-login-password --region "$REGION" | docker login --username AWS --password-stdin 551336603749.dkr.ecr.ap-south-1.amazonaws.com; then
    echo "ERROR: ECR login failed"
    exit 1
fi

echo "Pulling new images..."

if ! IMAGE_TAG="$NEW_VERSION" docker compose pull; then
    echo "ERROR: New image pull failed. Existing deployment unchanged."
    exit 1
fi

check_health() {
    for attempt in $(seq 1 12); do
        if curl -fsS http://localhost/users/health >/dev/null &&
           curl -fsS http://localhost/products/health >/dev/null &&
           curl -fsS http://localhost/orders/health >/dev/null; then
            return 0
        fi
        echo "Health check attempt $attempt failed. Retrying..."
        sleep 5
    done
    return 1
}

echo "Deploying version $NEW_VERSION..."

if IMAGE_TAG="$NEW_VERSION" docker compose up -d &&
   IMAGE_TAG="$NEW_VERSION" docker compose up -d --force-recreate nginx &&
   check_health; then

    printf '%s\n' "$NEW_VERSION" > "$STATE_FILE"
    echo "DEPLOYMENT_SUCCESS: Version $NEW_VERSION"
    exit 0
fi

echo "DEPLOYMENT_FAILED: Starting rollback to $PREVIOUS_VERSION..."

if IMAGE_TAG="$PREVIOUS_VERSION" docker compose pull &&
   IMAGE_TAG="$PREVIOUS_VERSION" docker compose up -d &&
   IMAGE_TAG="$PREVIOUS_VERSION" docker compose up -d --force-recreate nginx &&
   check_health; then

    echo "ROLLBACK_SUCCESS: Restored version $PREVIOUS_VERSION"
    exit 1
fi

echo "CRITICAL: Automatic rollback failed. Manual recovery required."
exit 2
