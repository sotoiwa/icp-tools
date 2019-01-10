#!/bin/bash

# 引数の数が1でなければエラー
if [ $# -ne 1 ]; then
  echo "指定された引数は$#個です。" 1>&2
  echo "実行するには1個の引数が必要です。" 1>&2
  exit 1
fi

# 引数のsugi/myliberty-app:18.0.0.3をリポジトリ名とタグ名に分割
REPO_NAME=${1%:*}
TAG_NAME=${1##*:}
echo "REPO_NAME: ${REPO_NAME}"
echo "TAG_NAME: ${TAG_NAME}"

# 事前にログイン済みの前提でID_TOKENを取得
ID_TOKEN=$(cloudctl tokens | grep "ID token:" | awk '{print ($3)}')
echo "ID_TOKEN: ${ID_TOKEN}"

# ID_TOKENを使用してREPO_TOKENを取得
REPO_TOKEN=$(curl -s -k -H "Authorization: Bearer ${ID_TOKEN}" \
  "https://mycluster.icp:8443/image-manager/api/v1/auth/token?service=token-service&scope=repository:${REPO_NAME}:*" \
  | jq -r '.token')
echo "REPO_TOKEN: ${REPO_TOKEN}"

# 削除するイメージのダイジェストを取得する
DIGEST=$(curl -s -k -H "Accept: application/vnd.docker.distribution.manifest.v2+json" \
  -H "Authorization: Bearer ${REPO_TOKEN}" \
  "https://mycluster.icp:8500/v2/${REPO_NAME}/manifests/${TAG_NAME}" -v 2>&1 \
  | grep -i Docker-Content-Digest | awk '{print $3}')
echo "DIGEST: ${DIGEST}"

# 削除を実行
curl -k -XDELETE -H "Authorization: Bearer ${REPO_TOKEN}" \
  "https://mycluster.icp:8500/v2/${REPO_NAME}/manifests/${DIGEST%$'\r'}"
