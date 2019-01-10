#!/bin/bash

# 引数の数が1でなければエラー
if [ $# -ne 1 ]; then
  echo "指定された引数は$#個です。" 1>&2
  echo "実行するには1個の引数が必要です。" 1>&2
  exit 1
fi

NAMESPACE=sugi

docker pull $1
docker tag $1 mycluster.icp:8500/${NAMESPACE}/$1
docker push mycluster.icp:8500/${NAMESPACE}/$1
