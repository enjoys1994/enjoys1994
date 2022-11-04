#version=Light-Core1.0V202209.00.000
version=feature-wgy
tag=${version}-$(date +%Y%m%d%H%M%S)

go mod tidy

rm -fr bin/app-operator
CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -a -o bin/app-operator main.go
IMG=package.hundsun.com/orca1.0-docker-test-local/orca/app-operator:${tag}
docker buildx build -f=Dockerfile.wgy --platform=linux/amd64 --tag=${IMG}-amd64 --push .

if [ $? -ne 0 ]; then
  exit
fi

rm -fr bin/app-operator
CGO_ENABLED=0 GOOS=linux GOARCH=arm64 go build -a -o bin/app-operator main.go
docker buildx build -f=Dockerfile.wgy --platform=linux/arm64 --tag=${IMG}-arm64 --push .

if [ $? -ne 0 ]; then
  exit
fi

rm -fr bin

docker manifest create ${IMG} ${IMG}-arm64 ${IMG}-amd64
docker manifest push ${IMG}
docker rmi ${IMG}-arm64
docker rmi ${IMG}-amd64

cd ../
cd orca-installation-yamls/orca-all-in-one

git pull

oldVersion=$(cat values.yaml | grep '/app-operator' -A1 | grep version | awk -F '"' '{print $2}')
newVersion=$tag
echo $oldVersion
echo $newVersion

str="s/${oldVersion}/$newVersion/g"
sed -ig $str values.yaml
rm -fr values.yamlg
cd ../
sh echoImage.sh orca-all-in-one/

git add orca-all-in-one/values.yaml
git add orca-all-in-one/images.md
git commit -m "Update app-operator operator version to ${tag}"
git push
echo ${IMG}


