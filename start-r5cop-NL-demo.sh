#!/bin/bash
#
# Simple shell script to set up and start the R5-COP Natural Language Interface ROS demo
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

# print a warning message
function warn() {
  echo "WARN: $1"
}

# print an error message and exit
function fail() {
  echo "ERROR: $1"
  exit 1
}

echo "------ R5-COP Natural Language interface demo ------"

if [ ! -x /usr/bin/docker ]; then
  fail "Docker is not installed."
else
  echo Docker found at /usr/bin/docker.
fi

demo_home="$(dirname "$0")"
cd "${demo_home}"

if [ ! -d "${demo_home}/NLdemo/" ]; then
  fail "R5-COP NL demo files are missing."
fi

if [ ! -x "${demo_home}/NLdemo/setup.sh" ]; then
  chmod +x "${demo_home}/NLdemo/setup.sh" "${demo_home}/NLdemo/start.sh" "${0}"
fi

NETDEV=$(ip route show |grep "default "|awk '{print $5}')
IPZONE=$(ip addr show ${NETDEV}|grep "inet "|awk '{print $2}')
IPADDR=$(echo $IPZONE | cut -d/ -f 1)

rosdocker=$(docker ps -qa --filter "ancestor=ros:indigo")
if [ "$rosdocker" == "" ]; then
  if askif "ROS docker container does not exist. Create?" "y"; then
     ask rosdockername "Choose a short name for the ROS docker container" "roscore"
     echo "Creating and starting the ROS docker container..."
     docker run -t -d --net=host --name $rosdockername -v ${demo_home}/.ros:/root/.ros -v ${demo_home}/.gazebo:/root/.gazebo -v ${demo_home}/jackal_navigation/:/root/jackal_navigation/ -v ${demo_home}/NLdemo/:/root/NLdemo/ ros:indigo $rosdockername ||  fail "Could not start ros docker image"
     # OLD docker run -t -d --name $rosdockername -v ${demo_home}/.ros:/root/.ros -v ${demo_home}/jackal_navigation/:/root/jackal_navigation/ -v ${demo_home}/r5copdemo/:/root/r5copdemo/ -p 11311:11311 ros:indigo $rosdockername ||  fail "Could not start ros docker image"
    is_running=$(docker ps -q --filter "ancestor=ros:indigo" --filter "status=running")
    if [ "$is_running" == "" ]; then
      fail "Could not start the ros docker image"
    fi
  else
     fail "Can not continue without the Docker image."
  fi
else
  is_running=$(docker ps -qa --filter "ancestor=ros:indigo" --filter "status=running")
  if [ "$is_running" == "" ]; then
    echo "Starting the ROS docker container..."
    docker start $rosdocker 2>/dev/null
    is_running=$(docker ps -q --filter "ancestor=ros:indigo" --filter "status=running")
    if [ "$is_running" == "" ]; then
      fail "Could not start the ros docker image"
    fi
  fi
fi

ROSIP=$(docker inspect --format '{{.NetworkSettings.IPAddress }}' $is_running )
cat <<EOF
ROS docker image is running as $is_running at $ROSIP.
You can stop it any time by issuing docker stop $is_running
To remove the image use this command: docker rm $is_running
ROS version is `docker exec -it $is_running rosversion -d`
----------------------------------------------------
This script will now check the demo setup in the Docker container...
EOF

sleep 3

docker exec -it $is_running /root/NLdemo/setup.sh

cat <<EOF
Finished doing preflight checks.
----------------------------------------------------
ROS core external addr is http://${IPADDR}:11311/
You may start the demo now.
If anything goes wrong, stop the Docker container and start over.

EOF

ask pp "Press enter to start the demo." "enter"

echo "Launching demo..."
xhost +inet:${ROSIP}
xhost +inet:${IPADDR}
docker exec -it $is_running /bin/bash -c "export DISPLAY=${IPADDR}:0 && /root/NLdemo/start.sh" || fail "Demo failed."
