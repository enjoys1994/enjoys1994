set -e
set -x



filePath=$(grep "filePath" config.yaml | awk '{print $2}')

upgradePath=$(grep "upgradePath" config.yaml | awk '{print $2}')

file=$(ls -ltr $filePath |grep SEE2.0-linux |awk -F " " '{print $9}')

if [ -z "$file" ]; then
    echo "file is empty"
    exit
fi

file=$filePath/$file

echo $file

if echo "$file" | grep -q "lightdb"; then
   echo "lightdb版本see升级"
    sh upgradelightdbsee.sh $file $upgradePath
else
  echo "mariadb版本see升级"
   sh upgrademariadbsee.sh $file $upgradePath
fi