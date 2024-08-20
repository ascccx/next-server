#!/bin/bash

# 当前 NeXT-Server 版本
VERSION="0.3.9"

# 获取 NeXT-Server 的最新版本
LATEST_VERSION=$(wget -qO- "https://api.github.com/repos/The-NeXT-Project/NeXT-Server/releases/latest" | grep "tag_name" | cut -d '"' -f 4)
DOWNLOAD_URL="https://github.com/The-NeXT-Project/NeXT-Server/releases/download/${LATEST_VERSION}/next-server-linux-amd64.zip"
INSTALL_DIR="/opt/NeXT-Server"
SERVICE_FILE="/etc/systemd/system/next-server.service"

# 颜色设置
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

function show_menu() {
    echo -e "${GREEN}NeXT-Server 一键脚本 [${VERSION}]${NC}"
    echo "一个基于Xray开发，支持多协议的专属后端框架"
    echo "支持协议:"
    echo "(1) Shadowsocks2022, (2) Trojan, (3) Vmess, (4) TUIC"
    echo "项目地址：https://github.com/The-NeXT-Project/NeXT-Server"
    echo ""
    echo "请选择要执行的操作："
    echo -e "${GREEN}1${NC}. 安装 NeXT-Server"
    echo -e "${GREEN}2${NC}. 启动 NeXT-Server"
    echo -e "${GREEN}3${NC}. 停止 NeXT-Server"
    echo -e "${GREEN}4${NC}. 重启 NeXT-Server"
    echo -e "${GREEN}5${NC}. 查看 NeXT-Server 日志"
    echo -e "${GREEN}6${NC}. 查看 NeXT-Server 状态"
    echo -e "${GREEN}7${NC}. 卸载 NeXT-Server"
    echo -e "${GREEN}0${NC}. 退出"
}

function download_and_install() {
    echo -e "${YELLOW}正在下载 NeXT-Server...${NC}"
    wget -O /tmp/next-server.zip "$DOWNLOAD_URL"

    echo -e "${YELLOW}正在创建安装目录...${NC}"
    mkdir -p "$INSTALL_DIR"

    echo -e "${YELLOW}正在解压 NeXT-Server，仅替换 next-server 文件...${NC}"
    unzip -o /tmp/next-server.zip next-server -d "$INSTALL_DIR"

    # 如果服务文件存在，则只重启服务
    if [ -f "$SERVICE_FILE" ]; then
        echo -e "${YELLOW}系统服务文件已存在，仅重启 NeXT-Server。${NC}"
        sudo systemctl restart next-server
    else
        echo -e "${YELLOW}正在创建 systemd 服务文件...${NC}"
        cat <<EOF | sudo tee "$SERVICE_FILE" > /dev/null
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

        echo -e "${YELLOW}正在重新加载 systemd 守护进程...${NC}"
        sudo systemctl daemon-reload
        echo -e "${YELLOW}NeXT-Server 服务文件已创建并加载。${NC}"
    fi

    echo -e "${YELLOW}NeXT-Server 安装与配置完成。${NC}"
}

function start_service() {
    echo -e "${YELLOW}正在启动 NeXT-Server...${NC}"
    sudo systemctl start next-server
    echo -e "${YELLOW}NeXT-Server 已启动。${NC}"
}

function stop_service() {
    echo -e "${YELLOW}正在停止 NeXT-Server...${NC}"
    sudo systemctl stop next-server
    echo -e "${YELLOW}NeXT-Server 已停止。${NC}"
}

function restart_service() {
    echo -e "${YELLOW}正在重启 NeXT-Server...${NC}"
    sudo systemctl restart next-server
    echo -e "${YELLOW}NeXT-Server 已重启。${NC}"
}

function view_logs() {
    echo -e "${YELLOW}正在查看 NeXT-Server 日志...${NC}"
    sudo journalctl -u next-server -f
}

function check_status() {
    echo -e "${YELLOW}正在检查 NeXT-Server 状态...${NC}"
    sudo systemctl status next-server
}

function uninstall() {
    read -p "确定要卸载 NeXT-Server 吗？[y/N]: " confirm
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}正在停止并禁用 NeXT-Server...${NC}"
        sudo systemctl stop next-server
        sudo systemctl disable next-server

        echo -e "${YELLOW}正在删除 systemd 服务文件...${NC}"
        sudo rm -f "$SERVICE_FILE"

        echo -e "${YELLOW}正在删除安装目录...${NC}"
        sudo rm -rf "$INSTALL_DIR"

        echo -e "${YELLOW}正在重新加载 systemd 守护进程...${NC}"
        sudo systemctl daemon-reload

        echo -e "${YELLOW}NeXT-Server 已卸载。${NC}"
    else
        echo -e "${YELLOW}卸载已取消。${NC}"
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
            echo -e "${YELLOW}操作结束，已退出...${NC}"
            exit 0
            ;;
        *)
            echo -e "${YELLOW}无效的选择，请输入 0 到 7 之间的数字。${NC}"
            ;;
    esac
done
