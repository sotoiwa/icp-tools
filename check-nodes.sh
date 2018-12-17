#!/bin/bash

# kubectl get nodeを実行して結果を変数に格納
json=$(kubectl get node -o json | jq -c .)

# typeがReadyでstatusがTrueなNodeConditionが1つもないNodeを抽出
fail_nodes=$(echo ${json} | jq -c '.items[] | select(([ .status.conditions[] | select(.type == "Ready" and .status == "True") ] | length ) != 1 )')

# 結果を整形
fail_nodes=$(echo ${fail_nodes} | jq -r '.metadata.name')

# fail_nodes が空文字の場合は正常
if [ -z "${fail_nodes}" ]; then
  echo "ICPのNodeが正常稼働しています。"
else
  for node in ${fail_nodes}; do
    echo "${node} が正常稼働していません。"
  done
fi
