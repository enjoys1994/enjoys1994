
cp ../base/base.sh base.sh
cp ../host.conf host.conf

source ./base.sh

master=$(cat host.conf | grep master | awk -F "=" '{print $2}')
slave=$(cat host.conf | grep slave | awk -F "=" '{print $2}')

echo "

helm history orca -norca-system --max 1 |grep -v REVISION |awk -F '"' '"' '{print $1}' | xargs helm rollback orca -norca-system
" >reset_orca.sh

for host in ${master} ${slave}; do
  ip=$(echo $host | awk -F ":" '{print $1}')
  pwd=$(echo $host | awk -F "/" '{print $2}')
  name=$(echo $host  |awk -F "[:/]" '{print $2}') 
  uploadFile ${ip} ${name} "${pwd}" "reset_orca.sh" "/root"
  execCmd ${ip} ${name} "${pwd}" "sh reset_orca.sh && rm -fr reset_orca.sh   &&  exit "
done
rm -fr reset_orca.sh

rm -fr base.sh
rm -fr host.conf