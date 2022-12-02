#!/usr/bash

set -x
set -e

version=feature-dev
tag=${version}-$(date +%Y%m%d%H%M%S)
IMG=package.hundsun.com/orca1.0-docker-test-local/orca/orcactl:${tag}

cd /Users/stt/Desktop/wgy/workspace/go/orcactl && go mod tidy || exit
echo '
FROM package.hundsun.com/orca1.0-docker-release-local/orca/alpine:3.13.5 as builder

WORKDIR /workspace
COPY . .

RUN chmod +x /workspace/bin/orcactl

FROM package.hundsun.com/orca1.0-docker-release-local/orca/alpine:3.13.5

WORKDIR /
COPY --from=builder /workspace/bin/orcactl /usr/bin/

' >Dockerfile.wgy

rm -fr bin/orcactl && CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -a -o bin/orcactl main.go
docker buildx build -f=Dockerfile.wgy --platform=linux/amd64 --tag=${IMG}-amd64 --push . || exit

rm -fr bin/orcactl && CGO_ENABLED=0 GOOS=linux GOARCH=arm64 go build -a -o bin/orcactl main.go
docker buildx build -f=Dockerfile.wgy --platform=linux/arm64 --tag=${IMG}-arm64 --push . || exit

rm -fr bin && rm -fr Dockerfile.wgy

docker manifest create ${IMG} ${IMG}-arm64 ${IMG}-amd64 && docker manifest push ${IMG} || exit

cd ../orca-installation-yamls/orca-all-in-one && git pull || exit

oldVersion=$(cat values.yaml | grep 'orca/orcactl' -A1 | grep version | awk -F '"' '{print $2}')
newVersion=$tag
echo $oldVersion
echo $newVersion

str="s/${oldVersion}/$newVersion/g"
sed -ig $str values.yaml && rm -fr values.yamlg || exit

sh /Users/stt/Desktop/wgy/workspace/go/wangguoyan/code/shell/orca/rsync.sh $1
