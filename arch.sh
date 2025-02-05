#!/bin/bash

# 全局变量
ROOT_MOUNT="/mnt"
BOOT_MOUNT=""
SWAP_PART=""

# 检查root权限
check_root() {
    [[ $EUID -ne 0 ]] && echo "必须使用root用户运行此脚本！" && exit 1
}

# 安装依赖工具
install_deps() {
    pacman -Sy --noconfirm dialog parted
}

# 主菜单界面
main_menu() {
    while true; do
        choice=$(dialog --clear --stdout \
            --title "Arch Linux 安装向导" \
            --menu "请选择操作：" 20 60 13 \
            1 "检查网络连接" \
            2 "分区和格式化磁盘" \
            3 "挂载文件系统" \
            4 "安装基础系统" \
            5 "配置系统基础设置" \
            6 "配置软件源" \
            7 "安装引导程序" \
            8 "安装桌面环境" \
            9 "创建用户账户" \
            10 "安装完成并重启" \
            0 "退出安装程序")
        
        case $choice in
            1) check_network ;;
            2) disk_partitioning ;;
            3) mount_filesystems ;;
            4) install_base ;;
            5) basic_config ;;
            6) configure_mirrors ;;
            7) install_bootloader ;;
            8) install_desktop ;;
            9) create_user ;;
            10) finish_installation ;;
            0) exit 0 ;;
        esac
    done
}

# 网络检查
check_network() {
    if ping -c 3 archlinux.org &>/dev/null; then
        dialog --msgbox "网络连接正常" 8 40
    else
        dialog --msgbox "网络连接失败，请先配置网络！" 8 50
        configure_wifi
    fi
}

# WiFi配置
configure_wifi() {
    if dialog --yesno "需要配置WiFi吗？" 8 40; then
        interface=$(ip link | awk -F: '$0 !~ "lo|vir|^[^0-9]"{print $2;getline}')
        rfkill unblock wifi
        ip link set $interface up
        
        SSID=$(dialog --inputbox "输入WiFi名称" 10 40 --stdout)
        PASS=$(dialog --passwordbox "输入WiFi密码" 10 40 --stdout)
        
        wpa_passphrase "$SSID" "$PASS" > /etc/wpa_supplicant.conf
        wpa_supplicant -B -i $interface -c /etc/wpa_supplicant.conf
        dhcpcd $interface
        
        check_network
    fi
}

# 磁盘分区
disk_partitioning() {
    DEVICE=$(dialog --stdout --title "选择磁盘" --menu "选择要操作的磁盘：" 20 60 10 \
        $(lsblk -dnpo NAME,SIZE | awk '{print $1 " " $2}'))
    [ -z "$DEVICE" ] && return

    cfdisk $DEVICE
    PARTITIONS=($(lsblk -lnpo NAME $DEVICE | tail -n +2))
    
    for part in "${PARTITIONS[@]}"; do
        dialog --yesno "格式化分区 $part 吗？" 10 50 && {
            fstype=$(dialog --stdout --menu "选择文件系统类型：" 12 40 6 \
                1 "ext4" \
                2 "btrfs" \
                3 "xfs" \
                4 "FAT32" \
                5 "swap")
            
            case $fstype in
                1) mkfs.ext4 $part ;;
                2) mkfs.btrfs $part ;;
                3) mkfs.xfs $part ;;
                4) mkfs.fat -F32 $part ;;
                5) mkswap $part ; swapon $part ;;
            esac
        }
    done
}

# 挂载文件系统
mount_filesystems() {
    ROOT_PART=$(dialog --stdout --title "选择根分区" --menu "选择根分区：" 20 60 10 \
        $(lsblk -lnpo NAME,SIZE,FSTYPE | grep -v 'swap' | awk '{print $1 " " $2 "(" $3 ")"}'))
    [ -z "$ROOT_PART" ] && return
    
    mount $ROOT_PART $ROOT_MOUNT
    
    if dialog --yesno "需要单独挂载/boot分区吗？" 8 40; then
        BOOT_PART=$(dialog --stdout --title "选择boot分区" --menu "选择boot分区：" 20 60 10 \
            $(lsblk -lnpo NAME,SIZE,FSTYPE | grep 'vfat\|fat' | awk '{print $1 " " $2 "(" $3 ")"}'))
        mkdir -p $ROOT_MOUNT/boot
        mount $BOOT_PART $ROOT_MOUNT/boot
    fi
}

