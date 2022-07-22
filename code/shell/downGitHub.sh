
#./downGitHub.sh https://github.com/wangguoyan/java_demo.git

git config --global http.proxy 127.0.0.1:15236
git config --global https.proxy 127.0.0.1:15236


git clone $1


git config --global --unset http.proxy
git config --global --unset https.proxy