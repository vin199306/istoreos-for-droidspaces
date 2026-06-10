#!/bin/bash
# 调用适配脚本，修改ext4镜像适配Droidspaces
chmod +x $GITHUB_WORKSPACE/patches/post_adapt.sh
$GITHUB_WORKSPACE/patches/post_adapt.sh