#!/usr/bin/bash
rclone sync ./ uni:/AppData/xf --progress --transfers 16 -v
