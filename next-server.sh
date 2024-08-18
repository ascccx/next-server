#!/bin/bash

# 设置 NeXT-Server 的版本和下载链接
VERSION="0.3.8"
DOWNLOAD_URL="https://github.com/The-NeXT-Project/NeXT-Server/releases/download/v0.3.8/next-server-linux-amd64.zip"
INSTALL_DIR="/opt/NeXT-Server"
SERVICE_FILE="/etc/systemd/system/next-server.service"

# 颜色设置
GREEN='\033[0;32m'
NC='\033[0m' # No Color

function show_menu() {
    echo -e "${GREEN}请选择要执行的操作：${NC}"
    echo -e "${GREEN}1. 安装 NeXT-Server${NC}"
    echo -e "${GREEN}2. 启动 NeXT-Server${NC}"
    echo -e "${GREEN}3. 停止 NeXT-Server${NC}"
    echo -e "${GREEN}4. 重启 NeXT-Server${NC}"
    echo -e "${GREEN}5. 查看 NeXT-Server 日志${NC}"
    echo -e "${GREEN}6. 查看 NeXT-Server 状态${NC}"
    echo -e "${GREEN}7. 卸载 NeXT-Server${NC}"
    echo -e "${GREEN}0. 退出${NC}"
}

function download_and_install() {
    echo "Downloading NeXT-Server..."
    wget -O /tmp/next-server.zip "$DOWNLOAD_URL"

    echo "Creating installation directory..."
    mkdir -p "$INSTALL_DIR"

    echo "Extracting NeXT-Server..."
    unzip /tmp/next-server.zip -d "$INSTALL_DIR"

    echo "Creating systemd service file..."
    cat <<EOF > "$SERVICE_FILE"
[Unit]
Description=NeXT Server
After=network.target

[Service]
Type=simple
ExecStart=/opt/NeXT-Server/next-server
Restart=on-failure
User=root
Group=root
WorkingDirectory=/opt/NeXT-Server

[Install]
WantedBy=multi-user.target
EOF

    echo "Reloading systemd daemon..."
    sudo systemctl daemon-reload

    echo "NeXT-Server installation and configuration complete."
}

function start_service() {
    echo "Starting NeXT-Server..."
    sudo systemctl start next-server
    echo "NeXT-Server has been started."
}

function stop_service() {
    echo "Stopping NeXT-Server..."
    sudo systemctl stop next-server
    echo "NeXT-Server has been stopped."
}

function restart_service() {
    echo "Restarting NeXT-Server..."
    sudo systemctl restart next-server
    echo "NeXT-Server has been restarted."
}

function view_logs() {
    echo "Viewing NeXT-Server logs..."
    sudo journalctl -u next-server -f
}

function check_status() {
    echo "Checking NeXT-Server status..."
    sudo systemctl status next-server
}

function uninstall() {
    read -p "确定要卸载 NeXT-Server 吗？[y/N]: " confirm
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        echo "Stopping and disabling NeXT-Server..."
        sudo systemctl stop next-server
        sudo systemctl disable next-server

        echo "Removing systemd service file..."
        sudo rm -f "$SERVICE_FILE"

        echo "Removing installation directory..."
        sudo rm -rf "$INSTALL_DIR"

        echo "Reloading systemd daemon..."
        sudo systemctl daemon-reload

        echo "NeXT-Server has been uninstalled."
    else
        echo "Uninstallation aborted."
    fi
}

while true; do
    show_menu
    read -p "请输入你的选择 [0-7]: " choice
    case $choice in
        1)
            download_and_install
            ;;
        2)
            start_service
            ;;
        3)
            stop_service
            ;;
        4)
            restart_service
            ;;
        5)
            view_logs
            ;;
        6)
            check_status
            ;;
        7)
            uninstall
            ;;
        0)
            echo "Exiting..."
            exit 0
            ;;
        *)
            echo "无效的选择，请输入 0 到 7 之间的数字。"
            ;;
    esac
done
