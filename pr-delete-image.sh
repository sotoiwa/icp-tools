#!/bin/bash
#
# プライベートレジストリ上のイメージを削除します。
#
# Usage: ./pr-delete-image.sh mycluster.icp:8500/sugi/myliberty:0.0.1

set -eu
set -o pipefail

USERNAME=admin
PASSWORD=admin

CLUSTER=mycluster.icp
REGISTRY_PORT=8500
MGMT_INGRESS_PORT=8443

CMDNAME=$(basename $0)
# 引数の数が1でなければエラー
if [ $# -ne 1 ]; then
  echo "引数が1つ必要です。" 1>&2
  echo "Usage: ./pr-delete-image.sh mycluster.icp:8500/sugi/myliberty:0.0.1" 1>&2
  exit 1
fi

image=$1
repo_host=${image%%/*}
repo_and_tag=${image#*/}
repo=${repo_and_tag%:*}
tag=${repo_and_tag##*:}

# # 事前にログイン済みの前提でid_tokenを取得
# if type cloudctl > /dev/null 2>&1; then
#   id_token=$(LANG=C cloudctl tokens | grep "ID token:" | awk '{print $3}')
# elif type bx > /dev/null 2>&1; then
#   id_token=$(LANG=C bx pr tokens | grep "ID token:" | awk '{print $3}')
# else
#   echo "cloudctlまたはbxコマンドがありません" 1>&2
#   exit 1
# fi
#
# id_tokenでrepo_tokenを取得
# repo_token=$(curl -s -k -H "Authorization: Bearer ${id_token}" \
#   "https://${CLUSTER}:${MGMT_INGRESS_PORT}/image-manager/api/v1/auth/token?service=token-service&scope=repository:${repo}:*" \
#   | jq -r '.token')
# echo "repo_token: ${repo_token}"

# ユーザーIDとパスワードでrepo_tokenを取得
repo_token=$(curl -s -k -u ${USERNAME}:${PASSWORD} \
  "https://${CLUSTER}:${MGMT_INGRESS_PORT}/image-manager/api/v1/auth/token?service=token-service&scope=repository:${repo}:*" \
  | jq -r '.token')
# echo "repo_token: ${repo_token}"

# 削除するイメージのダイジェストを取得する
digest=$(curl -s -k -H "Accept: application/vnd.docker.distribution.manifest.v2+json" \
  -H "Authorization: Bearer ${repo_token}" \
  "https://${CLUSTER}:${REGISTRY_PORT}/v2/${repo}/manifests/${tag}" -v 2>&1 \
  | grep -i Docker-Content-digest | awk '{print $3}')
echo "digest: ${digest}"

# 削除を実行
curl -k -XDELETE -H "Authorization: Bearer ${repo_token}" \
  "https://${CLUSTER}:${REGISTRY_PORT}/v2/${repo}/manifests/${digest%$'\r'}"
