# R5-COP natural language interface demo

## Requirements
- a Linux PC with basic 3D acceleration to run the Simulator
- an Android 4.1+ phone
- Internet connection for the mobile device and the PC

## Basic installation using Docker
The demo runs in a Docker container and it will not modify your host machine.
This method requires Ubuntu 14.04 (newer versions might also work).

#### Install docker
sudo apt-get install docker.io

#### Create a demo user and add it to the docker group (optional)
sudo useradd -g docker -m rosdemo
sudo passwd rosdemo

#### If you're using an existing user, add it to the docker group:
sudo adduser username docker
and perform a logout+login sequence to activate the new group setup

#### Login as the demo user and pull the demo files

#### Install the Voice Agent on an Android phone
Transfer voice-agent.apk to the phone, enable installation from unknown sources and install the application.

#### Setup and start the demo
./start-r5cop-NL-demo.sh
For the first run it will do many things in the Docker container that will take a long time (5-10 minutes).
Subsequent runs will be much faster (the demo will start in under a minute).
If anything goes wrong, the procedure can be restarted by removing the docker container and running the script again.

#### To manage the ROS core Docker container
(assuming that the name of the container is "roscore")
docker ps # Should show the roscore running
docker ps -a # Shows all docker containers
docker exec -it roscore rosversion -d # should report "indigo"
Stopping the ROS core: docker stop roscore
Starting the ROS core again: docker start roscore
Enter the ROS core docker image: docker exec -it roscore bash
ROS logs can be found at .ros/logs/ on the host machine.
To remove the ROS docker image: docker stop roscore && docker rm roscore

#### Troubleshooting

##### If you can't see the GUI of the simulator, "Can't open display:"
Check your host's GDM settings in /etc/gdm/custom.conf
Remote X11 requests must be enabled. Add "DisallowTCP=false" to the "[security]" section.

##### If the Gazebo simulator shows nothing or a "mixed up" world...
Quit and restart the demo.
