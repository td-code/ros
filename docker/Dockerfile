ARG VARIANT=focal
FROM mcr.microsoft.com/vscode/devcontainers/base:${VARIANT}

RUN apt-get update -q && \
    DEBIAN_FRONTEND=noninteractive apt-get upgrade -y && \
    apt-get autoclean && \
    apt-get autoremove && \
    rm -rf /var/lib/apt/lists/*

RUN export DEBIAN_FRONTEND=noninteractive \
    && apt-get update -q \
    && apt-get install -y --no-install-recommends \
    build-essential curl git gnupg2 lsb-release \
    python3 python3-pip \
    python3-venv python3-setuptools python3-wheel python-is-python3 \
    vim-gtk bash-completion dos2unix \
    zsh \
    && rm -rf /var/lib/apt/lists/*

ARG ROS_DISTRO=foxy
ARG INSTALL_PACKAGE=desktop
ARG TARGETPLATFORM=linux/amd64

RUN apt-get update -q && \
    apt-get install -y curl gnupg2 lsb-release && \
    curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/ros2.list > /dev/null && \
    apt-get update -q && \
    apt-get install -y ros-${ROS_DISTRO}-${INSTALL_PACKAGE} \
    python3-argcomplete \
    python3-colcon-common-extensions \
    python3-rosdep python3-vcstool && \
    rosdep init

ENV ROS_DISTRO=${ROS_DISTRO}
ENV ROS_PYTHON_VERSION=3

RUN rosdep update

RUN echo "source /opt/ros/${ROS_DISTRO}/setup.bash" >> /etc/bash.bashrc \
    && echo "source /opt/ros/${ROS_DISTRO}/setup.zsh" >> /etc/zsh/zshrc

# Install simulation package only on amd64
# Not ready for arm64 for now (July 28th, 2020)
# https://github.com/Tiryoh/docker-ros2-desktop-vnc/pull/56#issuecomment-1196359860
RUN if [ "$TARGETPLATFORM" = "linux/amd64" ]; then \
    apt-get update -q && \
    apt-get install -y \
    ros-${ROS_DISTRO}-gazebo-ros-pkgs \
    ros-${ROS_DISTRO}-ros-ign; \
    fi

# Turtlebot (not useful without Gazebo)
RUN if [ "$TARGETPLATFORM" = "linux/amd64" ]; then \
    apt-get update -q && export DEBIAN_FRONTEND=noninteractive \
    && apt-get install -y --no-install-recommends \
    ros-${ROS_DISTRO}-cartographer \
    ros-${ROS_DISTRO}-cartographer-ros \
    ros-${ROS_DISTRO}-navigation2 \
    ros-${ROS_DISTRO}-nav2-bringup \
    ros-${ROS_DISTRO}-turtlebot3 \
    ros-${ROS_DISTRO}-turtlebot3-fake-node \
    ros-${ROS_DISTRO}-turtlebot3-gazebo \
    && rm -rf /var/lib/apt/lists/*; \
    fi

# Prepare Carla PythonAPI (currently, version 0.9.13)
RUN apt-get update -q && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends libsdl2-dev libsdl2-image-dev libsdl2-mixer-dev libsdl2-ttf-dev libfreetype6-dev libportmidi-dev libjpeg-dev \
    && apt-get -y install --no-install-recommends python3-networkx python3-matplotlib python3-numpy python3-pygame python3-opencv python3-distro python3-shapely \
    && apt-get -y install ros-${ROS_DISTRO}-tf-transformations ros-${ROS_DISTRO}-ackermann-msgs ros-${ROS_DISTRO}-derived-object-msgs \
    && python3 -m pip --disable-pip-version-check --no-cache-dir install --upgrade pip \
    && python3 -m pip --disable-pip-version-check --no-cache-dir install carla==0.9.13 \  
    && apt-get autoclean \
    && apt-get autoremove \
    && rm -rf /var/lib/apt/lists/*

COPY library-scripts/desktop-lite-debian.sh /tmp/library-scripts/
RUN apt-get update \
    && bash /tmp/library-scripts/desktop-lite-debian.sh \
    && rm -rf /var/lib/apt/lists/*
ENV DBUS_SESSION_BUS_ADDRESS="autolaunch:" DISPLAY=":1" LANG="en_US.UTF-8" LANGUAGE="en_US.UTF-8"

# Enable apt-get completion after running `apt-get update` in the container
RUN rm /etc/apt/apt.conf.d/docker-clean

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/usr/local/share/desktop-init.sh", "/entrypoint.sh"]
CMD ["sleep", "infinity"]
