version=Light-Core1.0V202208.00.000
#version=feature-operator
tag=${version}-$(date +%Y%m%d%H%M%S)
IMG=package.hundsun.com/orca1.0-docker-test-local/orca/app-operator:${tag}
echo ${IMG}
docker buildx build -f=Dockerfile.buildx --platform=linux/amd64 --tag=${IMG} --push .

if [ $? -ne 0 ]; then
  exit
fi
docker rmi ${IMG}
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