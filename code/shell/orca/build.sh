#!/usr/bash

set -x
set -e
go mod tidy

echo '
FROM package.hundsun.com/orca1.0-docker-release-local/orca/alpine:3.13.5 as builder

WORKDIR /workspace
COPY . .

RUN chmod +x /workspace/bin/app-operator


FROM package.hundsun.com/orca1.0-docker-release-local/orca/alpine:3.13.5

WORKDIR /
COPY --from=builder /workspace/bin/app-operator .

CMD ["app-operator"]
'> Dockerfile.wgy

version=feature-wgy
tag=${version}-$(date +%Y%m%d%H%M%S)
IMG=package.hundsun.com/orca1.0-docker-test-local/orca/app-operator:${tag}

rm -fr bin/app-operator && CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -a -o bin/app-operator main.go &&
  docker buildx build -f=Dockerfile.wgy --platform=linux/amd64 --tag=${IMG}-amd64 --push . || exit

rm -fr bin/app-operator && CGO_ENABLED=0 GOOS=linux GOARCH=arm64 go build -a -o bin/app-operator main.go &&
  docker buildx build -f=Dockerfile.wgy --platform=linux/arm64 --tag=${IMG}-arm64 --push . || exit

rm -fr bin && rm -fr Dockerfile.wgy

docker manifest create ${IMG} ${IMG}-arm64 ${IMG}-amd64 && docker manifest push ${IMG} || exit

cd ../orca-installation-yamls/orca-all-in-one && git pull || exit

oldVersion=$(cat values.yaml | grep '/app-operator' -A1 | grep version | awk -F '"' '{print $2}')
newVersion=$tag
echo $oldVersion
echo $newVersion

str="s/${oldVersion}/$newVersion/g"
sed -ig $str values.yaml && rm -fr values.yamlg
cd ../ && sh echoImage.sh orca-all-in-one/ || exit

git add orca-all-in-one/values.yaml &&
  git add orca-all-in-one/images.md &&
  git commit -m "Update app-operator operator version to ${tag}" &&
  git push || exit





if [ ! $1 ]; then
  echo "没有带参数" && exit
fi

ip=$1

cd /Users/stt/Desktop/wgy/workspace/go/orca-installation-yamls
git pull

#for ip in "10.20.144.165" "10.20.144.166" "10.20.45.176"; do
rsync -ar /Users/stt/Desktop/wgy/workspace/go/orca-installation-yamls root@${ip}:/home/wgy/
#done

expect -c "
  set timeout 10

  spawn ssh root@${ip}

  expect {
    \"continue\" {send \"yes\r\";exp_continue}
    \"password\" {send \"Test@orca\r\";exp_continue}
    \"login\"    {send \"cd  /home/wgy/orca-installation-yamls && sh update-helm.sh > log.log 2>&1 &  \r exit \r  \";}
  }

  expect eof
  "