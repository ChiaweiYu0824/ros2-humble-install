<div align="center" style="background-color: white; padding: 20px;">
  <img src="https://learnopencv.com/wp-content/uploads/2024/06/ros2_humble-1.png" 
       alt="ROS 2 Humble" height="180" style="background-color: white; padding: 10px;">
       
  <div style="display: flex; justify-content: space-evenly; align-items: center; 
              flex-wrap: wrap; gap: 10px; background-color: white; padding: 10px;">
    <img src="https://robodyne-services.com/wp-content/uploads/2021/10/Turtlebot3_logo.png" 
         alt="TurtleBot3 Manipulation" height="180" style="background-color: white; padding: 10px;">
    <img src="https://raw.githubusercontent.com/ros-visualization/rviz/kinetic-devel/images/splash.png" 
         alt="RViz2" height="180" style="background-color: white; padding: 10px;">
    <img src="https://avatars.githubusercontent.com/u/1743799?s=280&v=4" 
         alt="Gazebo" height="190" style="background-color: white; padding: 10px;">
  </div>
</div>





# ROS 2 Humble Installation & Verification Guide 
![Build Status](https://img.shields.io/badge/build-passing-brightgreen) ![License](https://img.shields.io/badge/license-MIT-blue) ![ROS 2 Version](https://img.shields.io/badge/ROS2-Humble-orange)<br>
### Three options are available:
1. ROS2 Humble + Gazebo + TurtleBot3
2. ROS2 Humble + Gazebo
3. ROS2 Humble
---

# Table of Contents
1. [Install](#1install)  
2. [Build Workspace](#2build)  

<details>
<summary>3. <a href="#3check">Check</a></summary>

- [Check ROS 2 Related](#1check-ros2-related)  
- [Run Demo Nodes](#2run-demo-nodes)  
- [Run Turtlesim](#3run-turtlesim)  

</details>

<details>
<summary>4. <a href="#4start-gazebo">Start Gazebo</a></summary>

- [Set Turtlebot3 Model](#set-turtlebot3-model)  
- [Gazebo TurtleBot3 Simulation](#gazebo-turtlebot3-simulation)  

</details>

<details>
<summary>5. <a href="#5letgo-turtlebot3">Letgo TurtleBot3</a></summary>

- [Set Turtlebot3 Model](#1.set-turtlebot3-model)  
- [Gazebo TurtleBot3 Simulation](#2.gazebo-turtlebot3-simulation)  

</details>

<details>
<summary>6. <a href="#6helpful-instructions">Helpful Instructions</a></summary>

- [Gazebo Simulation Settings](#1-gazebo-simulation-settings)  
- [ROS Host Network Configuration](#2-ros-host-network-configuration)  
- [ROS Master Network Configuration](#3-ros-master-network-configuration)  
- [Workspace & Build Shortcuts](#4-workspace--build-shortcuts)  
- [Terminal Display](#5-terminal-display)  

</details>

7. [References](#references)  
8. [License](#license)  
9. [Disclaimer & Copyright](#disclaimer--copyright)  



---

# 1.Install
ros2-humble-install
```
wget -c https://raw.githubusercontent.com/ChiaweiYu0824/ros2-humble-install/main/install_ros2.sh && chmod +x ./install_ros2.sh && ./install_ros2.sh
```
# 2.Build
Build workspace
```
source /opt/ros/humble/setup.bash
cd ~/ros2_ws
colcon build
ls
echo "source /opt/ros/humble/setup.bash" >> ~/.bashrc
source ~/.bashrc
```
# 3.Check
## 1.Check ROS2 related
Version
```
echo $ROS_DISTRO
```
## 2.Run Demo Nodes
### C++ Example
Publisher
```
ros2 run demo_nodes_cpp talker
```
Subscriber(Add new terminal)
```
ros2 run demo_nodes_cpp listener
```
### Python Example
Publisher
```
ros2 run demo_nodes_py talker
```
Subscriber(Add new terminal)
```
ros2 run demo_nodes_py listener
```
## 3.Run Turtlesim
Turtlesim Node
```
ros2 run turtlesim turtlesim_node
```
Turtle Teleop (Add new terminal)
```
ros2 run turtlesim turtle_teleop_key
```
# 4.Start Gazebo
Run Gazebo 
```
gazebo
```
Launch Gazebo Demo World
```
gazebo worlds/rubble.world
```
---
# 5.Letgo TurtleBot3 
## 1.Set Turtlebot3 Model
Burger (Choose one of the three)
```
export TURTLEBOT3_MODEL=burger
```
Waffle (Choose one of the three) (Default)
```
export TURTLEBOT3_MODEL=waffle
```
Waffle_pi (Choose one of the three)
```
export TURTLEBOT3_MODEL=waffle_pi
```
## 2.Gazebo TurtleBot3 Simulation
Launch Simulation World
```
ros2 launch turtlebot3_gazebo turtlebot3_world.launch.py 
```
Operate TurtleBot3(Add new terminal)
```
ros2 run turtlebot3_teleop teleop_keyboard
```
---
# 6.Helpful Instructions
In this installed version, we have added the following features:
## 1. Gazebo Simulation Settings
- ROS_DOMAIN_ID: Isolates TurtleBot3 communication to prevent conflicts with other ROS 2 networks.
- SVGA_VGPU10=0: Ensures Gazebo works correctly in a virtualized GPU environment.
- TURTLEBOT3_MODEL: Sets the default TurtleBot3 model (waffle) used in the simulation.
## 2. ROS Host Network Configuration
- Automatically detects the host PC’s IP address.
- Sets ROS_IP to allow proper communication for ROS 2 nodes on the network.
- Ensures ROS nodes running on this host are accessible to other devices.
## 3. ROS Master Network Configuration
- ROBOT_IP is assigned for the host machine.  
- Configures ROS_MASTER_URI so all nodes communicate with the correct ROS master.
## 4. Workspace & Build Shortcuts
- cw: Navigate to the root of t
- cs: Navigate to the src folder.
- cm: Build the ROS 2 workspace using colcon.
- kg: Quickly terminate all running Gazebo servers and clients.
## 5. Terminal Display
- Displays the ROS 2 master URI and host IP when opening a terminal.
- Provides a quick verification that the environment is configured correctly.
#### You can open your bash configuration and scroll to the bottom to view the related settings by running:
```
gedit ~/.bashrc
```
---

## References
- [ROS 2 Humble Documentation](https://docs.ros.org/en/humble/index.html)
- [RViz2](https://docs.ros.org/en/rolling/p/rviz2/__links.html)
- [Gazebo Documentation](https://gazebosim.org/home)
- [ROS 2 Tutorials](https://docs.ros.org/en/humble/Tutorials.html)
- [TurtleBot3](https://emanual.robotis.com/docs/en/platform/turtlebot3/quick-start/)

## License
>  This guide is released under the **MIT License**. You are free to use, modify, and distribute it with attribution.

## Disclaimer & Copyright

> **Disclaimer**: This guide is provided "as is" for educational and reference purposes only. The author makes no warranties, express or implied, and disclaims all liability for any damages or losses arising from the use of this guide. Users assume all risks associated with using this guide.

> **Copyright Notice**: This guide is based on official ROS 2 documentation and open-source community resources, following the open-source spirit for technical learning and communication purposes. All referenced content is properly attributed with appropriate links to original sources.

> **Logos**: Property of respective organizations, used for educational purposes. 
