#!/usr/bin/env bash
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
  if [[ $os_version == "centos" ]]; then
      yum -y update
      rpm -Uvh https://repo.zabbix.com/zabbix/4.4/rhel/$VERSION_ID/x86_64/zabbix-release-4.4-1.el$VERSION_ID.noarch.rpm
      yum clean all
      yum -y install zabbix-agent
  elif [[ $os_version == "debian" ]]; then
      if [[ $VERSION_ID == "9" ]]; then
          wget https://repo.zabbix.com/zabbix/4.4/debian/pool/main/z/zabbix-release/zabbix-release_4.4-1+stretch_all.deb
          dpkg -i zabbix-release_4.4-1+stretch_all.deb && rm -rf zabbix-release_4.4-1+stretch_all.deb
      else
          wget https://repo.zabbix.com/zabbix/4.4/debian/pool/main/z/zabbix-release/zabbix-release_4.4-1+buster_all.deb
          dpkg -i zabbix-release_4.4-1+buster_all.deb && rm -rf zabbix-release_4.4-1+buster_all.deb
      fi
      apt update -y && apt install -y zabbix-agent

  elif [[ $os_version == "ubuntu" ]]; then
      if [[ $VERSION_ID == "16.04" ]]; then
          wget https://repo.zabbix.com/zabbix/4.4/ubuntu/pool/main/z/zabbix-release/zabbix-release_4.4-1+xenial_all.deb
          dpkg -i zabbix-release_4.4-1+xenial_all.deb && rm -rf zabbix-release_4.4-1+xenial_all.deb
      else
          wget https://repo.zabbix.com/zabbix/4.4/ubuntu/pool/main/z/zabbix-release/zabbix-release_4.4-1+bionic_all.deb
          dpkg -i zabbix-release_4.4-1+bionic_all.deb && rm -rf zabbix-release_4.4-1+bionic_all.deb
      fi
      apt update -y && apt install -y zabbix-agent
  fi

  sed -i "s/Server=127.0.0.1/Server=$zabbixip/g" /etc/zabbix/zabbix_agentd.conf
  sed -i "s/ServerActive=127.0.0.1/ServerActive=$zabbixip/g" /etc/zabbix/zabbix_agentd.conf
  sed -i "s/Hostname=Zabbix server/Hostname=$hostname/g" /etc/zabbix/zabbix_agentd.conf
  systemctl restart zabbix-agent
  [[ $? -eq 0 ]] && echo -e "${info}Succeed!" || echo -e "${error}Failled!"

}


#==manin
main(){
  clear
  check_root
  check_os
  echo -e "----ZABBIX AGENT AUTO INSTALL SCRIPT----"
  read -e -p "--Zabbix server IP: " zabbixip
  read -e -p "--Agent hostname: " hostname
  select_os
}

main
