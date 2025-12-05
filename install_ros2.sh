#!/bin/bash
# Script by Chiawei
set -e
print_step() { echo "==== $1 ===="; }
print_info() { echo "[INFO] $1"; }
print_warning() { echo "[WARNING] $1"; }
print_error() { echo "[ERROR] $1"; }

clean_bashrc_config() {
    if grep -q "#------------- HOSTPC CONFIG" ~/.bashrc; then
        sed -i '/#------------- HOSTPC CONFIG/,/#------------- HOSTPC CONFIG/d' ~/.bashrc
    fi
}
# ---------------- 系統檢查 ----------------
check_ubuntu() {
    if ! grep -q "ubuntu" /etc/os-release; then
        print_error "此腳本僅支援 Ubuntu 系統"
        exit 1
    fi
    print_info "檢測到 Ubuntu 系統，繼續安裝..."
}
# ---------------- ROS 2 Humble 安裝 ----------------
install_ros2_base() {
    print_step "Step 1: 設定區域設定 (locale)"
    locale
    sudo apt update && sudo apt install -y locales
    sudo locale-gen en_US en_US.UTF-8
    sudo update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
    export LANG=en_US.UTF-8
    locale
    print_step "Step 2: 設定來源 (APT Source)"
    sudo apt install -y software-properties-common
    sudo add-apt-repository universe
    sudo apt update && sudo apt install -y curl
    export ROS_APT_SOURCE_VERSION=$(curl -s https://api.github.com/repos/ros-infrastructure/ros-apt-source/releases/latest | grep -F "tag_name" | awk -F\" '{print $4}')
    curl -L -o /tmp/ros2-apt-source.deb \
    "https://github.com/ros-infrastructure/ros-apt-source/releases/download/${ROS_APT_SOURCE_VERSION}/ros2-apt-source_${ROS_APT_SOURCE_VERSION}.$(. /etc/os-release && echo $VERSION_CODENAME)_all.deb"
    sudo dpkg -i /tmp/ros2-apt-source.deb
    print_step "Step 3: 更新與升級系統"
    sudo apt update
    sudo apt upgrade -y
    print_step "Step 4: 安裝 ROS 2 Humble Desktop 與工具"
    sudo apt install -y ros-humble-desktop
    sudo apt install -y ros-humble-ros-base
    sudo apt install -y ros-dev-tools
    print_step "Step 5: 初始化 rosdep"
    if [ ! -f /etc/ros/rosdep/sources.list.d/20-default.list ]; then
        sudo rosdep init
    fi
    rosdep update
    print_step "Step 6: 設定環境"
    source /opt/ros/humble/setup.bash
    # 設定 bashrc
    grep -v "source /opt/ros/humble/setup.bash" ~/.bashrc > ~/.bashrc.tmp || true
    mv ~/.bashrc.tmp ~/.bashrc
    echo "source /opt/ros/humble/setup.bash" >> ~/.bashrc
    source ~/.bashrc
}
# ---------------- Gazebo 安裝 ----------------
install_gazebo() {
    print_step "安裝 Gazebo 套件"
    sudo apt install -y ros-humble-gazebo-ros-pkgs ros-humble-gazebo-ros
   
    print_step "Gazebo 安裝完成"
}
# ---------------- ROS2 工作空間建立 ----------------
setup_ros2_workspace() {
    print_step "建立 ROS2 工作空間"
    source /opt/ros/humble/setup.bash
    mkdir -p ~/ros2_ws/src
    cd ~/ros2_ws/src
    print_step "下載 ROS Tutorials"
    git clone https://github.com/ros/ros_tutorials.git -b humble
    rm -rf ros_tutorials/turtlesim
    print_info "已移除 ros_tutorials 中的 turtlesim (使用系統版本)"
    
    print_step "安裝相依套件"
    cd ~/ros2_ws
    rosdep install -i --from-path src --rosdistro humble -y
    print_step "編譯工作空間"
    colcon build --symlink-install
    print_step "ROS2 工作空間建立完成"
}
# ---------------- TurtleBot3 安裝 ----------------
install_turtlebot3() {
    print_step "安裝依賴的 ROS 2 套件"
    sudo apt install -y ros-humble-gazebo-*
    sudo apt install -y ros-humble-cartographer
    sudo apt install -y ros-humble-cartographer-ros
    sudo apt install -y ros-humble-navigation2
    sudo apt install -y ros-humble-nav2-bringup
    sudo apt install -y python3-colcon-common-extensions
    
    print_step "建立 TurtleBot3 資料夾"
    mkdir -p ~/ros2_ws/src/turtlebot3_ROS2
    cd ~/ros2_ws/src/turtlebot3_ROS2
    print_step "下載 TurtleBot3 軟體包"
    git clone -b humble https://github.com/ROBOTIS-GIT/DynamixelSDK.git
    git clone -b humble https://github.com/ROBOTIS-GIT/turtlebot3_msgs.git
    git clone -b humble https://github.com/ROBOTIS-GIT/turtlebot3.git
    print_step "下載 TurtleBot3 模擬包"
    git clone -b humble https://github.com/ROBOTIS-GIT/turtlebot3_simulations.git
    
    print_step "安裝相依套件"
    cd ~/ros2_ws
    rosdep install -i --from-path src --rosdistro humble -y
    print_step "編譯工作空間"
    colcon build --symlink-install
    print_step "TurtleBot3 安裝完成"
    ls
}
# ---------------- 主選單 ----------------
show_menu() {
    echo "============================================"
    echo " ROS 2 Humble 安裝選單"
    echo "============================================"
    echo "1) ROS2 Humble + Gazebo + TurtleBot3"
    echo "2) ROS2 Humble + Gazebo"
    echo "3) ROS2 Humble"
    echo "============================================"
}
# ---------------- 主程式 ----------------
main() {
    check_ubuntu
    show_menu
    echo -n "請選擇安裝選項 (1/2/3): "
    read choice
    case $choice in
        1)
            install_ros2_base
            install_gazebo
            setup_ros2_workspace
            install_turtlebot3
            print_step "安裝完成: ROS2 Humble + Gazebo + TurtleBot3"
            echo "安裝版本 : $ROS_DISTRO"
            echo "開新終端機後輸入以下指令進行測試："
           
            echo "1. ros2 run demo_nodes_cpp talker # C++ 範例發布者"
            echo "2. ros2 run demo_nodes_cpp listener # C++ 範例訂閱者 [新增終端機]"
            echo "3. ros2 run demo_nodes_py talker # Python 範例發布者 "
            echo "4. ros2 run demo_nodes_py listener # Python 範例訂閱者 [新增終端機]"
            echo "5. ros2 run turtlesim turtlesim_node # Turtlesim節點 "
            echo "6. ros2 run turtlesim turtle_teleop_key # Turtle Teleop [新增終端機]"
            echo "7. gazebo # 開啟Gazebo"
            echo "8. ros2 launch turtlebot3_gazebo turtlebot3_world.launch.py #開啟turtlebot3_gazebo World"
           
            clean_bashrc_config
           
            cat << 'EOF' >> ~/.bashrc
#------------- HOSTPC CONFIG ---------------------------------------------------------------
# ROS2 環境配置
source /opt/ros/humble/setup.bash
source ~/ros2_ws/install/setup.bash
source /usr/share/gazebo/setup.sh
#--------------------------------------------------------------------------------------------------
# Gazebo 環境配置
export ROS_DOMAIN_ID=30 #TURTLEBOT3
export SVGA_VGPU10=0
export TURTLEBOT3_MODEL=waffle
#--------------------------------------------------------------------------------------------------
# ROS_Host 網路配置
interface=$(ip route | grep default | head -1 | awk '{print $5}')
export IPAddress=$(ip -4 addr show $interface | grep -oP '(?<=inet\s)\d+(\.\d+){3}')
export ROS_IP=$IPAddress
#--------------------------------------------------------------------------------------------------
# ROS_Master 網路地址
export ROBOT_IP=$IPAddress
export ROS_MASTER_URI=http://$ROBOT_IP:11311
#--------------------------------------------------------------------------------------------------
# Alias path 跳轉快捷指令
alias cw='cd ~/ros2_ws'
alias cs='cd ~/ros2_ws/src'
alias cm='cd ~/ros2_ws && colcon build'
alias kg='killall -9 gzserver gzclient'
#--------------------------------------------------------------------------------------------------
# Bash 終端顯示
echo ""
echo "----------------------- HOST PC INFO -----------------------"
echo -e " ROS_MASTER_URI: \033[32m$ROS_MASTER_URI\033[0m"
echo -e " HOST PC ROS_IP: \033[32m$ROS_IP\033[0m"
echo "------------------------------------------------------------"
echo ""
#------------- HOSTPC CONFIG ---------------------------------------------------------------
EOF
            ;;
        2)
            install_ros2_base
            install_gazebo
            setup_ros2_workspace
            print_step "安裝完成: ROS2 Humble + Gazebo"
            echo "安裝版本 : $ROS_DISTRO"
            echo "開新終端機後輸入以下指令進行測試："
            echo "1. ros2 run demo_nodes_cpp talker # C++ 範例發布者"
            echo "2. ros2 run demo_nodes_cpp listener # C++ 範例訂閱者 [新增終端機]"
            echo "3. ros2 run demo_nodes_py talker # Python 範例發布者 "
            echo "4. ros2 run demo_nodes_py listener # Python 範例訂閱者 [新增終端機]"
            echo "5. ros2 run turtlesim turtlesim_node # Turtlesim節點 "
            echo "6. ros2 run turtlesim turtle_teleop_key # Turtle Teleop [新增終端機]"
            echo "7. gazebo # 開啟Gazebo"
           
            clean_bashrc_config
           
            cat << 'EOF' >> ~/.bashrc
