#! /bin/bash
#
# Shell script to start the R5-COP Natural Language Interface demo.
# Created by Tamas Meszaros <meszaros@mit.bme.hu>
#

# This script must be executed as root
if [ "`id -u`" != "0" ]; then
  sudo $0 $*
  exit
fi

cd ~/NLdemo

if [ ! -x /usr/bin/gazebo ] || [ ! -d /opt/ros/indigo ] || [ ! -f ~/jackal_navigation/devel/setup.bash ] || [ `grep -c jackal_race /opt/ros/indigo/share/jackal_gazebo/launch/jackal_world.launch` != 0 ] || [ ! -x /usr/bin/java ]; then
  echo "ERROR: environment is not set up properly. See the INSTALL guide."
  # list missing files
  ls -l /usr/bin/gazebo /opt/ros/indigo ~/jackal_navigation/devel/setup.bash /usr/bin/java >/dev/null
  exit
fi

NETDEV=$(ip route show |grep "default "|awk '{print $5}')
IPZONE=$(ip addr show ${NETDEV}|grep "inet "|awk '{print $2}')
IPADDR=$(echo $IPZONE | cut -d/ -f 1)

if [ "$ROS_IP" == "" ]; then
  export ROS_IP=$IPADDR
fi

export ROS_MASTER_URI=http://${ROS_IP}:11311

echo "Starting R5-COP natural language interface demo at $ROS_MASTER_URI"

source /opt/ros/indigo/setup.bash
source /usr/share/gazebo/setup.sh
# export GAZEBO_MODEL_DATABASE_URI=http://models.gazebosim.org
source ~/jackal_navigation/devel/setup.bash

echo "- Starting jackal_gazebo... (see gazebo.log)"
roslaunch jackal_gazebo jackal_world.launch config:=front_laser &> gazebo.log &
echo "- Start the Voice Agent on the mobile phone WHEN the simulator is ready,"
echo "  and connect to the ROS core at $ROS_MASTER_URI"
echo -n "  Waiting for successful launch..."
until [ "`rostopic list /R5COP_Management`" == "/R5COP_Management" ]; do
  echo -n "."
  sleep 3
done
echo "Ready. Voice Agent has been connected."
echo "- Starting jackal_navigation... (see odom.log and gmapping.log)"
roslaunch jackal_navigation odom_navigation_demo.launch &> odom.log &
roslaunch jackal_navigation gmapping.launch &> gmapping.log &
sleep 2
echo "- Starting Rviz... (see rviz.log)"
roslaunch jackal_viz view_robot.launch config:=gmapping &> rviz.log &
echo "- Starting R5-COP agents... (see agents.log)"
sleep 12
cat <<EOF
You should see additional commands appearing on the Voice Agent's interface in a few seconds.
To stop the demo simply close the ROSDisplay window or say goodbye to the agent.
EOF
java -jar AgentInterface.jar $ROS_MASTER_URI &> agents.log
echo "Demo has been stopped."
