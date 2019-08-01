#!/bin/bash

# kubectl get nodeを実行して結果を変数に格納
json=$(kubectl get event --all-namespaces -o json | jq -c .)

# 300秒以内のWarningイベントを取得
warnings=$(echo ${json} | jq -c '.items
  | sort_by( .timestamp )
  | .[] 
  | select( .type == "Warning")
  | select( .lastTimestamp | now - fromdate <= 300 )'
)

# 結果を整形
warnings=$(echo ${warnings} | jq -r '.lastTimestamp + " "
                                      + .involvedObject.namespace + " "
                                      + .involvedObject.name + " "
                                      + .message')

# warnings が空文字の場合は正常
if [ -z "${warnings}" ]; then
  echo "Warningはありません。"
else
  for warning in "${warnings}"; do
    echo "${warnings}"
  done
fi
