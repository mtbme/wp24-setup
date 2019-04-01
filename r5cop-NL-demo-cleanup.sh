#!/bin/bash
#
# R5-COP Natural Language Interface ROS demo cleanup script
# Created by Tamas Meszaros <meszaros@mit.bme.hu>
#

# ask a question and provide a default answer
# sets the variable to the answer or the default value
# 1:varname 2:question 3:default value
function ask() {
  echo -n "${2} [$3] "
  read pp
  if [ "$pp" == "" ]; then
    eval ${1}=$3
  else
    eval ${1}=$pp
  fi
}

# ask a yes/no question, returns true on answering y
# 1:question 2:default answer
function askif() {
  ask ypp "$1" "$2"
  [ "$ypp" == "y" ]
}

cd "$(dirname "$0")"
demo_home="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

rosdocker=$(docker ps -qa --filter "ancestor=ros:indigo")
if [ "$rosdocker" != "" ]; then
  echo "Removing the ROS docker container..."
  docker container rm -f $rosdocker
fi

if askif "Do you want to remove docker images and volumes?" "y"; then
  docker image rm ros:indigo
  docker volume prune -f
fi
