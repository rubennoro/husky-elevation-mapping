# **husky-elevation-mapping**

## **Introduction**
This repository consists of three ROS 2 packages that are used for elevation mapping in a robotic system. These packages provide essential functionality for localization, mapping, and sensor data processing. The three packages included in this repository are:

- **elevation_mapping_ros2** - Elevation mapping package for ROS 2 - https://github.com/siddarth09/elevation_mapping_ros2.
- **kindr** - A library for kinematics and dynamics representation - https://github.com/ANYbotics/kindr.
- **kindr_ros** - ROS 2 interface for the Kindr library - https://github.com/SivertHavso/kindr_ros/tree/ros2.

Additionally, for **point cloud processing**, we use Intel RealSense cameras. In this case, the **D455** model has been used. Make sure to also clone the official **Intel RealSense ROS 2** repository to enable point cloud processing:

- **Intel RealSense ROS 2 repository**: [(https://github.com/IntelRealSense/librealsense/blob/master/doc/distribution_linux.md)]

## **Installation & Usage**

### **Cloning the Repository**
To set up the workspace, clone this repository inside your ROS 2 workspace:

```bash
cd ~/rk_ws/src

git clone https://github.com/<your-username>/husky-elevation-mapping.git
```

If you haven't already cloned the **Intel RealSense ROS 2 repository**, do so now:

```bash
git clone https://github.com/IntelRealSense/realsense-ros.git
```

### **Building the Packages**
Once all required packages are cloned, navigate back to the workspace root and build the packages:
Add the Cmake argument for GPU acceleration of point cloud production with OpenGL.
```bash
cd ~/rk_ws
colcon build --symlink-install --cmake-args '-DBUILD_ACCELERATE_GPU_WITH_GLSL=ON' 
```

Source the workspace:

```bash
source install/setup.bash
```

### **Launching the System**

#### **1. Launch Elevation Mapping**

#### **2. Launch RealSense Camera for Point Clouds**
Ensure the Intel RealSense camera is connected, then launch the RealSense node:

```bash
ros2 launch realsense2_camera rs_launch.py pointcloud.enable:=true
```

#### **3. Visualizing the Map in RViz2**
Once the nodes are running, open **RViz2** to visualize the elevation map:

```bash
rviz2
```

In **RViz2**, add the following topics:

- `/elevation_map`
- `/camera/camera/depth/color/points` (for point cloud visualization)

## **Additional Notes**
- Ensure that your **Intel RealSense D455 camera** is properly connected and recognized by the system.
- You may need to tweak the **elevation mapping parameters** based on the environment.
- If any dependencies are missing, use:

  ```bash
  rosdep install --from-paths src --ignore-src -r -y
  ```
---

This repository is maintained for research and development purposes. Feel free to contribute and improve the functionality!
