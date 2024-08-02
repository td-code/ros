#!/usr/bin/env bash
set -e

# colcon
HOME=/home/vscode
BASHRC_PATH=$HOME/.bashrc
grep -F "source /opt/ros/$ROS_DISTRO/setup.bash" $BASHRC_PATH || echo "source /opt/ros/$ROS_DISTRO/setup.bash" >> $BASHRC_PATH
grep -F "source /usr/share/colcon_argcomplete/hook/colcon-argcomplete.bash" $BASHRC_PATH || echo "source /usr/share/colcon_argcomplete/hook/colcon-argcomplete.bash" >> $BASHRC_PATH
chown vscode:vscode $BASHRC_PATH

# Fix rosdep permission
mkdir -p $HOME/.ros
cp -r /root/.ros/rosdep $HOME/.ros/rosdep
chown -R vscode:vscode $HOME/.ros

source /opt/ros/$ROS_DISTRO/setup.bash

mkdir -p /workspace/src
sudo chown vscode:vscode /workspace /workspace/src

exec "$@"
