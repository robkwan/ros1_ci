#! /bin/bash 
set -euo pipefail

# Source ROS 2 environment
source /opt/ros/noetic/setup.bash
source /simulation_ws/devel/setup.bash

#prints each command and its arguments as they are executed for debugging
set -x

rostest tortoisebot_waypoints test_tortoisebot.launch