
#sh /Users/wgy/Downloads/work/wangguoyan/code/shell/git/pull.sh
#./pull.sh

git stash

git config --global http.proxy 127.0.0.1:15236
git config --global https.proxy 127.0.0.1:15236

git config --global pull.rebase true

git pull

git config --global --unset http.proxy
git config --global --unset https.proxy

git stash pop