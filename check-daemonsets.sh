#!/bin/bash

# kubectl get dsを実行して結果を変数に格納
json=$(kubectl get ds --all-namespaces -o json | jq -c .)

# desiredNumberScheduledとnumberReadyが一致していないdeploymentを抽出
fail_workloads=$(echo ${json} | jq -c '.items[] | select ( .status.desiredNumberScheduled != .status.numberReady )')

# 結果を整形
fail_workloads=$(echo ${fail_workloads} | jq -r '.metadata.namespace + "/" + .metadata.name')

# fail_workloads が空文字の場合は正常
if [ -z "${fail_workloads}" ]; then
  echo "全てのDaemonSetが正常稼働しています。"
else
  for workload in ${fail_workloads}; do
    echo "${workload} が正常稼働していません。"
  done
fi
