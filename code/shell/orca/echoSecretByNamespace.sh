

#set -x
set -e
ns=$(kubectl get ns|grep -v NAME |awk '{print $1}')


for i in ${ns} ; do
   num=$(kubectl get secret -n ${i}  | wc -l)
   echo "${i} : ${num}"
done
