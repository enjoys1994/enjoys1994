
#  cd /Users/wgy/Downloads/work/java &&  sh /Users/wgy/Downloads/work/wangguoyan/code/shell/git/downGitHub.sh https://github.com/wangguoyan/demo.git

git config --global http.proxy 127.0.0.1:15236
git config --global https.proxy 127.0.0.1:15236


git clone $1


git config --global --unset http.proxy
git config --global --unset https.proxy