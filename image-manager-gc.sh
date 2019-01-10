#!/bin/bash

# 引数がgcでなければチェックのみ
if [ -z "$1" ] || [ $1 != "gc" ]; then
  # 何がGCされるかを確認する
  kubectl exec -it image-manager-0 -c icp-registry -n kube-system -- registry garbage-collect --dry-run /etc/docker/registry/config.yml
  exit 0
fi

# image-managerのサービスを一時的に無効にする
kubectl patch svc image-manager -n kube-system -p '{"spec": {"selector": {"app": "image-manager-dummy"}}}'

# 何がGCされるかを確認する
kubectl exec -it image-manager-0 -c icp-registry -n kube-system -- registry garbage-collect --dry-run /etc/docker/registry/config.yml

# GCを実行する
kubectl exec -it image-manager-0 -c icp-registry -n kube-system -- registry garbage-collect /etc/docker/registry/config.yml

# オーファン・イメージ・リポジトリー・フォルダーを削除
kubectl exec -it image-manager-0 -c icp-registry -n kube-system -- /bin/sh -c "find /var/lib/registry/docker/registry/v2/repositories/ -maxdepth 2 -mindepth 2 | tee /tmp/image_all"
kubectl exec -it image-manager-0 -c icp-registry -n kube-system -- /bin/sh -c "registry garbage-collect --dry-run /etc/docker/registry/config.yml 2>&1 | grep 'marking manifest' | cut -d ":" -f 0 | xargs -n1 echo '/var/lib/registry/docker/registry/v2/repositories/' | sed 's/ //g'| tee /tmp/image_valid"
kubectl exec -it image-manager-0 -c icp-registry -n kube-system -- /bin/sh -c "grep -F -v -f /tmp/image_valid /tmp/image_all | tr -d '\r' | xargs -n1 rm -rf  2>&1"

# image-managerのサービスを有効にする
kubectl patch svc image-manager -n kube-system -p '{"spec": {"selector": {"app": "image-manager"}}}'
