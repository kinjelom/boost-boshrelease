#!/bin/bash -eu

source ./rel.env

URL="https://github.com/kinjelom/boost-boshrelease/releases/download/v$REL_VERSION/$REL_TARBALL"
SHA1="$(sha1sum "$REL_TARBALL_PATH" | awk '{print $1}')"

echo "$REL_NAME / $REL_VERSION"
echo " "
# shellcheck disable=SC2016
echo 'You can reference this release in your deployment manifest from the `releases` section:'
echo '```yaml'
echo "- name: \"$REL_NAME\""
echo "  version: \"$REL_VERSION\""
echo "  url: \"$URL\""
echo "  sha1: \"$SHA1\""
echo '```'
# shellcheck disable=SC2016
echo 'Or upload it to your director with the `upload-release` command:'
echo '```'
echo "bosh upload-release --sha1 $SHA1 \\"
echo "  $URL"
echo '```'
