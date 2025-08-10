#! /bin/bash 

# Source ROS 2 environment
source /opt/ros/noetic/setup.bash
source /simulation_ws/devel/setup.bash

#prints each command and its arguments as they are executed for debugging
set -x

# Exit immediately if a command exits with a non-zero status
set -e

#xhost +local:root &

#Launch tortoisebot gazebo
echo "$(date +'[%Y-%m-%d %T]') Starting tortoisebot gazebo..."
roslaunch tortoisebot_gazebo tortoisebot_playground.launch &

# Wait for services
echo "[$(date '+%Y-%m-%d %T')] Waiting for services to initialize..."
until rosnode list 2>/dev/null >/dev/null; do sleep 1; done
until rostopic list | grep -q '/gazebo'; do sleep 1; done

#Launch waypoint action server
echo "$(date +'[%Y-%m-%d %T]') Starting waypoint action server..."
rosrun tortoisebot_waypoints tortoisebot_action_server.py &
until rostopic list | grep -q '/tortoisebot_as'; do sleep 1; done

#Launch waypoint action server tests
echo "$(date +'[%Y-%m-%d %T]') Starting waypoint action server..."
rostest tortoisebot_waypoints waypoints_test.test --reuse-master 
TEST_RESULT=$?

# Clean up background processes
kill $WAYPOINT_PID $GAZEBO_PID
wait $WAYPOINT_PID 2>/dev/null || true
wait $GAZEBO_PID 2>/dev/null || true

# Exit with the test result so Jenkins gets pass/fail correctly
exit $TEST_RESULT