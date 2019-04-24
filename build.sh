#!/bin/sh

set -o errexit

branch=libs
remote=$(git config "branch.${branch}.remote")

echo "Fetching latest commits (git fetch)"
git fetch -p "${remote}"

missing=$(git cherry "${remote}/${branch}")

if [ -n "${missing}" ]; then
  echo "Unpushed commits detected, stopping"
  exit 1
fi

current_version=$(cat VERSION)
next_version=$(echo "${current_version}+1" | bc)
echo "Prev version: ${current_version}"
echo "Next version: ${next_version}"

image_name="volatiletech/openapigen:4.0.${next_version}-dev"
echo "Building ${image_name}"
docker build -t "${image_name}" .
echo "Pushing ${image_name}"
docker push "${image_name}"

echo "Writing current version"
echo "${next_version}" > VERSION
git commit -m 'Bump version' VERSION
git push "${remote}" libs
