# BASE IMAGE contains Pytorch, TorchVision, OpenCV, CUDA, TensorRT, and Ultralytics
FROM ultralytics/ultralytics:8.3.49-jetson-jetpack6

# Completely remove OpenCV
# RUN apt-get purge -y '*opencv*' && apt-get autoremove -y \
#     && apt-get clean

RUN apt-get update && \
    apt-get install -y --fix-missing && \
    dpkg --configure -a || true && \
    apt-get -f install || true && \
    rm -rf /var/lib/dpkg/info/binutils-aarch64-linux-gnu.* && \
    apt-get purge -y *opencv* nvidia-opencv opencv-samples-data* || true && \
    apt-get autoremove -y && apt-get clean

WORKDIR /husky_ws

# Install Basic packages
RUN apt-get update && apt-get install --no-install-recommends -y \
    apt-utils \
    nano \
    pkg-config \
    cmake \
    libeigen3-dev \
    wget \
    curl \
    libpthread-stubs0-dev \
    python3-setuptools \
    python3-pip \
    tmux

# Fix setuptools dependency
RUN pip install --upgrade setuptools==70.3.0

ENV DEBIAN_FRONTEND=noninteractive

# ROS 2 Humble Installation Steps
RUN apt-get update && apt-get install -y curl gnupg2 lsb-release \
    && curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/ros2.list > /dev/null

# Install humble
RUN apt-get update && apt-get install -y ros-humble-desktop \
    && echo "source /opt/ros/humble/setup.bash" >> ~/.bashrc

# Install bootstrap tools
RUN apt-get install --no-install-recommends -y \
    build-essential \
    python3-colcon-common-extensions \
    python3-rosdep \
    python3-vcstool \
    git

# Install realsense-ros from source
RUN rosdep init && rosdep update

# Add Intel RealSense repository
RUN mkdir -p /etc/apt/keyrings && \
    curl -sSfL https://librealsense.intel.com/Debian/librealsense.pgp -o /etc/apt/keyrings/librealsense.pgp && \
    echo "deb [signed-by=/etc/apt/keyrings/librealsense.pgp] https://librealsense.intel.com/Debian/apt-repo $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/librealsense.list && \
    apt-get update

# Install librealsense2
RUN apt-get update && apt-get install -y \
    librealsense2-utils librealsense2-dev librealsense2-dbg

# Install peripheral rtabmap packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    ros-humble-pcl-ros \
    ros-humble-perception-pcl \
    ros-humble-octomap-ros \
    ros-humble-nav2-costmap-2d \
    ros-humble-grid-map-ros \
    ros-humble-rosbag2-storage-mcap \
    ros-humble-rmw-cyclonedds-cpp \
    equivs

WORKDIR /home/husky_ws/src

#Clone ROS2 RS Wrapper into Source directory, includes the camera and the description packages
RUN git clone https://github.com/IntelRealSense/realsense-ros.git -b ros2-master

RUN git clone https://github.com/siddarth09/elevation_mapping_ros2.git
RUN git clone https://github.com/SivertHavso/kindr_ros.git -b ros2
RUN git clone https://github.com/ANYbotics/kindr.git

# Modify CMakeLists.txt to include Eigen3 paths
RUN sed -i '/include_directories(/a \
  include_directories(\
  include\
  ${EIGEN3_INCLUDE_DIRS}\
  /usr/include/eigen3\
  /usr/local/include/eigen3\
  )' /home/husky_ws/src/kindr_ros/kindr_ros/CMakeLists.txt


WORKDIR /home/husky_ws
#Build the 'kindr' package separately using CMake
RUN /bin/bash -c "source /opt/ros/humble/setup.bash && \
    cd /home/husky_ws/src/kindr && \
    rm -rf build && mkdir build && cd build && \
    cmake .. -DUSE_CMAKE=true && \
    make install"

# Install missing ROS dependencies
RUN rosdep update && rosdep install --from-paths /home/husky_ws/src --ignore-src -r -y

# Build the remaining packages using colcon (excluding kindr)
RUN /bin/bash -c "source /opt/ros/humble/setup.bash && \
    colcon build --symlink-install"

RUN echo "source /husky_ws/install/setup.bash" >> ~/.bashrc

# Style command prompt
RUN echo "export PS1='\\[\\e[1;35m\\]\\u@\\h:\\[\\e[1;34m\\]\\w\\[\\e[0m\\]\\$ '" >> ~/.bashrc

# Set ROS Domain ID
RUN echo "export ROS_DOMAIN_ID=9" >> ~/.bashrc

# Set the default command
CMD ["/bin/bash"]
