#!/bin/bash

LOG_FILE=/root/script/bx-pr-login-slack.log
RETRY=2
SLEEP=60
TIMEOUT=60

writeLog() {
  msg=$@
  msg_txt="$(date '+%Y-%m-%d %T.%3N') ${msg}"
  echo "${msg_txt}"
  echo "${msg_txt}" >>"${LOG_FILE}"
}

retry() {
  n=0
  until [ $n -gt $RETRY ]
  do
    "$@" && break
    n=$((n+1))
    writeLog "${n}回目の試行が失敗しました"
    sleep $SLEEP
  done
  if [ $n -gt $RETRY ]; then
    return 1
  fi
}

retry timeout ${TIMEOUT} bx pr login -u admin -p admin -c id-mycluster-account -a https://mycluster.icp:8443 --skip-ssl-validation >> ${LOG_FILE} 2>&1

if [[ $? -ne 0 ]]; then
  writeLog "ログインに失敗しました"
  CHANNEL="#channel-name"
  WEBHOOK_URL="url"
  MESSAGE="PoC環境でbx pr loginに失敗"
  curl -X POST --data-urlencode "payload={\"channel\": \"${CHANNEL}\", \"username\": \"webhookbot\", \"icon_emoji\": \":ghost:\", \"text\": \"${MESSAGE}\"}" ${WEBHOOK_URL}
  exit 1
fi

writeLog  "ログインに成功しました"