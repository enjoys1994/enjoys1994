
while true
do
  jmap -dump:live,format=b,file=heap-$(date +%Y%m%d%H%M%S).hprof $1
  sleep 5
done