#!/bin/bash

# kubectl get poを実行して結果を変数に格納
json=$(kubectl get po --all-namespaces -o json | jq -c .)

# typeがReadyでstatusがTrueなPodConditionが1つもないPodを抽出
fail_pods=$(echo ${json} | jq -c '.items[] | select( ([ .status.conditions[] | select( .type == "Ready" and .status == "True" ) ] | length ) != 1)')

# SucceededなPodは対象外とする
fail_pods=$(echo ${fail_pods} | jq -c 'select( .status.phase != "Succeeded" )')

# regpod-checkingは定期的に起動されるため、監視対象外とする
fail_pods=$(echo ${fail_pods} | jq -c 'select( .metadata.name | test("regpod-checking") | not )')

# 結果を整形
fail_pods=$(echo ${fail_pods} | jq -r '.metadata.namespace + "/" + .metadata.name')

# fail_pods が空文字の場合は正常
if [ -z "${fail_pods}" ]; then
  echo "全てのPodが正常稼働しています。"
else
  for pod in ${fail_pods}; do
    echo "${pod} が正常稼働していません。"
  done
fi
