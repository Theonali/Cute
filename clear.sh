#!/usr/bin/env bash

#==========Define color==========
Green_font_prefix="\033[32m"
Red_font_prefix="\033[31m"
Yellow_font_prefix="\033[1;33m"
Green_background_prefix="\033[42;37m"
Red_background_prefix="\033[41;37m"
Font_color_suffix="\033[0m"

info=${Green_font_prefix}[信息]${Font_color_suffix}
error=${Red_font_prefix}[错误]${Font_color_suffix}
tip=${Red_font_prefix}[提示]${Font_color_suffix}
#================================

#chek root
check_root() {
  [[ $EUID -ne 0 ]] && echo -e "${error}This script must be executed as root!" && exit 1
}

#check status
check_status(){
  systemctl restart mariadb
  [[ $? -eq 0 ]] && echo -e "${info} 数据库启动成功" && clear_sql || echo -e "${error} 数据库启动失败" && exit 1
}

clear_sql(){
  del_time=$(date -d $(date -d "$(date +%Y%m01) last day" +%Y%m%d) +%s) #选择上个月最后一天
  mysql -u$dbuser -p$dbpasswd zabbix -e"DELETE FROM history_uint WHERE 'clock' < $del_time"
  [[ $? -eq 0 ]] && echo -e "${info} 删除history_unit表成功" || echo -e "${error} 删除history_unit表失败"
  mysql -u$dbuser -p$dbpasswd zabbix -e"optimize table history_uint"
  [[ $? -eq 0 ]] && echo -e "${info} 清理history_unit空间成功" || echo -e "${error} 清理history_unit空间失败"
  mysql -u$dbuser -p$dbpasswd zabbix -e"DELETE FROM history WHERE 'clock' < $del_time"
  [[ $? -eq 0 ]] && echo -e "${info} 删除history表成功" || echo -e "${error} 删除history_unit表失败"
  mysql -u$dbuser -p$dbpasswd zabbix -e"optimize table history"
  [[ $? -eq 0 ]] && echo -e "${info} 清理history空间成功" || echo -e "${error} 清理history空间失败"
  mysql -u$dbuser -p$dbpasswd zabbix -e"DELETE FROM trends_uint WHERE 'clock' < $del_time"
  [[ $? -eq 0 ]] && echo -e "${info} 删除trends_uint表成功" || echo -e "${error} 删除trends_uint表失败"
  mysql -u$dbuser -p$dbpasswd zabbix -e"optimize table trends_uint"
  [[ $? -eq 0 ]] && echo -e "${info} 清理trends_uint空间成功" || echo -e "${error} 清理trends_uint空间失败"
  mysql -u$dbuser -p$dbpasswd zabbix -e"DELETE FROM trends WHERE 'clock' < $del_time"
  [[ $? -eq 0 ]] && echo -e "${info} 删除trends表成功" || echo -e "${error} 删除trends表失败"
  mysql -u$dbuser -p$dbpasswd zabbix -e"optimize table trends"
  [[ $? -eq 0 ]] && echo -e "${info} 清理trends空间成功" || echo -e "${error} 清理trends空间失败"
  echo -e "\n${info} 已完成。\n"
}

main(){
  clear
  check_root
  echo -e "
--数据库自动清理（ZABBIX专用）--"
  read -e -p "  请输入数据库用户名：" dbuser
  read -e -p "  请输入数据库密码：" dbpasswd
  check_status
}

main