#------------- HOSTPC CONFIG ---------------------------------------------------------------
# ROS2 環境配置
source /opt/ros/humble/setup.bash
source ~/ros2_ws/install/setup.bash
source /usr/share/gazebo/setup.sh
#--------------------------------------------------------------------------------------------------
# Gazebo 環境配置
export ROS_DOMAIN_ID=30
export SVGA_VGPU10=0
#--------------------------------------------------------------------------------------------------
# ROS_Host 網路配置
interface=$(ip route | grep default | head -1 | awk '{print $5}')
export IPAddress=$(ip -4 addr show $interface | grep -oP '(?<=inet\s)\d+(\.\d+){3}')
export ROS_IP=$IPAddress
#--------------------------------------------------------------------------------------------------
# ROS_Master 網路地址
export ROBOT_IP=$IPAddress
export ROS_MASTER_URI=http://$ROBOT_IP:11311
#--------------------------------------------------------------------------------------------------
# Alias path 跳轉快捷指令
alias cw='cd ~/ros2_ws'
alias cs='cd ~/ros2_ws/src'
alias cm='cd ~/ros2_ws && colcon build'
alias kg='killall -9 gzserver gzclient'
#--------------------------------------------------------------------------------------------------
# Bash 終端顯示
echo ""
echo "----------------------- HOST PC INFO -----------------------"
echo -e " ROS_MASTER_URI: \033[32m$ROS_MASTER_URI\033[0m"
echo -e " HOST PC ROS_IP: \033[32m$ROS_IP\033[0m"
echo "------------------------------------------------------------"
echo ""
#------------- HOSTPC CONFIG ---------------------------------------------------------------
EOF
            ;;
        3)
            install_ros2_base
            setup_ros2_workspace
            print_step "安裝完成: ROS2 Humble"
            echo "安裝版本 : $ROS_DISTRO"
            echo "開新終端機後輸入以下指令進行測試："
            echo "1. ros2 run demo_nodes_cpp talker # C++ 範例發布者"
            echo "2. ros2 run demo_nodes_cpp listener # C++ 範例訂閱者 [新增終端機]"
            echo "3. ros2 run demo_nodes_py talker # Python 範例發布者 "
            echo "4. ros2 run demo_nodes_py listener # Python 範例訂閱者 [新增終端機]"
            echo "5. ros2 run turtlesim turtlesim_node # Turtlesim節點 "
            echo "6. ros2 run turtlesim turtle_teleop_key # Turtle Teleop [新增終端機]"
           
            clean_bashrc_config
           
            cat << 'EOF' >> ~/.bashrc
