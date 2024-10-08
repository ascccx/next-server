#!/bin/bash

# 颜色设置
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # 无颜色

function show_menu() {
    echo -e "NeXT-Server 一键脚本"
    echo ""
    echo "请选择要执行的操作："
    echo -e "${GREEN}1${NC}. 安装 NeXT-Server"
    echo -e "${GREEN}2${NC}. 卸载 NeXT-Server"
    echo "----------------------------"
    echo -e "${GREEN}3${NC}. 启动 NeXT-Server"
    echo -e "${GREEN}4${NC}. 停止 NeXT-Server"
    echo -e "${GREEN}5${NC}. 重启 NeXT-Server"
    echo "----------------------------"
    echo -e "${GREEN}6${NC}. 查看 NeXT-Server 日志"
    echo -e "${GREEN}7${NC}. 查看 NeXT-Server 状态"
    echo "----------------------------"
    echo -e "${GREEN}8${NC}. 节点配置"
    echo -e "${GREEN}9${NC}. DNS解锁"
    echo ""
}

function configure_nodes() {
    echo -e "${YELLOW}请填写节点信息:${NC}"
    
    read -p "请输入 ApiHost: " api_host
    read -p "请输入 ApiKey: " api_key
    read -p "请输入 NodeID: " node_id
    
    # 创建或更新配置文件
    CONFIG_FILE="/etc/next-server/config.yml"
    cat <<EOF | sudo tee "$CONFIG_FILE" > /dev/null
Log:
  Level: warning # Log level: none, error, warning, info, debug 
  AccessPath: # /etc/next-server/access.Log
  ErrorPath: # /etc/next-server/error.log
DnsConfigPath: /etc/next-server/dns.json
RouteConfigPath: # /etc/next-server/route.json
InboundConfigPath: # /etc/next-server/custom_inbound.json
OutboundConfigPath: # /etc/next-server/custom_outbound.json
ConnectionConfig:
  Handshake: 4 # Handshake time limit, Second
  ConnIdle: 30 # Connection idle time limit, Second
  UplinkOnly: 2 # Time limit when the connection downstream is closed, Second
  DownlinkOnly: 4 # Time limit when the connection is closed after the uplink is closed, Second
  BufferSize: 64 # The internal cache size of each connection, kB
Nodes:
  - PanelType: "sspanel-old" # Panel type: sspanel-old, nextpanel-v1(wip)
    ApiConfig:
      ApiHost: "$api_host"
      ApiKey: "$api_key"
      NodeID: $node_id
      NodeType: trojan # Node type: vmess, trojan, shadowsocks, shadowsocks2022
      Timeout: 30 # Timeout for the api request
      SpeedLimit: 0 # Mbps, Local settings will replace remote settings, 0 means disable
      DeviceLimit: 0 # Local settings will replace remote settings, 0 means disable
      RuleListPath: # /etc/next-server/rulelist Path to local rulelist file
    ControllerConfig:
      ListenIP: 0.0.0.0 # IP address you want to listen
      SendIP: 0.0.0.0 # IP address you want to send package
      UpdatePeriodic: 60 # Time to update the nodeinfo, how many sec.
      CertConfig:
        CertMode: dns # Option about how to get certificate: none, file, http, tls, dns. Choose "none" will forcedly disable the tls config.
        CertDomain: "999999999.680998.xyz" # Domain to cert
        CertFile: /etc/next-server/cert/node1.test.com.cert # Provided if the CertMode is file
        KeyFile: /etc/next-server/cert/node1.test.com.key
        Provider: cloudflare # cloudflare # DNS cert provider, Get the full support list here: https://go-acme.github.io/lego/dns/
        Email: L479647973@gmail.com
        DNSEnv: # DNS ENV option used by DNS provider
          # ALICLOUD_ACCESS_KEY: aaa
          # ALICLOUD_SECRET_KEY: bbb
          CF_DNS_API_TOKEN: -g7cJ7TyL5Vp7ErrxQpHG6jwLMKTlNjp1z7fP-5I
      EnableDNS: true # Use custom DNS config, Please ensure that you set the dns.json well
      DNSType: UseIP # AsIs, UseIP, UseIPv4, UseIPv6, DNS strategy
      DisableUploadTraffic: false # Disable upload traffic to API
      DisableGetRule: false # Disable get rule
      EnableProxyProtocol: false # Only works for WebSocket and TCP
      DisableIVCheck: false # Disable IV check
      DisableSniffing: false # Disable sniffing
      AutoSpeedLimitConfig:
        Limit: 0 # Warned speed. Set to 0 to disable AutoSpeedLimit (mbps)
        WarnTimes: 0 # After (WarnTimes) consecutive warnings, the user will be limited. Set to 0 to punish overspeed user immediately.
        LimitSpeed: 0 # The speedlimit of a limited user (unit: mbps)
        LimitDuration: 0 # How many minutes will the limiting last (unit: minute)
  - PanelType: "sspanel-old" # Panel type: sspanel-old, nextpanel-v1(wip)
    ApiConfig:
      ApiHost: "$api_host"
      ApiKey: "$api_key"
      NodeID: $((node_id + 1))
      NodeType: trojan # Node type: vmess, trojan, shadowsocks, shadowsocks2022
      Timeout: 30 # Timeout for the api request
      SpeedLimit: 0 # Mbps, Local settings will replace remote settings, 0 means disable
      DeviceLimit: 0 # Local settings will replace remote settings, 0 means disable
      RuleListPath: # /etc/next-server/rulelist Path to local rulelist file
    ControllerConfig:
      ListenIP: 0.0.0.0 # IP address you want to listen
      SendIP: 0.0.0.0 # IP address you want to send package
      UpdatePeriodic: 60 # Time to update the nodeinfo, how many sec.
      CertConfig:
        CertMode: dns # Option about how to get certificate: none, file, http, tls, dns. Choose "none" will forcedly disable the tls config.
        CertDomain: "999999999.680998.xyz" # Domain to cert
        CertFile: /etc/next-server/cert/node1.test.com.cert # Provided if the CertMode is file
        KeyFile: /etc/next-server/cert/node1.test.com.key
        Provider: cloudflare # cloudflare # DNS cert provider, Get the full support list here: https://go-acme.github.io/lego/dns/
        Email: L479647973@gmail.com
        DNSEnv: # DNS ENV option used by DNS provider
          # ALICLOUD_ACCESS_KEY: aaa
          # ALICLOUD_SECRET_KEY: bbb
          CF_DNS_API_TOKEN: -g7cJ7TyL5Vp7ErrxQpHG6jwLMKTlNjp1z7fP-5I
      EnableDNS: true # Use custom DNS config, Please ensure that you set the dns.json well
      DNSType: UseIP # AsIs, UseIP, UseIPv4, UseIPv6, DNS strategy
      DisableUploadTraffic: false # Disable upload traffic to API
      DisableGetRule: false # Disable get rule
      EnableProxyProtocol: false # Only works for WebSocket and TCP
      DisableIVCheck: false # Disable IV check
      DisableSniffing: false # Disable sniffing
      AutoSpeedLimitConfig:
        Limit: 0 # Warned speed. Set to 0 to disable AutoSpeedLimit (mbps)
        WarnTimes: 0 # After (WarnTimes) consecutive warnings, the user will be limited. Set to 0 to punish overspeed user immediately.
        LimitSpeed: 0 # The speedlimit of a limited user (unit: mbps)
        LimitDuration: 0 # How many minutes will the limiting last (unit: minute)
EOF

    echo -e "${YELLOW}节点配置已更新至 $CONFIG_FILE${NC}"
}

# 主程序循环
while true; do
    show_menu
    read -p "请输入选项: " choice
    case $choice in
        1)
            echo "安装 NeXT-Server 的操作..."
            # 这里添加安装的具体操作
            ;;
        2)
            echo "卸载 NeXT-Server 的操作..."
            # 这里添加卸载的具体操作
            ;;
        3)
            echo "启动 NeXT-Server 的操作..."
            # 这里添加启动的具体操作
            ;;
        4)
            echo "停止 NeXT-Server 的操作..."
            # 这里添加停止的具体操作
            ;;
        5)
            echo "重启 NeXT-Server 的操作..."
            # 这里添加重启的具体操作
            ;;
        6)
            echo "查看 NeXT-Server 日志的操作..."
            # 这里添加查看日志的具体操作
            ;;
        7)
            echo "查看 NeXT-Server 状态的操作..."
            # 这里添加查看状态的具体操作
            ;;
        8)
            configure_nodes  # 调用配置函数
            ;;
        9)
            echo "DNS解锁的操作..."
            # 这里添加 DNS 解锁的具体操作
            ;;
        *)
            echo "无效的选项，请重新选择。"
            ;;
    esac
    echo ""
done
