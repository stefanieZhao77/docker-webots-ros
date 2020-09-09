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

RUN mkdir -p /root/ws_tmp /root/Desktop && ln -s /usr/share/applications/lxterminal.desktop /root/Desktop/lxterminal.desktop
ENV ROS_DISTRO=melodic

RUN /bin/bash -c "echo -e 'umask 000\n \
      source /opt/ros/melodic/setup.bash\n \
      cd /root/Desktop/ros_ws/\n' >> /root/.bashrc "

WORKDIR /root/ws_tmp
# COPY vnc/copyws.sh /root/copyws.sh
# RUN chmod a+x /root/copyws.sh
COPY ./src /root/ws_tmp/src

RUN apt-get update && rosdep install --from-paths . -r -y

RUN catkin config \
      --extend /opt/ros/melodic

# install webots
ARG WEBOTS_VERSION=R2020b-rev1

RUN apt update && apt install --yes wget
RUN wget https://raw.githubusercontent.com/cyberbotics/webots/master/scripts/install/linux_runtime_dependencies.sh
RUN chmod +x linux_runtime_dependencies.sh
RUN ./linux_runtime_dependencies.sh
RUN rm ./linux_runtime_dependencies.sh

RUN apt install --yes xvfb

WORKDIR /usr/local
RUN wget https://github.com/cyberbotics/webots/releases/download/$WEBOTS_VERSION/webots-$WEBOTS_VERSION-x86-64_ubuntu-16.04.tar.bz2
RUN tar xjf webots-$WEBOTS_VERSION-x86-64_ubuntu-16.04.tar.bz2
RUN rm webots-$WEBOTS_VERSION-x86-64_ubuntu-16.04.tar.bz2
RUN sed -i 's/"$webots_home\/bin\/webots-bin" "$@"/"$webots_home\/bin\/webots-bin" --no-sandbox "$@"/g' /usr/local/webots/webots
ENV WEBOTS_HOME /usr/local
ENV PATH /usr/local/webots:${PATH}

RUN apt-get install ros-melodic-webots-ros