#------------- HOSTPC CONFIG ---------------------------------------------------------------
# ROS2 環境配置
source /opt/ros/humble/setup.bash
source ~/ros2_ws/install/setup.bash
#--------------------------------------------------------------------------------------------------
# ROS_Host 網路配置
interface=$(ip route | grep default | head -1 | awk '{print $5}')
export IPAddress=$(ip -4 addr show $interface | grep -oP '(?<=inet\s)\d+(\.\d+){3}')
export ROS_IP=$IPAddress
#--------------------------------------------------------------------------------------------------
# ROS_Master 網路地址
export ROBOT_IP=$IPAddress
export ROS_MASTER_URI=http://$ROBOT_IP:11311
#--------------------------------------------------------------------------------------------------
# Alias path 跳轉快捷指令
alias cw='cd ~/ros2_ws'
alias cs='cd ~/ros2_ws/src'
alias cm='cd ~/ros2_ws && colcon build'
#--------------------------------------------------------------------------------------------------
# Bash 終端顯示
echo ""
echo "----------------------- HOST PC INFO -----------------------"
echo -e " ROS_MASTER_URI: \033[32m$ROS_MASTER_URI\033[0m"
echo -e " HOST PC ROS_IP: \033[32m$ROS_IP\033[0m"
echo "------------------------------------------------------------"
echo ""
#------------- HOSTPC CONFIG ----------------------------------------------------------------------
EOF
            ;;
        *)
            print_error "無效選項，程式結束"
            exit 1
            ;;
    esac
    echo ""
    print_warning "請重新開啟終端機或執行 'source ~/.bashrc' 來載入新環境"
    echo "=== Script by Chiawei ==="
}
main
