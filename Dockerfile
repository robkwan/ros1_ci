# Base image
FROM osrf/ros:noetic-desktop

# Change the default shell to Bash
SHELL [ "/bin/bash" , "-c" ]

# Install Gazebo 11 and other dependencies
RUN apt-get update && apt-get install -y \
  ros-noetic-gazebo-ros-pkgs \
  ros-noetic-gazebo-ros-control \
  ros-noetic-ros-control \
  ros-noetic-ros-controllers \
  ros-noetic-joint-state-publisher \
  ros-noetic-robot-state-publisher \
  ros-noetic-robot-localization \
  ros-noetic-xacro \
  ros-noetic-tf2-ros \
  ros-noetic-tf2-tools \
  #ros-noetic-rmw-cyclonedds-cpp \
  python3-colcon-common-extensions \
  && rm -rf /var/lib/apt/lists/*

# Create workspace and download simulation repository

RUN source /opt/ros/noetic/setup.bash \
 && mkdir -p /simulation_ws/src 

# Copy your simulation package
COPY tortoisebot /simulation_ws/src/tortoisebot
COPY tortoisebot_waypoints /simulation_ws/src/tortoisebot_waypoints
COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

# Build the Colcon workspace and ensure it's sourced
RUN source /opt/ros/noetic/setup.bash \
 && cd /simulation_ws \
 && catkin_make
RUN echo "source /simulation_ws/devel/setup.bash" >> ~/.bashrc

# Set up a workspace directory
WORKDIR /simulation_ws/

# Set environment variables
ENV DISPLAY=:1
ENV GAZEBO_MASTER_URI=${GAZEBO_MASTER_URI}
ENV ROS_DOMAIN_ID=1
#ENV RMW_IMPLEMENTATION=rmw_cyclonedds_cpp

# We want /bin/bash to execute our /entrypoint.sh when container starts
CMD ["/entrypoint.sh"]