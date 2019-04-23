#!/bin/bash

set -eu

CLUSTER=mycluster.icp:8500
NAMESPACE=sugi

# 引数の数が1でなければエラー
if [ $# -ne 1 ]; then
  echo "指定された引数は$#個です。" 1>&2
  echo "実行するには1個の引数が必要です。" 1>&2
  exit 1
fi

image=$1
newimage=${image##*/}

docker pull ${image}
docker tag ${image} ${CLUSTER}/${NAMESPACE}/${newimage}
docker push ${CLUSTER}/${NAMESPACE}/${newimage}
