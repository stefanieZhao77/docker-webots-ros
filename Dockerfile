FROM dorowu/ubuntu-desktop-lxde-vnc:bionic


# Fix dirmngr
RUN apt-get purge dirmngr -y && apt-get update && apt-get install dirmngr -y
RUN apt-get dist-upgrade -y

# Adding keys for ROS
RUN sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
RUN apt-key adv --keyserver 'hkp://keyserver.ubuntu.com:80' --recv-key C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654

# Installing ROS
RUN apt-get update && apt-get install -y ros-melodic-desktop-full wget nano python-rosdep
RUN apt-get install -y \
      ros-melodic-libfranka python-catkin-tools libeigen3-dev 
RUN apt-get install -y python-rosinstall python-rosinstall-generator python-wstool build-essential
RUN apt-get install vim -y
RUN rosdep init && rosdep update

RUN mkdir -p /root/catkin_ws/src /root/Desktop && ln -s /usr/share/applications/lxterminal.desktop /root/Desktop/lxterminal.desktop
ENV ROS_DISTRO=melodic

RUN /bin/bash -c "echo -e 'umask 000\n \
      source /opt/ros/melodic/setup.bash\n \
      cd /root/Desktop/ros_ws/\n' >> /root/.bashrc "

WORKDIR /root/catkin_ws
# COPY vnc/copyws.sh /root/copyws.sh
# RUN chmod a+x /root/copyws.sh
# COPY ./src ~/catkin_ws/src

RUN apt-get update && rosdep install --from-paths . -r -y

RUN catkin config \
      --extend /opt/ros/melodic

# Install Moveit
RUN apt install ros-melodic-moveit

# install webots

# Determine Webots version to be used and set default argument
ARG WEBOTS_VERSION=R2021a


# Install Webots runtime dependencies
RUN apt update && apt install --yes wget && rm -rf /var/lib/apt/lists/
RUN wget https://raw.githubusercontent.com/cyberbotics/webots/master/scripts/install/linux_runtime_dependencies.sh
RUN chmod +x linux_runtime_dependencies.sh && ./linux_runtime_dependencies.sh && rm ./linux_runtime_dependencies.sh && rm -rf /var/lib/apt/lists/

# Install X virtual framebuffer to be able to use Webots without GPU and GUI (e.g. CI)
RUN apt update && apt install --yes xvfb && rm -rf /var/lib/apt/lists/

# Install Webots
WORKDIR /usr/local
RUN wget https://github.com/cyberbotics/webots/releases/download/$WEBOTS_VERSION/webots-$WEBOTS_VERSION-x86-64_ubuntu-18.04.tar.bz2
RUN tar xjf webots-*.tar.bz2 && rm webots-*.tar.bz2
ENV QTWEBENGINE_DISABLE_SANDBOX=1
ENV WEBOTS_HOME /usr/local/webots
ENV PATH /usr/local/webots:${PATH}
ENV LD_LIBRARY_PATH ${WEBOTS_HOME}/lib/controller
ENV PYTHONPATH ${WEBOTS_HOME}/lib/controller/python36

RUN sudo apt-get update && apt-get install ros-melodic-webots-ros
