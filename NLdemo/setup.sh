#! /bin/bash
#
# Shell script to set up the required software environment for the R5-COP Natural Language Interface ROS demo
# Created by Tamás Mészáros <meszaros@mit.bme.hu>
#

if [ ! -x /usr/bin/gazebo ] && [ -d /opt/ros/indigo ]; then
  echo "--- Installing the simulator. This may take a while..."
  sleep 3
  apt-get update
  apt-get -y install ros-indigo-jackal-simulator ros-indigo-jackal-desktop python-catkin-tools cmake python-catkin-pkg python-empy python-nose libgtest-dev ros-indigo-roslint ros-indigo-move-base ros-indigo-slam-gmapping ros-indigo-gazebo-ros-pkgs ros-indigo-gazebo-ros-control 
  echo done.
else
  echo "Gazebo is installed."
fi

source /opt/ros/indigo/setup.bash
  
if [ ! -f ~/jackal_navigation/devel/setup.bash ]; then
  echo "--- Setting up Jackal navigation. This may take a while..."
  sleep 3
  mkdir -p ~/jackal_navigation/src
  pushd ~/jackal_navigation/src
  catkin_init_workspace
  git clone https://github.com/jackal/jackal.git
  git clone https://github.com/jackal/jackal_simulator.git
  git clone https://github.com/clearpathrobotics/LMS1xx.git
  git clone https://github.com/ros-drivers/pointgrey_camera_driver.git
  cd ..
  catkin_make
  echo done.
  echo "--- Setting up R5-COP demo world in Jackal..."
  sed -i 's/"[^"]*jackal_race.world/"\/root\/NLdemo\/r5cop_world.sdf/' /root/jackal_navigation/src/jackal_simulator/jackal_gazebo/launch/jackal_world.launch
  echo done.
  popd
else
  echo "Jackal is installed."
fi

source ~/jackal_navigation/devel/setup.bash

if [ `grep -c jackal_race /opt/ros/indigo/share/jackal_gazebo/launch/jackal_world.launch` != 0 ]; then
  echo "--- Setting up R5-COP demo world in the global config..."
  sed -i 's/"[^"]*jackal_race.world/"\/root\/NLdemo\/r5cop_world.sdf/' /opt/ros/indigo/share/jackal_gazebo/launch/jackal_world.launch
  echo done.
else
  echo "R5-COP demo world is ready."
fi

if [ ! -x /usr/bin/java ]; then
  echo "--- Installing Oracle Java8..."
  sleep 3
  apt-get -y install software-properties-common python-software-properties
  apt-add-repository -y ppa:webupd8team/java && apt-get update
  apt-get -y install oracle-java8-installer
  echo done.
else
  echo "Java is installed."
fi

if [ ! -x /usr/bin/gazebo ] || [ ! -d /opt/ros/indigo ] || [ ! -f ~/jackal_navigation/devel/setup.bash ] || [ `grep -c jackal_race /opt/ros/indigo/share/jackal_gazebo/launch/jackal_world.launch` != 0 ] || [ ! -x /usr/bin/java ]; then
  echo "Setup failed."
else
  echo "Setup seems to be fine."
fi
