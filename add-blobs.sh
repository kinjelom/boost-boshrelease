#!/bin/bash

set -eu

source ./src/meta-info/blobs-versions.env
source ./rel.env
unset BOSH_ALL_PROXY

mkdir -p "$TMP_DIR"

function down_add_blob {
  BLOBS_GROUP=$1
  FILE=$2
  URL=$3
  if [ ! -f "blobs/${BLOBS_GROUP}/${FILE}" ];then
    echo "Downloads resource from the Internet ($URL -> $TMP_DIR/$FILE)"
    curl -L "$URL" --output "$TMP_DIR/$FILE"
    echo "Adds blob ($TMP_DIR/$FILE -> $BLOBS_GROUP/$FILE), starts tracking blob in config/blobs.yml for inclusion in packages"
    bosh add-blob "$TMP_DIR/$FILE" "$BLOBS_GROUP/$FILE"
  fi
}

function down_add_syspkg_blob {
  BLOBS_GROUP=$1
  SYS_PACKAGE=$2
  URL=$3
  FILE="$(basename "${URL}")"
  if [ ! -f "blobs/$BLOBS_GROUP/$SYS_PACKAGE/$FILE" ];then
    echo "Downloads resource from the Internet ($URL -> $TMP_DIR/$FILE)"
    curl -L $URL --output "$TMP_DIR/$FILE"
    echo "Adds blob ($TMP_DIR/$FILE -> $BLOBS_GROUP/$SYS_PACKAGE/$FILE), starts tracking blob in config/blobs.yml for inclusion in packages"
    bosh add-blob "$TMP_DIR/$FILE" "$BLOBS_GROUP/$SYS_PACKAGE/$FILE"
  fi
}

BLOBS_GROUP="nfs-debs-xenial"
down_add_syspkg_blob "$BLOBS_GROUP" "keyutils"            "http://mirrors.kernel.org/ubuntu/pool/main/k/keyutils/keyutils_1.5.9-8ubuntu1_amd64.deb"
down_add_syspkg_blob "$BLOBS_GROUP" "libevent-2.0-5"      "http://mirrors.kernel.org/ubuntu/pool/main/libe/libevent/libevent-2.0-5_2.0.21-stable-2ubuntu0.16.04.1_amd64.deb"
down_add_syspkg_blob "$BLOBS_GROUP" "libnfsidmap2"        "http://mirrors.kernel.org/ubuntu/pool/main/libn/libnfsidmap/libnfsidmap2_0.25-5_amd64.deb"
down_add_syspkg_blob "$BLOBS_GROUP" "nfs-common"          "http://mirrors.kernel.org/ubuntu/pool/main/n/nfs-utils/nfs-common_1.2.8-9ubuntu12.3_amd64.deb"
down_add_syspkg_blob "$BLOBS_GROUP" "rpcbind"             "http://mirrors.kernel.org/ubuntu/pool/main/r/rpcbind/rpcbind_0.2.3-0.2_amd64.deb"

BLOBS_GROUP="nfs-debs-bionic"
down_add_syspkg_blob "$BLOBS_GROUP" "keyutils"            "http://mirrors.kernel.org/ubuntu/pool/main/k/keyutils/keyutils_1.5.9-9.2ubuntu2_amd64.deb"
down_add_syspkg_blob "$BLOBS_GROUP" "libevent-2.1-6"      "http://mirrors.kernel.org/ubuntu/pool/main/libe/libevent/libevent-2.1-6_2.1.8-stable-4build1_amd64.deb"
down_add_syspkg_blob "$BLOBS_GROUP" "libnfsidmap2"        "http://mirrors.kernel.org/ubuntu/pool/main/libn/libnfsidmap/libnfsidmap2_0.25-5.1_amd64.deb"
down_add_syspkg_blob "$BLOBS_GROUP" "nfs-common"          "http://mirrors.kernel.org/ubuntu/pool/main/n/nfs-utils/nfs-common_1.3.4-2.1ubuntu5.5_amd64.deb"
down_add_syspkg_blob "$BLOBS_GROUP" "rpcbind"             "http://mirrors.kernel.org/ubuntu/pool/main/r/rpcbind/rpcbind_0.2.3-0.6ubuntu0.18.04.4_amd64.deb"

BLOBS_GROUP="nfs-debs-jammy"
down_add_syspkg_blob "$BLOBS_GROUP" "keyutils"            "https://archive.ubuntu.com/ubuntu/pool/main/k/keyutils/keyutils_1.6.1-2ubuntu3_amd64.deb"
down_add_syspkg_blob "$BLOBS_GROUP" "libevent-core-2.1-7" "https://archive.ubuntu.com/ubuntu/pool/main/libe/libevent/libevent-core-2.1-7_2.1.12-stable-1build3_amd64.deb"
down_add_syspkg_blob "$BLOBS_GROUP" "libnfsidmap1"        "https://archive.ubuntu.com/ubuntu/pool/main/n/nfs-utils/libnfsidmap1_2.6.1-1ubuntu1.2_amd64.deb"
down_add_syspkg_blob "$BLOBS_GROUP" "nfs-common"          "https://archive.ubuntu.com/ubuntu/pool/main/n/nfs-utils/nfs-common_2.6.1-1ubuntu1.2_amd64.deb"
down_add_syspkg_blob "$BLOBS_GROUP" "rpcbind"             "https://archive.ubuntu.com/ubuntu/pool/main/r/rpcbind/rpcbind_1.2.6-2build1_amd64.deb"

BLOBS_GROUP="nfs-debs-noble"
down_add_syspkg_blob "$BLOBS_GROUP" "keyutils"               "https://archive.ubuntu.com/ubuntu/pool/main/k/keyutils/keyutils_1.6.3-3build1_amd64.deb"
down_add_syspkg_blob "$BLOBS_GROUP" "libevent-core-2.1-7t64" "https://archive.ubuntu.com/ubuntu/pool/main/libe/libevent/libevent-core-2.1-7t64_2.1.12-stable-9ubuntu2_amd64.deb"
down_add_syspkg_blob "$BLOBS_GROUP" "libnfsidmap1"           "https://archive.ubuntu.com/ubuntu/pool/main/n/nfs-utils/libnfsidmap1_2.6.4-3ubuntu5.1_amd64.deb"
down_add_syspkg_blob "$BLOBS_GROUP" "nfs-common"             "https://archive.ubuntu.com/ubuntu/pool/main/n/nfs-utils/nfs-common_2.6.4-3ubuntu5.1_amd64.deb"
down_add_syspkg_blob "$BLOBS_GROUP" "rpcbind"                "https://archive.ubuntu.com/ubuntu/pool/main/r/rpcbind/rpcbind_1.2.6-7ubuntu2_amd64.deb"



down_add_blob "nfs_mounter" "nfs_mounter_agent_${NFS_MOUNTER_AGENT_VERSION}.tar.gz" "${NFS_MOUNTER_AGENT_URL}"

echo "Upload previously added blobs that were not yet uploaded to the blobstore. Updates config/blobs.yml with returned blobstore IDs."
bosh upload-blobs

echo "Download blobs into blobs/ based on config/blobs.yml"
bosh sync-blobs
