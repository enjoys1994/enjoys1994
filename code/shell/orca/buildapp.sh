#!/usr/bash

set -x
set -e

version=Light-Core1.0V202303.00.000
tag=${version}-$(date +%Y%m%d%H%M%S)
IMG=package.hundsun.com/orca1.0-docker-test-local/orca/app-operator:${tag}

cd /Users/stt/Desktop/wgy/workspace/go/application-operator && go mod tidy || exit


echo '
FROM package.hundsun.com/orca1.0-docker-release-local/orca/alpine:3.13.5 as builder

WORKDIR /workspace
COPY . .

RUN chmod +x /workspace/bin/app-operator


FROM package.hundsun.com/orca1.0-docker-release-local/orca/alpine:3.13.5

WORKDIR /
COPY --from=builder /workspace/bin/app-operator .

CMD ["app-operator"]
' >Dockerfile.wgy

rm -fr bin/app-operator && CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -a -o bin/app-operator main.go &&
  docker buildx build -f=Dockerfile.wgy --platform=linux/amd64 --tag=${IMG} --push . || exit

rm -fr bin && rm -fr Dockerfile.wgy

cd /Users/stt/Desktop/wgy/workspace/go/orca-installation-yamls/orca-all-in-one && git restore values.yaml &&
  git pull || exit

oldVersion=$(cat values.yaml | grep '/app-operator' -A1 | grep version | awk -F '"' '{print $2}')
newVersion=$tag
echo $oldVersion
echo $newVersion

str="s/${oldVersion}/$newVersion/g"
sed -ig $str values.yaml && rm -fr values.yamlg || exit

echo ${IMG}

sh /Users/stt/Desktop/wgy/workspace/go/wangguoyan/code/shell/orca/rsync.sh $1

#  app.orcastack.io/app-id: 8d2f8c9d-7be2-47bf-963d-5e81507dfd19