# 安装基础系统
install_base() {
    packages=(
        base base-devel linux linux-firmware 
        vim nano git openssh networkmanager 
        man-db man-pages texinfo 
        grub efibootmgr os-prober
    )
    
    pacstrap $ROOT_MOUNT ${packages[@]}
    genfstab -U $ROOT_MOUNT >> $ROOT_MOUNT/etc/fstab
    dialog --msgbox "基础系统安装完成" 8 40
}

# 基本系统配置
basic_config() {
    # 时区配置
    arch-chroot $ROOT_MOUNT ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
    arch-chroot $ROOT_MOUNT hwclock --systohc
    
    # 本地化配置
    sed -i 's/#en_US.UTF-8/en_US.UTF-8/' $ROOT_MOUNT/etc/locale.gen
    sed -i 's/#zh_CN.UTF-8/zh_CN.UTF-8/' $ROOT_MOUNT/etc/locale.gen
    arch-chroot $ROOT_MOUNT locale-gen
    echo "LANG=en_US.UTF-8" > $ROOT_MOUNT/etc/locale.conf
    
    # 主机名
    hostname=$(dialog --inputbox "输入主机名" 10 40 --stdout)
    echo $hostname > $ROOT_MOUNT/etc/hostname
}

# 配置镜像源
configure_mirrors() {
    mirror_url=$(dialog --stdout --title "选择镜像源" --menu "选择镜像源：" 15 50 5 \
        "https://mirrors.tuna.tsinghua.edu.cn/archlinux/" "清华大学" \
        "https://mirrors.ustc.edu.cn/archlinux/" "中国科技大学" \
        "https://mirrors.zju.edu.cn/archlinux/" "浙江大学")
    
    cp $ROOT_MOUNT/etc/pacman.d/mirrorlist $ROOT_MOUNT/etc/pacman.d/mirrorlist.backup
    echo "Server = ${mirror_url}\$repo/os/\$arch" > $ROOT_MOUNT/etc/pacman.d/mirrorlist
    dialog --msgbox "镜像源已配置为：$mirror_url" 10 60
}

# 安装引导程序
install_bootloader() {
    if [ -d /sys/firmware/efi ]; then
        arch-chroot $ROOT_MOUNT grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=Arch
    else
        arch-chroot $ROOT_MOUNT grub-install --target=i386-pc $DEVICE
    fi
    arch-chroot $ROOT_MOUNT grub-mkconfig -o /boot/grub/grub.cfg
    dialog --msgbox "GRUB引导程序安装完成" 8 40
}

# 安装桌面环境
install_desktop() {
    DE=$(dialog --stdout --title "选择桌面环境" --menu "选择要安装的桌面环境：" 15 50 5 \
        "gnome" "GNOME桌面环境" \
        "plasma" "KDE Plasma桌面" \
        "xfce4" "XFCE轻量桌面" \
        "none" "跳过桌面安装")
    
    case $DE in
        gnome)
            arch-chroot $ROOT_MOUNT pacman -S --noconfirm gnome gnome-extra gdm
            arch-chroot $ROOT_MOUNT systemctl enable gdm
            ;;
        plasma)
            arch-chroot $ROOT_MOUNT pacman -S --noconfirm plasma sddm konsole dolphin
            arch-chroot $ROOT_MOUNT systemctl enable sddm
            ;;
        xfce4)
            arch-chroot $ROOT_MOUNT pacman -S --noconfirm xfce4 xfce4-goodies lightdm
            arch-chroot $ROOT_MOUNT systemctl enable lightdm
            ;;
    esac
}

# 创建用户
create_user() {
    username=$(dialog --inputbox "输入用户名" 10 40 --stdout)
    arch-chroot $ROOT_MOUNT useradd -m -G wheel -s /bin/bash $username
    arch-chroot $ROOT_MOUNT passwd $username
    
    # 配置sudo权限
    sed -i '/%wheel ALL=(ALL) ALL/s/^#//' $ROOT_MOUNT/etc/sudoers
}

# 完成安装
finish_installation() {
    umount -R $ROOT_MOUNT
    dialog --msgbox "安装完成！现在可以重启系统。" 10 40
    reboot
}

# 执行主流程
check_root
install_deps
main_menu
