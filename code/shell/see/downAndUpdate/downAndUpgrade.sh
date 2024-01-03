node test.js


cd ../../../java/uploadFile || exit

#mvn clean package

java -jar target/upload-jar-with-dependencies.jar --config=10.20.144.166,root,Test@orca,/Users/wgy/Downloads/upgrade,/home/wgy/upgrade,mysql --delete=true

java -jar target/upload-jar-with-dependencies.jar --config=10.20.144.165,wgy,Test@orca,/Users/wgy/Downloads/upgrade,/home/wgy/upgrade,lightdb --delete=true

java -jar target/upload-jar-with-dependencies.jar --config=10.20.45.174,root,Preview@see2023,/Users/wgy/Downloads/upgrade,/home/wgy/upgrade,mysql --delete=true








