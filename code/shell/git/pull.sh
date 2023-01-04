

# sh /Users/stt/Desktop/wgy/workspace/go/wangguoyan/code/shell/git/pull.sh
#./pull.sh

git config --global http.proxy 127.0.0.1:15236
git config --global https.proxy 127.0.0.1:15236


git pull


git config --global --unset http.proxy
git config --global --unset https.proxy