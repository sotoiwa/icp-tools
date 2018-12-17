#!/bin/bash

# 事前にログイン済みの前提でID_TOKENを取得
ID_TOKEN=$(cloudctl tokens | grep "ID token:" | awk '{print ($3)}')

# ID_TOKENを使用してCATALOG_TOKENを取得
CATALOG_TOKEN=$(curl -s -k -H "Authorization: Bearer ${ID_TOKEN}" \
  "https://mycluster.icp:8443/image-manager/api/v1/auth/token?service=token-service&scope=registry:catalog:*" \
  | jq -r '.token')

# リポジトリを取得
repo_list=$(curl -s -k -H "Authorization: Bearer ${CATALOG_TOKEN}" \
  "https://mycluster.icp:8500/v2/_catalog?n=10000" | jq -r '.repositories[]')

# リポジトリ毎に繰り返し
for repo in ${repo_list}; do
  # ibmcomはスキップ
  if [ $(echo ${repo} | grep ibmcom) ]; then
    continue
  fi
  REPO_TOKEN=$(curl -s -k -H "Authorization: Bearer ${ID_TOKEN}" \
  "https://mycluster.icp:8443/image-manager/api/v1/auth/token?service=token-service&scope=repository:${repo}:*" \
  | jq -r '.token')
  curl -s -k -H "Authorization: Bearer ${REPO_TOKEN}" \
  "https://mycluster.icp:8500/v2/${repo}/tags/list" | jq -r 'select( .tags != null ) | "'${repo}:'" + .tags[]'
done
