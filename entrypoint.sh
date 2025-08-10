#! /bin/bash 
set -euo pipefail

# Source ROS 2 environment
source /opt/ros/noetic/setup.bash
source /simulation_ws/devel/setup.bash

#prints each command and its arguments as they are executed for debugging
set -x

# Exit immediately if a command exits with a non-zero status
#set -e

#xhost +local:root &

#Launch tortoisebot gazebo
echo "$(date +'[%Y-%m-%d %T]') Starting tortoisebot gazebo..."
roslaunch tortoisebot_gazebo tortoisebot_playground.launch &
BG_PID=$!

# Wait for services
echo "[$(date '+%Y-%m-%d %T')] Waiting for services to initialize..."
until rosnode list 2>/dev/null >/dev/null; do sleep 1; done
until rostopic list | grep -q '/gazebo'; do sleep 1; done

#Launch waypoint action server
echo "$(date +'[%Y-%m-%d %T]') Starting waypoint action server..."
rosrun tortoisebot_waypoints tortoisebot_action_server.py 
#until rostopic list | grep -q '/tortoisebot_as'; do sleep 1; done

#Launch waypoint action server tests
echo "$(date +'[%Y-%m-%d %T]') Starting waypoint action server..."
set +e  # Don't exit immediately on test failures; we want to capture code
rostest tortoisebot_waypoints waypoints_test.test --reuse-master 
TEST_RESULT=$?
set -e

echo " * RESULT: $( [ $TEST_RESULT -eq 0 ] && echo SUCCESS || echo FAILURE )"

# --- Shutdown background process if started ---
if [ -n "${BG_PID:-}" ]; then
    echo "Stopping background process with PID $BG_PID"
    kill "$BG_PID" 2>/dev/null || true
    wait "$BG_PID" 2>/dev/null || true
fi

# --- Exit with the real test result ---
exit $TEST_RESULT