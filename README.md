# icp-tools

## 前提

`cloudctl`、`kubectl`、`jq`、`curl`が必要。

## イメージ確認

```shell
$ ./list-images.sh
default/infra-test-18.0.0.3:v410
sugi/alpine:3.8
sugi/alpine:3.7
sugi/busybox:1.29.3
sugi/busybox:1.28.4
sugi/myliberty:18.0.0.4
sugi/mysql:8.0.13
sugi/nginx:1.15.7
sugi/stress:1.0
sugi/websphere-liberty:18.0.0.4-webProfile8
sugi/websphere-liberty:18.0.0.4-javaee8
sugi/websphere-liberty:18.0.0.4-kernel
sugi/websphere-liberty:18.0.0.3-kernel
$
```

## イメージ削除

```
$ ./delete-image.sh sugi/websphere-liberty:18.0.0.3-kernel
REPO_NAME: sugi/websphere-liberty
TAG_NAME: 18.0.0.3-kernel
DIGEST: sha256:70171e01672de8d6fda8380beb2c48da00e4099964a30134c1d41afececba6d2
$
```

## レジストリGC

```shell
# Check only
./registry-gc.sh
# Exec gc
./registry-gc.sh run
```

## 状況確認

```
$ ./check-nodes.sh
ICPのNodeが正常稼働しています。
$ ./check-pods.sh
ICPのPodが正常稼働しています。
$ ./check-deployments.sh
ICPのDeploymentが正常稼働しています。
$
```