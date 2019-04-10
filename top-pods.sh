#!/bin/bash

set -eu

CLUSTER=mycluster.icp

# 事前にログイン済みの前提でID_TOKENを取得
if type cloudctl > /dev/null 2>&1; then
  ID_TOKEN=$(LANG=C cloudctl tokens | grep "ID token:" | awk '{print $3}')
elif type bx > /dev/null 2>&1; then
  ID_TOKEN=$(LANG=C bx pr tokens | grep "ID token:" | awk '{print $3}')
else
  echo "cloudctlまたはbxコマンドがありません"
  exit 1
fi

# ID_TOKENを使用してCATALOG_TOKENを取得
JSON=$(curl -s -k -H "Authorization: Bearer ${ID_TOKEN}" \
  "https://${CLUSTER}:8001/apis/metrics.k8s.io/v1beta1/pods" \
  | jq -c '.')

echo $JSON | \
  jq -r '.items[] |
          {
            metadata,
            timestamp,
            container: .containers[]
          } |
          [
            .timestamp,
            .metadata.namespace,
            .metadata.name,
            .container.name,
            (.container.usage.cpu | rtrimstr("n")),
            (.container.usage.memory | rtrimstr("Ki"))
          ] | @csv'

# {
#   "kind": "PodMetricsList",
#   "apiVersion": "metrics.k8s.io/v1beta1",
#   "metadata": {
#     "selfLink": "/apis/metrics.k8s.io/v1beta1/pods"
#   },
#   "items": [
#     {
#       "metadata": {
#         "name": "cust-1",
#         "namespace": "aid-ym",
#         "selfLink": "/apis/metrics.k8s.io/v1beta1/namespaces/aid-ym/pods/cust-1",
#         "creationTimestamp": "2019-04-09T11:16:48Z"
#       },
#       "timestamp": "2019-04-09T11:16:35Z",
#       "window": "30s",
#       "containers": [
#         {
#           "name": "liberty",
#           "usage": {
#             "cpu": "3466991n",
#             "memory": "152524Ki"
#           }
#         }
#       ]
#     },
#     {
#       "metadata": {
#         "name": "kube-dns-9kqc8",
#         "namespace": "kube-system",
#         "selfLink": "/apis/metrics.k8s.io/v1beta1/namespaces/kube-system/pods/kube-dns-9kqc8",
#         "creationTimestamp": "2019-04-09T11:16:48Z"
#       },
#       "timestamp": "2019-04-09T11:16:14Z",
#       "window": "30s",
#       "containers": [