#!/bin/bash

# kubectl get deployを実行して結果を変数に格納
json=$(kubectl get deploy --all-namespaces -o json | jq -c .)

# replicasとreadyReplicasが一致していないdeploymentを抽出
fail_deployments=$(echo ${json} | jq -c '.items[] | select ( .status.replicas != .status.readyReplicas )')

# 結果を整形
fail_deployments=$(echo ${fail_deployments} | jq -r '.metadata.namespace + "/" + .metadata.name')

# fail_deployments が空文字の場合は正常
if [ -z "${fail_deployments}" ]; then
  echo "ICPのDeploymentが正常稼働しています。"
else
  for deployment in ${fail_deployments}; do
    echo "${deployment} が正常稼働していません。"
  done
fi
