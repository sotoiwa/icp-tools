#!/bin/bash

set -eu

SKIP_IBMCOM=true
CLUSTER=mycluster.icp

# 事前にログイン済みの前提でID_TOKENを取得
if type cloudctl > /dev/null 2>&1; then
  ID_TOKEN=$(LANG=C cloudctl tokens | grep "ID token:" | awk '{print $3}')
elif type bx > /dev/null 2>&1; then
  ID_TOKEN=$(LANG=C bx pr tokens | grep "ID token:" | awk '{print $3}')
else
  echo "cloudctlまたはbxコマンドがありません"
  exit 1
fi
# echo "ID_TOKEN: ${ID_TOKEN}"

# ID_TOKENを使用してCATALOG_TOKENを取得
CATALOG_TOKEN=$(curl -s -k -H "Authorization: Bearer ${ID_TOKEN}" \
  "https://${CLUSTER}:8443/image-manager/api/v1/auth/token?service=token-service&scope=registry:catalog:*" \
  | jq -r '.token')
# echo "CATALOG_TOKEN: ${CATALOG_TOKEN}"

# リポジトリを取得
repo_list=$(curl -s -k -H "Authorization: Bearer ${CATALOG_TOKEN}" \
  "https://${CLUSTER}:8500/v2/_catalog?n=10000" | jq -r '.repositories[]')

# リポジトリ毎に繰り返し
for repo in ${repo_list}; do

  # ibmcomはスキップ
  if ${SKIP_IBMCOM:-false} && [ $(echo ${repo} | grep "ibmcom/") ]; then
    continue
  fi

  REPO_TOKEN=$(curl -s -k -H "Authorization: Bearer ${ID_TOKEN}" \
  "https://${CLUSTER}:8443/image-manager/api/v1/auth/token?service=token-service&scope=repository:${repo}:*" \
  | jq -r '.token')
  # echo "REPO_TOKEN: ${REPO_TOKEN}"

  curl -s -k -H "Authorization: Bearer ${REPO_TOKEN}" \
  "https://${CLUSTER}:8500/v2/${repo}/tags/list" | jq -r 'select( .tags != null ) | "'${repo}:'" + .tags[]'

done
