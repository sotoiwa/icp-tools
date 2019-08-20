#!/bin/bash

set -eu
set -o pipefail

# kubectl get nodeを実行して結果を変数に格納
# "jq -c"は結果を改行等で整形せずコンパクトにするオプション
json=$(kubectl get event --all-namespaces -o json | jq -c .)

# 結果を時刻でソートしてから、
# Warningでフィルタリングし、
# 300秒以内であるかでフィルタリング
warnings=$(echo ${json} | jq -c '.items
  | sort_by( .lastTimestamp )
  | .[]
  | select( .type == "Warning" )
  | select( now - ( .lastTimestamp | fromdate ) <= 300 )'
)

# 結果を整形
# <時刻> <Namespace名> <イベント名> <メッセージ>
# "jq -r"は出力をクオートしないオプション
warnings=$(echo ${warnings} | jq -r '.lastTimestamp + " "
                                      + .involvedObject.namespace + " "
                                      + .involvedObject.name + " "
                                      + .message')

# warnings が空文字の場合は正常
if [ -z "${warnings}" ]; then
  echo "Warningはありません。"
else
  IFS=$'\n'
  for warning in ${warnings}; do
    echo "${warning}"
  done
  unset IFS
  exit 1
fi

