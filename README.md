# R5-COP natural language interface demo
This is a natural language robot interface demonstration using ROS, Jackal and Gazebo.
The main setup script (start...) will pull a Docker image and install the required software in that container.
It also configures the container to use the host's 3D acceleration capabilities (instead of the built-in software renderer).

## Requirements
- a Linux PC with basic 3D acceleration to run the Simulator
- an Android 4.1+ phone
- Internet connection for the mobile device and the PC
- Ubuntu 14.04 (or later)

## Basic installation using Docker
The demo runs in a Docker container and it will not modify your host machine.

#### Install docker
<code>sudo apt-get install docker.io</code>

#### Create a demo user and add it to the docker group (optional)
<code>sudo useradd -g docker -m rosdemo</code>  
<code>sudo passwd rosdemo</code>

#### If you're using an existing user, add it to the docker group:
<code>sudo adduser username docker</code>  
and perform a logout+login sequence to activate the new group setup

#### Login as the demo user and pull the demo files

#### Install the Voice Agent on an Android phone
Transfer voice-agent.apk to the phone, enable installation from unknown sources and install the application.

#### Setup and start the demo
<code>bash ./start-r5cop-NL-demo.sh</code>  
For the first run it will do many things in the Docker container that will take a long time (10-20 minutes).  
Subsequent runs will be much faster (the demo will start in under a minute).  
If anything goes wrong, the procedure can be restarted by removing the docker container and running the script again.

#### To manage the ROS core Docker container
(assuming that the name of the container is "roscore")
<code>docker ps</code> # should show the roscore running  
<code>docker ps -a</code> # shows all docker containers  
<code>docker exec -it roscore rosversion -d</code># should report "indigo"  
Stopping the ROS core: <code>docker stop roscore</code>  
Starting the ROS core again: <code>docker start roscore</code>  
Enter the ROS core docker image: <code>docker exec -it roscore bash</code>  
ROS logs can be found at .ros/logs/ on the host machine.  
To remove the ROS docker image: <code>docker stop roscore &amp;&amp; docker rm roscore</code>  

#### Troubleshooting

##### If you can't see the GUI of the simulator, "Can't open display:"
Check your host's GDM settings in <code>/etc/gdm/custom.conf</code>  
Remote X11 requests must be enabled. Add <code>DisallowTCP=false</code> to the <code>[security]</code> section.

##### If the Gazebo simulator shows nothing or a "mixed up" world...
Quit and restart the demo.

##### If you see libGL errors about missing drivers
See http://wiki.ros.org/docker/Tutorials/Hardware%20Acceleration for troubleshooting.
Also check the various log files created by the application and ROS modules.
