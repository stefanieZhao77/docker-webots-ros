#!/bin/sh

if [ -z "$(ls -A /root/Desktop/ros_ws)" ]; then
   echo "Copying workspace..."
   cp /root/ws_tmp/* /root/Desktop/ros_ws -r
   chmod a+rwx /root/Desktop/ros_ws/ -R
fi