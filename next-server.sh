#!/bin/bash

red='\033[0;31m'
green='\033[0;32m'
plain='\033[0m'

SERVICE_NAME="next-server"
SERVICE_FILE="/etc/systemd/system/$SERVICE_NAME.service"
START_SCRIPT="/opt/next-server/start-script.sh"
WORKING_DIR="/opt/NeXT-Server"
USER="root"
GROUP="root"
REPO_URL="https://github.com/The-NeXT-Project/NeXT-Server"
BACKUP_DIR="/opt/next-server-backup"

# 显示帮助信息
function show_help() {
    echo -e "${green}Usage: next {install|uninstall|start|stop|restart|status|logs|update}${plain}"
    exit 1
}

# 创建 systemd 服务文件
function install_service() {
    echo "Installing $SERVICE_NAME service..."
    sudo tee $SERVICE_FILE > /dev/null <<EOF
[Unit]
Description=Next Server
After=network.target

[Service]
ExecStart=$START_SCRIPT
WorkingDirectory=$WORKING_DIR
Restart=always
User=$USER
Group=$GROUP

[Install]
WantedBy=multi-user.target
EOF

    sudo systemctl daemon-reload
    sudo systemctl enable $SERVICE_NAME
    echo "$SERVICE_NAME service installed and enabled."
}

# 删除 systemd 服务文件
function uninstall_service() {
    echo "Uninstalling $SERVICE_NAME service..."
    sudo systemctl stop $SERVICE_NAME
    sudo systemctl disable $SERVICE_NAME
    sudo rm $SERVICE_FILE
    sudo systemctl daemon-reload
    echo "$SERVICE_NAME service uninstalled."
}

# 启动服务
function start_service() {
    echo "Starting $SERVICE_NAME..."
    sudo systemctl start $SERVICE_NAME
    echo "$SERVICE_NAME started."
}

# 停止服务
function stop_service() {
    echo "Stopping $SERVICE_NAME..."
    sudo systemctl stop $SERVICE_NAME
    echo "$SERVICE_NAME stopped."
}

# 重启服务
function restart_service() {
    echo "Restarting $SERVICE_NAME..."
    sudo systemctl restart $SERVICE_NAME
    echo "$SERVICE_NAME restarted."
}

# 查看服务状态
function status_service() {
    echo "Checking status of $SERVICE_NAME..."
    sudo systemctl status $SERVICE_NAME
}

# 查看服务日志
function logs_service() {
    echo "Viewing logs for $SERVICE_NAME..."
    sudo journalctl -u $SERVICE_NAME
    echo -e "${green}返回菜单...${plain}"
}

# 克隆或更新仓库
function update_repository() {
    if [ -d "$WORKING_DIR" ]; then
        echo "Updating existing repository in $WORKING_DIR..."
        cd $WORKING_DIR
        sudo git pull origin main
    else
        echo "Cloning repository from $REPO_URL to $WORKING_DIR..."
        sudo git clone $REPO_URL $WORKING_DIR
    fi
}

# 备份当前版本
function backup_current_version() {
    if [ -d "$WORKING_DIR" ]; then
        echo "Backing up current version to $BACKUP_DIR..."
        sudo rsync -av --delete $WORKING_DIR/ $BACKUP_DIR/
    fi
}

# 执行更新
function update_next_server() {
    backup_current_version
    update_repository
}

# 显示菜单
function show_menu() {
    while true; do
        echo -e "${green}请选择操作：${plain}"
        echo "1. 安装服务"
        echo "2. 卸载服务"
        echo "3. 启动服务"
        echo "4. 停止服务"
        echo "5. 重启服务"
        echo "6. 查看服务状态"
        echo "7. 查看服务日志"
        echo "8. 更新服务"
        echo "0. 退出"
        read -p "请输入选项 (0-8): " option
        case "$option" in
            1) install_service; echo -e "${green}操作完成，返回菜单...${plain}" ;;
            2) uninstall_service; echo -e "${green}操作完成，返回菜单...${plain}" ;;
            3) start_service; echo -e "${green}操作完成，返回菜单...${plain}" ;;
            4) stop_service; echo -e "${green}操作完成，返回菜单...${plain}" ;;
            5) restart_service; echo -e "${green}操作完成，返回菜单...${plain}" ;;
            6) status_service; echo -e "${green}操作完成，返回菜单...${plain}" ;;
            7) logs_service ;;
            8) update_next_server; echo -e "${green}操作完成，返回菜单...${plain}" ;;
            0) exit 0 ;;
            *) echo -e "${red}无效的选项，请重新输入。${plain}" ;;
        esac
    done
}

# 主程序
show_menu
