#!/bin/bash
#
# プライベートレジストリ上のイメージを表示します。
#
# Usage: ./pr-delete-image.sh mycluster.icp:8500/sugi/myliberty:0.0.1

set -eu
set -o pipefail

USERNAME=admin
PASSWORD=admin

SKIP_IBMCOM=true

CLUSTER=mycluster.icp
REGISTRY_PORT=8500
MGMT_INGRESS_PORT=8443

# 事前にログイン済みの前提でid_tokenを取得
if type cloudctl > /dev/null 2>&1; then
  id_token=$(LANG=C cloudctl tokens | grep "ID token:" | awk '{print $3}')
elif type bx > /dev/null 2>&1; then
  id_token=$(LANG=C bx pr tokens | grep "ID token:" | awk '{print $3}')
else
  echo "cloudctlまたはbxコマンドがありません" 1>&2
  exit 1
fi

# # id_tokenでcatalog_tokenを取得
# catalog_token=$(curl -s -k -H "Authorization: Bearer ${id_token}" \
#   "https://${CLUSTER}:${MGMT_INGRESS_PORT}/image-manager/api/v1/auth/token?service=token-service&scope=registry:catalog:*" \
#   | jq -r '.token')

# ユーザーIDとパスワードでcatalog_tokenを取得
catalog_token=$(curl -s -k -u ${USERNAME}:${PASSWORD} \
  "https://${CLUSTER}:${MGMT_INGRESS_PORT}/image-manager/api/v1/auth/token?service=token-service&scope=registry:catalog:*" \
  | jq -r '.token')
# echo "catalog_token: ${catalog_token}"

# リポジトリを取得
repo_list=$(curl -s -k -H "Authorization: Bearer ${catalog_token}" \
  "https://${CLUSTER}:${REGISTRY_PORT}/v2/_catalog?n=10000" | jq -r '.repositories[]')

# リポジトリ毎に繰り返し
for repo in ${repo_list}; do

  # ibmcomはスキップ
  if ${SKIP_IBMCOM:-false} && [ $(echo ${repo} | grep "ibmcom/") ]; then
    continue
  fi
  
  # # id_tokenでrepo_tokenを取得
  # repo_token=$(curl -s -k -H "Authorization: Bearer ${id_token}" \
  #   "https://${CLUSTER}:${MGMT_INGRESS_PORT}/image-manager/api/v1/auth/token?service=token-service&scope=repository:${repo}:*" \
  #   | jq -r '.token')

  # ユーザーIDとパスワードでrepo_tokenを取得
  repo_token=$(curl -s -k -u ${USERNAME}:${PASSWORD} \
    "https://${CLUSTER}:${MGMT_INGRESS_PORT}/image-manager/api/v1/auth/token?service=token-service&scope=repository:${repo}:*" \
    | jq -r '.token')
  # echo "repo_token: ${repo_token}"

  curl -s -k -H "Authorization: Bearer ${repo_token}" \
    "https://${CLUSTER}:${REGISTRY_PORT}/v2/${repo}/tags/list" \
     | jq -r 'select( .tags != null ) | "'${CLUSTER}:${RESITRY_PORT}/${repo}:'" + .tags[]'

done
