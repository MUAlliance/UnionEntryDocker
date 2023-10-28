#!/bin/bash

# Default values
pre_release=false
output_dir="."

while [[ $# -gt 0 ]]; do
  key="$1"
  case $key in
    --repo=*)
      repo="${key#*=}"
      shift
      ;;
    --filename=*)
      filename_regex="${key#*=}"
      shift
      ;;
    --pre-release=*)
      pre_release="${key#*=}"
      shift
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

if [ -z "$repo" ]; then
  echo "Please specify the GitHub repository using --repo."
  exit 1
fi

# Split the owner and repo
IFS="/" read -r owner repo <<< "$repo"

# Use the GitHub API to fetch the latest release information, including pre-releases if specified
if [ "$pre_release" = true ]; then
  latest_release=$(wget -qO- "https://api.github.com/repos/$owner/$repo/releases/latest")
else
  latest_release=$(wget -qO- "https://api.github.com/repos/$owner/$repo/releases")
fi

# Extract the download URL for the release asset that matches the filename pattern
if [ -n "$filename_regex" ]; then
  download_url=$(echo "$latest_release" | jq -r ".assets[] | select(.name | test(\"$filename_regex\")) | .browser_download_url")
else
  download_url=$(echo "$latest_release" | jq -r ".assets[0].browser_download_url")
fi

echo $download_url