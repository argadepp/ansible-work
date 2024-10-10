#!/bin/bash

# Check if Kubernetes version is passed as an argument
if [ -z "$1" ]; then
  echo "Usage: $0 <K8S_VERSION>"
  exit 1
fi

K8S_VERSION=$1
ARCH="x86_64"  # Assuming x86_64 architecture, change if needed

# Fetch all available image versions for the specified K8S version
IMAGE_VERSIONS=$(aws ssm get-parameters-by-path \
  --path "/aws/service/bottlerocket/aws-k8s-$K8S_VERSION/$ARCH" \
  --query "Parameters[?Name.ends_with('image_version')].[Value]" \
  --output text)

# Check if any image versions are found
if [ -z "$IMAGE_VERSIONS" ]; then
  echo "Error: No Bottlerocket AMI versions found."
  exit 1
fi

# Sort versions and get the latest and latest -1
LATEST_VERSION=$(echo "$IMAGE_VERSIONS" | tr ' ' '\n' | sort -rV | head -n 1)
LATEST_MINUS_ONE_VERSION=$(echo "$IMAGE_VERSIONS" | tr ' ' '\n' | sort -rV | head -n 2 | tail -n 1)

# Output the results
echo "Latest Bottlerocket AMI version: $LATEST_VERSION"
echo "Latest -1 Bottlerocket AMI version: $LATEST_MINUS_ONE_VERSION"
