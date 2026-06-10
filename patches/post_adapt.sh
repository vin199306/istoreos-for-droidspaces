#!/bin/bash
set -e

IMG_PATH="./bin/targets/armsr/armv8/"
cd ${IMG_PATH}
# 找到ext4镜像
IMG=$(find . -name "*.root.ext4")

MNT_DIR="/mnt/istoreos"
sudo mkdir -p ${MNT_DIR}

# 挂载loop设备
LOOP_DEV=$(sudo losetup -f --show ${IMG})
sudo mount ${LOOP_DEV} ${MNT_DIR}

# 1. 重写fstab
sudo tee ${MNT_DIR}/etc/config/fstab >/dev/null <<'EOF'
config global
        option anon_swap '0'
        option anon_mount '0'
        option auto_swap '0'
        option auto_mount '1'
        option delay_root '5'
        option check_fs '0'
config mount
        option target '/'
        option device '/dev/root'
        option fstype 'ext4'
        option options 'rw,noatime'
EOF

# 2. 网络改为DHCP，适配虚拟网卡
sudo tee ${MNT_DIR}/etc/config/network >/dev/null <<'EOF'
config interface 'loopback'
        option ifname 'lo'
        option proto 'static'
        option ipaddr '127.0.0.1'
        option netmask '255.0.0.0'
config interface 'lan'
        option ifname 'eth0'
        option proto 'dhcp'
EOF

# 3. rc.local 关闭硬件服务
sudo tee ${MNT_DIR}/etc/rc.local >/dev/null <<'EOF'
#!/bin/sh
/etc/init.d/wireless stop
/etc/init.d/hostapd stop
/etc/init.d/dnsmasq disable
/etc/init.d/network restart
exit 0
EOF
sudo chmod +x ${MNT_DIR}/etc/rc.local

# 4. 删除内核模块，避免Android内核冲突
sudo rm -rf ${MNT_DIR}/lib/modules/*

# 卸载镜像
sudo umount ${MNT_DIR}
sudo losetup -d ${LOOP_DEV}

echo "===== 镜像适配 Droidspaces 完成 ====="