#!/usr/bin/env bash

echo 'deb http://mirrors.aliyun.com/debian/ stretch main non-free contrib
      deb-src http://mirrors.aliyun.com/debian/ stretch main non-free contrib
      deb http://mirrors.aliyun.com/debian-security stretch/updates main
      deb-src http://mirrors.aliyun.com/debian-security stretch/updates main
      deb http://mirrors.aliyun.com/debian/ stretch-updates main non-free contrib
      deb-src http://mirrors.aliyun.com/debian/ stretch-updates main non-free contrib
      deb http://mirrors.aliyun.com/debian/ stretch-backports main non-free contrib
      deb-src http://mirrors.aliyun.com/debian/ stretch-backports main non-free contrib' > /etc/apt/sources.list




deb http://deb.debian.org/debian/ stretch main contrib non-free
deb http://deb.debian.org/debian/ stretch-updates main contrib non-free
deb http://deb.debian.org/debian-security/ stretch/updates main contrib non-free


########################
# Author: Etnous
# Blog: lala.biz
# Update Date: Jan 2, 2020
########################
#==========Define color==========
Green_font_prefix="\033[32m"
Red_font_prefix="\033[31m"
Yellow_font_prefix="\033[1;33m"
Green_background_prefix="\033[42;37m"
Red_background_prefix="\033[41;37m"
Font_color_suffix="\033[0m"

info=${Green_font_prefix}[Info]${Font_color_suffix}
error=${Red_font_prefix}[Error]${Font_color_suffix}
tip=${Red_font_prefix}[Tip]${Font_color_suffix}
#================================

#chek root
check_root() {
  [[ $EUID -ne 0 ]] && echo -e "${error}This script must be executed as root!" && exit 1
}

#check os
check_os() {
  osfile="/etc/os-release"
  if [ -e $osfile ]; then
    source $osfile
    case "$ID" in
    centos)
      if [[ $VERSION_ID -ge "7" ]]; then
        os_version="centos"
        echo -e "${info}${Yellow_font_prefix}Your system is $ID$VERSION_ID.${Font_color_suffix}\n"
      else
        echo -e "${error}${Yellow_font_prefix}Wrong VERSION_ID!${Font_color_suffix}\n" && exit 1
      fi
      ;;
    debian)
      if [[ $VERSION_ID -ge "9" ]]; then
        os_version="debian"
        echo -e "${info}${Yellow_font_prefix}Your system is $ID$VERSION_ID.${Font_color_suffix}\n"
      else
        echo -e "${error}${Yellow_font_prefix}Wrong VERSION_ID!${Font_color_suffix}\n" && exit 1
      fi
      ;;
    ubuntu)
      if [[ $VERSION_ID == "16.04" ]] || [[ $VERSION_ID == "18.04" ]]; then
        os_version="ubuntu"
        echo -e "${info}${Yellow_font_prefix}Your system is $ID$VERSION_ID.${Font_color_suffix}\n"
      else
        echo -e "${error}${Yellow_font_prefix}Wrong VERSION_ID!${Font_color_suffix}\n" && exit 1
      fi
      ;;
    *)
      echo -e "Wrong ID" && exit 1
      ;;
    esac
  else
    echo -e "${error}${Yellow_font_prefix}This script doesn't support your system!${Font_color_suffix}\n"
  fi
}

select_os(){
  if [[ $os_version == 'debian' ]]; then
    if [[ $VERSION_ID == '9' ]]; then
        echo "
        deb http://deb.debian.org/debian/ stretch main contrib non-free
        deb http://deb.debian.org/debian/ stretch-updates main contrib non-free
        deb http://ftp.debian.org/debian stretch-backports main contrib non-free
        deb http://deb.debian.org/debian-security/ stretch/updates main contrib non-free" > /etc/apt/sources.list
    elif [[ $VERSION_ID == '10' ]]; then
        echo "
        deb http://deb.debian.org/debian/ buster main contrib non-free
        deb http://deb.debian.org/debian/ buster-backports main contrib non-free
        deb http://deb.debian.org/debian-security/ buster/updates main contrib non-free" > /etc/apt/sources.list
    fi
  fi
}

main(){
  check_root
  check_os
  select_os
}

main