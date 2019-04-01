#!/bin/bash
#
# R5-COP Natural Language Interface ROS demo setup script
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

cd "$(dirname "$0")"
demo_home="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ ! -d "${demo_home}/NLdemo/" ]; then
  fail "R5-COP NL demo files are missing."
fi

if [ ! -x "${demo_home}/NLdemo/setup.sh" ]; then
  chmod +x "${demo_home}/NLdemo/setup.sh" "${demo_home}/NLdemo/start.sh" "${0}"
fi

NETDEV=$(ip route show |grep "default "|awk '{print $5}')
IPZONE=$(ip addr show ${NETDEV}|grep "inet "|awk '{print $2}')
IPADDR=$(echo $IPZONE | cut -d/ -f 1)
DISP_ID=$(echo $DISPLAY|cut -d : -f 2)
HOST_LSB=$(lsb_release  -c | cut -f 2)

rosdocker=$(docker ps -qa --filter "ancestor=ros:indigo")
if [ "$rosdocker" == "" ]; then
  if askif "ROS docker container does not exist. Create?" "y"; then
    ask rosdockername "Choose a short name for the ROS docker container" "roscore"
    echo "Creating and starting the ROS docker container..."
    docker run -t -d --net=host --env "DISPLAY=unix:${DISP_ID}" --env "HOST_LSB=${HOST_LSB}" --name $rosdockername -v ${demo_home}/.ros:/root/.ros -v ${demo_home}/.gazebo:/root/.gazebo -v ${demo_home}/jackal_navigation/:/root/jackal_navigation/ -v ${demo_home}/NLdemo/:/root/NLdemo/  -v /tmp/.X11-unix:/tmp/.X11-unix:rw --device=/dev/dri:/dev/dri --env="QT_X11_NO_MITSHM=1" ros:indigo $rosdockername ||  fail "Could not start ros docker image"
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

# No separate IP, we're using the host's network
# ROS_IP=$(docker inspect --format '{{.NetworkSettings.IPAddress }}' $is_running )
ROS_NAME=$(docker inspect --format '{{.Name }}' $is_running | cut -d / -f 2 )

cat <<EOF
ROS docker image is running as $ROS_NAME.
You can stop it any time by issuing docker stop $ROS_NAME
To remove the image use this command: docker rm $ROS_NAME
ROS version is `docker exec -it $ROS_NAME rosversion -d`
----------------------------------------------------
This script will now check the demo setup in the Docker container...
EOF

sleep 3

#xhost +inet:${ROS_IP}
#xhost +inet:${IPADDR}
xhost +local:unix
docker exec -it $ROS_NAME /root/NLdemo/setup.sh
[ ! -f ${demo_home}/NLdemo/.setup_ok ] && fail "Setup failed in the Docker container."

cat <<EOF
Finished doing preflight checks.
----------------------------------------------------
ROS core external addr is http://${IPADDR}:11311/
Your display is at ${IPADDR}:${DISP_ID}
Your host is running `lsb_release -d | cut -f 2` ($HOST_LSB)
You may start the demo now.
If anything goes wrong, stop the Docker container and start over.

EOF

ask pp "Press enter to start the demo." "enter"

echo "Launching demo..."
docker exec -it $ROS_NAME /bin/bash -c "/root/NLdemo/start.sh" || fail "Demo failed."
#docker exec -it $ROS_NAME /bin/bash -c "export DISPLAY=${IPADDR}:${DISP_ID} && /root/NLdemo/start.sh" || fail "Demo failed."
