#!/bin/bash

# kubectl get deployを実行して結果を変数に格納
json=$(kubectl get deploy --all-namespaces -o json | jq -c .)

# replicasとreadyReplicasが一致していないdeploymentを抽出
fail_workloads=$(echo ${json} | jq -c '.items[] | select ( .status.replicas != .status.readyReplicas )')

# 結果を整形
fail_workloads=$(echo ${fail_workloads} | jq -r '.metadata.namespace + "/" + .metadata.name')

# fail_workloads が空文字の場合は正常
if [ -z "${fail_workloads}" ]; then
  echo "全てのDeploymentが正常稼働しています。"
else
  for workloads in ${fail_workloads}; do
    echo "${workloads} が正常稼働していません。"
  done
fi
