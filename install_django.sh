#!/usr/bin/env bash
########################
# Author: Zheng Changyun
# Tele:560-19959
# Update Date: December 17, 2019
########################
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
#=====WELCOME=====
install_figlet() {

  man figlet &>/dev/null
  if [[ $? -ne 0 ]]; then
    if [[ $os_version == "centos" ]]; then
      echo -e "${Yellow_font_prefix}Preparing to start, please wait...${Font_color_suffix}\n"
      yum update -y &>/dev/null
      yum install -y figlet &>/dev/null
    else
      echo -e "${Yellow_font_prefix}Preparing to start, please wait...${Font_color_suffix}\n"
      apt update -y &>/dev/null
      apt install -y figlet &>/dev/null
    fi
  else
    return
  fi
}

check_python_status() {
  pyvr=$(python --version)
  if [[ -z $pyvr ]]; then
    echo -e "${error}You haven't install python3!" && exit 1
  else
    echo -e "${info}${Yellow_font_prefix}Your current verison is $pyvr.\nPreparing to install Django!${Font_color_suffix}\n" && check_project_list
  fi
}

set_project_name() {
  while true; do
    echo -e "--${info}请输入项目名称--"
    read -e -p "  (不支持中文，必须英文开头否则报错)：" project_name
    zh_pr_na=$(echo $project_name | awk '{print gensub(/[!-~]/,"","g",$0)}')
    if [[ -n $project_name ]]; then
      if [[ ${project_name:0:1} =~ ^[0-9]*$ ]] || [[ -n $zh_pr_na ]]; then
        echo -e "  ${error}输入错误！请重新输入！\n"
      else
        echo -e "\n  ${info}项目名称为：$project_name\n"
        break
      fi
    else
      echo -e "  ${error}输入错误！请重新输入！\n"
    fi
  done
}


set_sql_config() {
  echo -e "\n--${info}请输入数据库信息--\n"
  read -e -p "--数据库名称（英文）：" dbname
  echo "host = '127.0.0.1'" >>/root/config.py
  echo "port = 3306" >>/root/config.py
  echo "charset = 'utf8'" >>/root/config.py
  echo "dbname = '$dbname'" >>/root/config.py
  echo -e "\n    数据库名为：$dbname\n"
  echo -e "--数据库用户名为：${Green_font_prefix}root${Font_color_suffix}\n" && dbuser='root'
  echo "dbuser = '$dbuser'" >>/root/config.py
  read -e -p "--数据库密码：" dbpasswd
  echo "dbpasswd = '$dbpasswd'" >>/root/config.py
  echo -e "    数据库密码为：$dbpasswd\n"
}

set_django_config() {
  echo -e "\n${info}----请配置Django参数----\n"
  read -e -p "  请输入交换机SNAP密码：" switchpasswd
  echo "#==交换机" >>/root/config.py
  echo "switchpasswd = '$switchpasswd'" >>/root/config.py
  echo "cpufile = '/data/$project_name/python_script/cpu.txt'" >>/root/config.py
  echo "dnsfile = '/data/$project_name/python_script/dnslist.txt'" >>/root/config.py
  echo "mstpfilepath = '/data/$project_name/static/js/mstp_data.json'" >>/root/config.py
  read -e -p "  请输入zabbix LAN服务器IP：" zabbixlan
  echo "#==zabbix" >>/root/config.py
  echo "zabbixlan = '$zabbixlan'" >>/root/config.py
  read -e -p "  请输入zabbix WAN服务器IP：" zabbixwan
  echo "zabbixwan = '$zabbixwan'" >>/root/config.py
  read -e -p "  请输入zabbix 用户名：" zauser
  echo "zauser = '$zauser'" >>/root/config.py
  read -e -p "  请输入zabbix 密码：" zapasswd
  echo "zapasswd = '$zapasswd'" >>/root/config.py
  read -e -p "  请输入监控主干设备所在zabbix群组：" langroup
  echo "langroup = '$langroup'" >>/root/config.py
  read -e -p "  请输入监控专线所在zabbix群组：" wangroup
  echo "wangroup = '$wangroup'" >>/root/config.py
  read -e -p "  请输入监控集团名称（例如CNSBG,A次）：" groupname
  echo "groupname = '$groupname'" >>/root/config.py
  echo -e "x_len = [\n]" >>/root/config.py
  echo -e "y_len = [\n]" >>/root/config.py
  echo -e "text_len = [\n]" >>/root/config.py

}

set_all_config() {
  set_project_name
  set_sql_config
  set_django_config

  clear
  echo -e "
--以下为数据库配置信息，请仔细检查是否有误--
--数据库名称：${Green_font_prefix}$dbname${Font_color_suffix}
--数据库用户名：${Green_font_prefix}$dbuser${Font_color_suffix}
--数据库密码：${Green_font_prefix}$dbpasswd${Font_color_suffix}
--数据库主机：${Green_font_prefix}127.0.0.1${Font_color_suffix}
--数据库端口：${Green_font_prefix}3306${Font_color_suffix}
---------------------------------------
---以下为项目配置信息，请仔细检查是否有误---
--交换机SNAP密码：${Green_font_prefix}$switchpasswd${Font_color_suffix}
--主干设备IP表：${Green_font_prefix}cpu.txt${Font_color_suffix}
--DNS IP表：${Green_font_prefix}dnslist.txt${Font_color_suffix}
--专线流量状态信息：${Green_font_prefix}mstp_data.json${Font_color_suffix}
--zabbix LAN服务器IP：${Green_font_prefix}$zabbixlan${Font_color_suffix}
--zabbix WAN服务器IP：${Green_font_prefix}$zabbixwan${Font_color_suffix}
--zabbix 用户名：${Green_font_prefix}$zauser${Font_color_suffix}
--zabbix 用户密码：${Green_font_prefix}$zapasswd${Font_color_suffix}
--监控主干设备所在群组：${Green_font_prefix}$langroup${Font_color_suffix}
--监控专线所在群组：${Green_font_prefix}$wangroup${Font_color_suffix}
--监控集团名称：${Green_font_prefix}$groupname${Font_color_suffix}
----------------------------------------
"
  read -e -p "是否继续？[y/n]:" yn
  case $yn in
  Y | y)
    isntall_django
    ;;
  N | n)
    echo -e "${error}已取消。" && rm -rf /root/config.py && exit 1
    ;;
  *)
    echo -e "${error}输入错误！" && rm -rf /root/config.py && exit 1
    ;;
  esac
}

install_mariadb() {
  #====安装数据库=====
  if [[ $os_version == "centos" ]]; then
    yum -y install mariadb mariadb-server mariadb-devel
    [[ $? -ne 0 ]] && echo -e "${error} yum安装数据库失败！" && exit 1
  else
    apt -y install mariadb mariadb-server mariadb-devel
    [[ $? -ne 0 ]] && echo -e "${error} apt安装数据库失败！" && exit 1
  fi
  systemctl start mariadb && systemctl enable mariadb
  #---初始化数据库---
  /usr/bin/mysqladmin -u $dbuser password $dbpasswd
  if [[ $? -eq 0 ]]; then
    sed -i '/\[mysqld\]/a\character-set-server=utf8' /etc/my.cnf.d/server.cnf
    mysql -u$dbuser -p$dbpasswd -e "delete from mysql.user where user='';"
    [[ $? -ne 0 ]] && echo -e "${error} 删除匿名用户失败！" && exit 1
    mysql -u$dbuser -p$dbpasswd -e "drop database test;"
    [[ $? -ne 0 ]] && echo -e "${error} 删除测试数据库失败！" && exit 1
    mysql -u$dbuser -p$dbpasswd -e "grant all privileges on *.* to $dbuser@localhost identified by '$dbpasswd' with grant option;"
    mysql -u$dbuser -p$dbpasswd -e "grant all privileges on *.* to $dbuser@'%' identified by '$dbpasswd' with grant option;"
    [[ $? -ne 0 ]] && echo -e "${error} 开启远程登录失败！" && exit 1
    mysql -u$dbuser -p$dbpasswd -e "FLUSH PRIVILEGES;"
    mysql -u$dbuser -p$dbpasswd -e "create database $dbname;"
    [[ $? -ne 0 ]] && echo -e "${error} 创建数据库失败！" && exit 1 || echo -e "${info}创建数据库成功！\n"
    systemctl restart mariadb && echo -e "${info}数据库启动成功！\n" || echo -e "${error}数据库启动失败！\n"
  else
    echo -e "${info}数据库配置已存在！\n"
    mysql -u$dbuser -p$dbpasswd -e "create database $dbname;"
    [[ $? -ne 0 ]] && echo -e "${error} 创建数据库失败！" && exit 1 || echo -e "${info}创建数据库成功！\n"
  fi
}

config_settings() {
  #====配置settings.py====
  cd /data && django-admin startproject $project_name
  sed -i "s/^.*ALLOWED_HOSTS.*$/ALLOWED_HOSTS = \['*'\]/" /data/$project_name/$project_name/settings.py
  sed -i "/django.middleware.csrf.CsrfViewMiddleware/ s/^/#/" /data/$project_name/$project_name/settings.py
  sed -i "s/^.*'DIRS': \[\].*$/        'DIRS': \[os.path.join(BASE_DIR, 'templates')],/" /data/$project_name/$project_name/settings.py
  sed -i "/STATIC_URL/a \STATICFILES_DIRS = (\n    os.path.join(BASE_DIR, 'static'),\n)" /data/$project_name/$project_name/settings.py
  sed -i '/DATABASES/,+5d;:go;1,2!{P;$!N;D};N;bgo' /data/$project_name/$project_name/settings.py
  sed -i "/Database/a \DATABASES = {\n\t'default':{\n\t'ENGINE': 'django.db.backends.mysql',\n\t'NAME': '$dbname',\n\t'USER': '$dbuser',\n\t'PASSWORD': '$dbpasswd',\n\t'HOST': '127.0.0.1',\n\t'PORT': 3306\n\t}\n}" /data/$project_name/$project_name/settings.py
  sed -i "s/^.*LANGUAGE_CODE.*$/LANGUAGE_CODE = 'zh-hans'/" /data/$project_name/$project_name/settings.py
  sed -i "s/^.*TIME_ZONE.*$/TIME_ZONE = 'Asia\/Shanghai'/" /data/$project_name/$project_name/settings.py
  cat >>/data/$project_name/$project_name/settings.py <<EOF
WHITE_CLIENT_LIST = [
]
EOF

  #------报错注释------
  cp /usr/local/sbin/python-$pyv/lib/python3.$pyb/site-packages/django/db/backends/mysql/base.py /usr/local/sbin/python-$pyv/lib/python3.$pyb/site-packages/django/db/backends/mysql/base.py.bak
  cp /usr/local/sbin/python-$pyv/lib/python3.$pyb/site-packages/django/db/backends/mysql/operations.py /usr/local/sbin/python-$pyv/lib/python3.$pyb/site-packages/django/db/backends/mysql/operations.py.bak
  sed -i "/if version/ s/^/#/" /usr/local/sbin/python-$pyv/lib/python3.$pyb/site-packages/django/db/backends/mysql/base.py
  sed -i "/or newer is required/ s/^/#/" /usr/local/sbin/python-$pyv/lib/python3.$pyb/site-packages/django/db/backends/mysql/base.py
  #sed -i 's/decode/encode/' /usr/local/sbin/python-$pyv/lib/python3.$pyb/site-packages/django/db/backends/mysql/operations.py #django2.0版本
}

isntall_django() {
  if [[ $os_version == "centos" ]]; then
    yum -y remove firewalld
    setenforce 0
    sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config
    yum install -y net-snmp net-snmp-utils
  fi
  pyb=${pyvr:9:1}
  pyv=${pyvr:7:5}
  mkdir -p /data && cd /data
  pip install django
  rm -rf /usr/local/bin/django-admin
  rm -rf /usr/local/bin/django-admin.py
  ln -s /usr/local/sbin/python-$pyv/lib/python3.$pyb/site-packages/django/bin/django-admin.py /usr/local/bin/django-admin

  #===安装数据库===
  install_mariadb

  #====配置settings.py====
  config_settings


  #=====安装app=====
  cd /data/$project_name
  pip install mysqlclient pymysql
  python manage.py startapp web
  sed -i "/INSTALLED_APPS/a \    'web.apps.WebConfig'," /data/$project_name/$project_name/settings.py
  cat >/data/$project_name/web/__init__.py <<-EOF
import pymysql
pymysql.install_as_MySQLdb()
EOF

  #====安装网站源码====
  cd /root && tar -zxf /root/source.tar.gz && chmod -R 755 /root/source
  mv /root/source/python_script /data/$project_name/python_script
  mv /root/source/static /data/$project_name/static
  mv /root/source/templates /data/$project_name/templates
  mv /root/source/utils /data/$project_name/utils
  mv -f /root/source/project/* /data/$project_name/$project_name/
  mv -f /root/source/web/* /data/$project_name/web/
  [[ $? -ne 0 ]] && echo -e "${error}网页源码布置失败！" && exit 1 || echo -e "${info}网页源码布置成功！"
  rm -rf /root/source
  sed -i "s/groupname/$groupname/g" /data/$project_name/templates/index.html

  #====安装zabbix依赖====
  pip install netmiko IPy Pillow nmap requests pyzabbix plotly python-nmap
  [[ $? -ne 0 ]] && echo -e "${error}安装zabbix依赖失败！" && exit 1 || echo -e "${info}安装zabbix依赖成功！"

  mv /root/config.py /data/$project_name/ && chmod 755 /data/$project_name/config.py

  sed -i "s/'path'/'\/data\/$project_name\/'/g" /data/$project_name/python_script/init_sql.py
  sed -i "s/'path'/'\/data\/$project_name\/'/g" /data/$project_name/python_script/get_cpu_1min.py
  sed -i "s/'path'/'\/data\/$project_name\/'/g" /data/$project_name/python_script/get_dns_status.py
  sed -i "s/'path'/'\/data\/$project_name\/'/g" /data/$project_name/python_script/get_mstp_bandwidth.py
  #==初始化监控数据==
  cd /data/$project_name/
  python manage.py makemigrations
  python manage.py migrate
  python /data/$project_name/python_script/init_sql.py all
  [[ $? -ne 0 ]] && echo -e "${error}\n初始化监控数据失败。\n" && exit 1 || echo -e "${info}\n初始化监控数据成功！\n"
  cd /data/$project_name/
  echo -e "${info}  创建全局管理员。"
  python manage.py createsuperuser
  [[ $? -ne 0 ]] && echo -e "${error}\n创建全局管理员失败。\n" && exit 1 || echo -e "${info}\n创建成功，启动Django后，请使用用户名密码登录 http://ip/admin设置网站管理员。\n"
  crontab -l | {
    cat
    echo "*/1 * * * * python /data/$project_name/python_script/get_dns_status.py >> /data/$project_name/python_script/auto_get_dns_status.log"
  } | crontab -
  crontab -l | {
    cat
    echo "*/1 * * * * python /data/$project_name/python_script/get_mstp_bandwidth.py >> /data/$project_name/python_script/auto_get_mstp_bandwidth.log"
  } | crontab -
  crontab -l | {
    cat
    echo "* * * */1 * cd /data/$project_name/python_script/ && rm -rf auto_get_cpu.log auto_get_dns_status.log auto_get_mstp_bandwidth.log"
  } | crontab -

}

check_project_list() {
  pro_list=$(ls /data)
  if [[ -z $pro_list ]]; then
    if [[ -e /root/source.tar.gz ]]; then
      set_all_config
    else
      echo -e "${error}/root/目录下未检测到source.tar.gz文件，请检查！\n" && exit 1
    fi
  else
    echo -e "${tip}警告！已存在Django项目，继续会引发许多未知问题！如继续，请确保可以手动处理问题！"
    read -e -p "是否继续？[Y/N]:" yn
    case $yn in
    Y | y)
      set_all_config
      ;;
    N | n)
      read -p "是否删除已存在项目（不可恢复）？[Y/N]:" yny
      case $yny in
      Y | y)
        remove_project
        ;;
      N | n)
        echo -e "${tip}脚本退出！\n" && exit 0
        ;;
      *)
        echo -e "${tip}输入错误，脚本退出！\n" && exit 1
        ;;
      esac
      ;;
    *)
      echo -e "${tip}输入错误，脚本退出！\n" && exit 1
      ;;
    esac
  fi
}

remove_project() {
  cd /root
  pro_list=$(ls /data)
  if [[ ! -d '/data' ]] || [[ -z $pro_list ]]; then
    echo -e "${tip}你还没有安装项目，请先安装！\n" && exit 1
  fi
  read -e -p "确定删除项目：$pro_list？[Y/N]:" yun
  case $yun in
  Y | y)
    for list in $pro_list; do
      rm -rf /data/$list
    done
    echo -e "${info}$list已删除！\n"
    ;;
  N | n)
    echo -e "${tip}已取消！\n" && exit 0
    ;;
  *)
    echo -e "${error}输入错误！\n" && exit 1
    ;;
  esac
  pyvr=$(python --version)
  pyb=${pyvr:9:1}
  pyv=${pyvr:7:5}
  mv -f /usr/local/sbin/python-$pyv/lib/python3.$pyb/site-packages/django/db/backends/mysql/base.py.bak /usr/local/sbin/python-$pyv/lib/python3.$pyb/site-packages/django/db/backends/mysql/base.py
  mv -f /usr/local/sbin/python-$pyv/lib/python3.$pyb/site-packages/django/db/backends/mysql/operations.py.bak /usr/local/sbin/python-$pyv/lib/python3.$pyb/site-packages/django/db/backends/mysql/operations.py
  #---删除数据库信息---
  echo -e "--请输入要删除数据库信息--\n"
  read -e -p "  请输入要删除数据库名称：" dbname
  echo -e "\n  数据库用户名：${Green_font_prefix}root${Font_color_suffix}\n" && dbuser=root
  read -e -p "  请输入数据库密码：" dbpasswd
  mysql -u$dbuser -p$dbpasswd -e "drop database $dbname;"
  [[ $? -eq 0 ]] && echo -e "\n${info}项目删除成功！\n" || echo -e "${error}项目删除失败，请进入/data手动删除！\n"
}

show_ip_list() {
  project_name=$(ls /data)
  [[ -z $project_name ]] && echo -e "${error}你还没有安装项目！"
  echo -e "--以下为 ${Green_font_prefix}$project_name${Font_color_suffix} 的当前IP白名单--"
  showip=$(python /data/$project_name/$project_name/showiplist.py)
  for ip in $showip; do
    echo -e "--${Green_font_prefix}$ip${Font_color_suffix}"
  done
  echo -e "----------------------\n"
}

add_ip() {
  while true; do
    clear
    show_ip_list
    echo -e "${tip}如果想开放整个网段，在IP后加上掩码，如10.10.10.0/32\n"
    read -e -p "请输入你要添加的IP： " addip
    [[ -z $addip ]] && echo -e "${error}输入为空，脚本退出。\n" && exit 1
    echo -e "添加的IP为：${Green_font_prefix}$addip${Font_color_suffix}"
    sed -i "/WHITE_CLIENT_LIST/a \ \t'$addip'," /data/$project_name/$project_name/settings.py
    echo -e "${info}  IP已添加。\n"
    read -e -p "是否继续添加？[Y/N]:" ynn
    case $ynn in
    Y | y)
      continue
      ;;
    N | n)
      echo -e "${info}脚本退出。\n" && exit 0
      ;;
    *)
      echo -e "${error}输入错误，脚本退出。\n" && exit 1
      ;;
    esac
  done
}

del_ip() {
  while true; do
    clear
    show_ip_list
    read -e -p "请输入你要删除的IP： " delip
    [[ -z $delip ]] && echo -e "${error}输入为空，脚本退出。\n" && exit 1
    for i in $showip; do
      if [[ $delip == $i ]]; then
        echo -e "删除的IP为：${Red_font_prefix}$delip${Font_color_suffix}\n"
        read -e -p "确定删除？[Y/N]:" nyn
        case $nyn in
        Y | y)
          sed -i "/'$delip',/d" /data/$project_name/$project_name/settings.py && echo -e "${info}IP已删除。\n"
          ;;
        N | n)
          echo -e "${info}已取消。\n" && exit 0
          ;;
        *)
          echo -e "${error}输入错误，脚本退出。\n" && exit 1
          ;;
        esac

        read -e -p "是否继续删除？[Y/N]:" nny
        case $nny in
        Y | y)
          del_ip
          ;;
        N | n)
          echo -e "${info}脚本退出。\n" && exit 0
          ;;
        *)
          echo -e "${error}输入错误，脚本退出。\n" && exit 1
          ;;
        esac
      fi
    done
    echo -e "${error}${Red_font_prefix}$delip${Font_color_suffix}不在白名单内，无法删除，请重新输入！"
    echo -e "请等待5秒后重试，或按Ctrl+C退出脚本！"
    for num in $(seq -w 5 -1 0); do
      echo -en "---${Green_font_prefix}$num${Font_color_suffix}---\r"
      sleep 1
    done
  done
}

show_dns_list() {
  project_name=$(ls /data)
  [[ -z $project_name ]] && echo -e "${error}你还没有安装项目！"
  echo -e "--以下为 ${Green_font_prefix}$project_name${Font_color_suffix} 的当前监控DNS--"
  showdns=$(python /data/$project_name/python_script/showdnslist.py)
  for dnsip in $showdns; do
    echo -e "--${Green_font_prefix}$dnsip${Font_color_suffix}"
  done
  echo -e "----------------------\n"
}

add_dns() {
  while true; do
    clear
    show_dns_list
    read -e -p "输入要添加的DNS ip：" dns_add_ip
    [[ -z $dns_add_ip ]] && echo -e "${error}输入为空，脚本退出。\n" && exit 1
    echo -e "\n添加的DNS为：${Green_font_prefix}$dns_add_ip${Font_color_suffix}"
    read -e -p "请输入数据库名： " dbname
    read -e -p "请输入数据库用户名： " dbuser
    read -e -p "请输入数据库密码： " dbpasswd
    echo "$dns_add_ip" >>/data/$project_name/python_script/dnslist.txt
    mysql -u$dbuser -p$dbpasswd $dbname -e"INSERT INTO web_dns_monitor(dns_ip) SELECT '$dns_add_ip' FROM DUAL WHERE NOT EXISTS (select * from web_dns_monitor where dns_ip = '$dns_add_ip')"
    [[ $? -eq 0 ]] && echo -e "${info}  DNS已添加。\n" || echo -e "${error}  添加失败，请检查数据库信息是否正确。\n" && exit 1
    read -e -p "是否继续添加？[Y/N]:" ynn
    case $ynn in
    Y | y)
      continue
      ;;
    N | n)
      python /data/$project_name/python_script/get_dns_status.py #刷新状态
      echo -e "${info}脚本退出。\n" && exit 0
      ;;
    *)
      echo -e "${error}输入错误，脚本退出。\n" && exit 1
      ;;
    esac
  done
}

del_dns() {
  while true; do
    clear
    show_dns_list
    read -e -p "请输入要删除的IP：" dns_del_ip
    [[ -z $dns_del_ip ]] && echo -e "${error}输入为空，脚本退出。\n" && exit 1
    echo -e "\n删除的DNS为：${Red_font_prefix}$dns_del_ip${Font_color_suffix}"
    read -e -p "请输入数据库名： " dbname
    read -e -p "请输入数据库用户名： " dbuser
    read -e -p "请输入数据库密码： " dbpasswd
    sed -i "/^$dns_del_ip.*/d" /data/project_name/python_script/dnslist.txt
    mysql -u$dbuser -p$dbpasswd $dbname -e"TRUNCATE TABLE web_dns_monitor"
    [[ $? -eq 0 ]] && echo -e "${error}  删除失败，请检查数据库信息是否正确。\n" && exit 1
    python /data/$project_name/python_script/init_sql.py dns
    [[ $? -eq 0 ]] && echo -e "${info}  DNS已删除。\n" || echo -e "${error}  删除失败，数据库初始化失败。\n" && exit 1
    read -e -p "是否继续删除？[Y/N]:" ynn
    case $ynn in
    Y | y)
      continue
      ;;
    N | n)
      python /data/$project_name/python_script/get_dns_status.py #刷新状态
      echo -e "${info}脚本退出。\n" && exit 0
      ;;
    *)
      echo -e "${error}输入错误，脚本退出。\n" && exit 1
      ;;
    esac
  done
}

show_zhuanxian_list() {
  project_name=$(ls /data)
  [[ -z $project_name ]] && echo -e "${error}你还没有安装项目！"
  echo -e "--以下为 ${Green_font_prefix}$project_name${Font_color_suffix} 的当前监控专线列表--"
  showzx=$(python /data/$project_name/python_script/showzx.py)
  for zx in $showzx; do
    echo -e "--${Green_font_prefix}$zx${Font_color_suffix}"
  done
  echo -e "----------------------\n"
}

add_zhuanxian() {
  while true; do
    clear
    show_zhuanxian_list
    read -e -p "输入要添加的专线ID：" zxid
    read -e -p "输入要添加的专线名称：" zxname
    [[ -z $zxid ]] && [[ -z $zxname ]] && echo -e "${error}输入为空，脚本退出。\n" && exit 1
    echo -e "\n添加的专线信息为：ID：${Green_font_prefix}$zxid${Font_color_suffix}；专线名称为：${Green_font_prefix}$zxname${Font_color_suffix}"
    sed -i "/zhuanxianlist = {/ a\ \t'$zxid': '$zxname'," /data/$project_name/python_script/zhuanxianlist.py
    [[ $? -eq 0 ]] && echo -e "${info}添加成功！\n" || echo -e "${error}  添加失败，请检查所填信息是否正确。\n" && exit 1
    read -e -p "是否继续添加？[Y/N]:" ynn
    case $ynn in
    Y | y)
      continue
      ;;
    N | n)
      python /data/$project_name/python_script/get_mstp_bandwidth.py #刷新状态
      echo -e "${info}脚本退出。\n" && exit 0
      ;;
    *)
      echo -e "${error}输入错误，脚本退出。\n" && exit 1
      ;;
    esac
  done
}

del_zhuanxian() {
  while true; do
    clear
    show_zhuanxian_list
    read -e -p "输入要删除的专线ID：" zxdelid
    [[ -z $zxdelid ]] && echo -e "${error}输入为空，脚本退出。\n" && exit 1
    echo -e "\n删除的专线ID为：${Red_font_prefix}$zxdelid${Font_color_suffix}"
    sed -i "/'$zxdelid'/d" /data/$project_name/python_script/zhuanxianlist.py
    [[ $? -eq 0 ]] && echo -e "${info}  专线信息已删除。\n" || echo -e "${error}  删除失败，检查输入是否有误。\n" && exit 1
    #python /data/$project_name/python_script/get_mstp_bandwidth.py #刷新状态
    read -e -p "是否继续删除？[Y/N]:" ynn
    case $ynn in
    Y | y)
      continue
      ;;
    N | n)
      python /data/$project_name/python_script/get_mstp_bandwidth.py #刷新状态
      echo -e "${info}脚本退出。\n" && exit 0
      ;;
    *)
      echo -e "${error}输入错误，脚本退出。\n" && exit 1
      ;;
    esac
  done
}

show_cpu_list() {
  project_name=$(ls /data)
  [[ -z $project_name ]] && echo -e "${error}你还没有安装项目！"
  echo -e "--以下为 ${Green_font_prefix}$project_name${Font_color_suffix} 的当前监控IP--"
  showcpu=$(python /data/$project_name/python_script/showcpu.py)
  for cpuip in $showcpu; do
    echo -e "--${Green_font_prefix}$cpuip${Font_color_suffix}"
  done
  echo -e "----------------------\n"
}

add_cpu() {
  while true; do
    clear
    show_cpu_list
    read -e -p "请输入要添加的IP：" cpu_add_ip
    [[ -z $cpu_add_ip ]] && echo -e "${error}输入为空，脚本退出。\n" && exit 1
    echo -e "\n添加的设备IP为：${Green_font_prefix}$cpu_add_ip${Font_color_suffix}"
    read -e -p "请输入数据库名： " dbname
    read -e -p "请输入数据库用户名： " dbuser
    read -e -p "请输入数据库密码： " dbpasswd
    echo "$cpu_add_ip" >>/data/$project_name/python_script/cpu.txt
    mysql -u$dbuser -p$dbpasswd $dbname -e"INSERT INTO web_l3_cpu(ip) SELECT '$cpu_add_ip' FROM DUAL WHERE NOT EXISTS (select * from web_l3_cpu where ip = '$cpu_add_ip')"
    [[ $? -eq 0 ]] && echo -e "${info}  设备已添加。\n" || echo -e "${error}  添加失败，请检查数据库信息是否正确。\n" && exit 1
    read -e -p "是否继续添加？[Y/N]:" ynn
    case $ynn in
    Y | y)
      continue
      ;;
    N | n)
      python /data/$project_name/python_script/get_cpu_1min.py #刷新状态
      echo -e "${info}脚本退出。\n" && exit 0
      ;;
    *)
      echo -e "${error}输入错误，脚本退出。\n" && exit 1
      ;;
    esac
  done
}

del_cpu() {
  while true; do
    clear
    show_cpu_list
    read -e -p "请输入要删除的主干设备：" cpu_del_ip
    [[ -z $cpu_del_ip ]] && echo -e "${error}输入为空，脚本退出。\n" && exit 1
    echo -e "\n删除的DNS为：${Red_font_prefix}$cpu_del_ip${Font_color_suffix}"
    read -e -p "请输入数据库名： " dbname
    read -e -p "请输入数据库用户名： " dbuser
    read -e -p "请输入数据库密码： " dbpasswd
    sed -i "/^$cpu_del_ip.*/d" /data/project_name/python_script/cpu.txt
    mysql -u$dbuser -p$dbpasswd $dbname -e"TRUNCATE TABLE web_l3_cpu"
    [[ $? -eq 0 ]] && echo -e "${error}  删除失败，请检查数据库信息是否正确。\n" && exit 1
    python /data/$project_name/python_script/init_sql.py cpu
    [[ $? -eq 0 ]] && echo -e "${info}  设备已删除。\n" || echo -e "${error}  删除失败，数据库初始化失败。\n" && exit 1
    read -e -p "是否继续删除？[Y/N]:" ynn
    case $ynn in
    Y | y)
      continue
      ;;
    N | n)
      python /data/$project_name/python_script/get_cpu_1min.py #刷新状态
      echo -e "${info}脚本退出。\n" && exit 0
      ;;
    *)
      echo -e "${error}输入错误，脚本退出。\n" && exit 1
      ;;
    esac
  done
}

main() {
  #-----MAIN----------------------------------------------------------------------------------
  clear
  check_root
  echo -e "${info}${Yellow_font_prefix}}此脚本支持系统版本：CentOS 7/8 Debian 9/10 Ubuntu 16.04/18.04 with 64bit.\n开始使用前，请打开部署文档仔细阅读。${Font_color_suffix}\n"
  check_os
  #install_figlet
  #figlet FII-GNCS
  echo -e "
=============================================
最后更新日期: Dec 25, 2019
作者: 郑长昀
分机: 560-19959
工号: F1336346
=============================================

+-----------Django 环境安装和管理脚本-----------
+-----安装-----
|  ${Green_font_prefix}1.${Font_color_suffix}  安装Django项目及网站源码
|  ${Green_font_prefix}2.${Font_color_suffix}  删除Django项目
|  ${Green_font_prefix}3.${Font_color_suffix}  启动
|  ${Green_font_prefix}4.${Font_color_suffix}  停止
|  ${Green_font_prefix}5.${Font_color_suffix}  重启
+-----管理-----
|  ${Green_font_prefix}6.${Font_color_suffix}  添加访问IP白名单
|  ${Green_font_prefix}7.${Font_color_suffix}  删除访问IP白名单
|  ${Green_font_prefix}8.${Font_color_suffix}  添加DNS
|  ${Green_font_prefix}9.${Font_color_suffix}  删除DNS
|  ${Green_font_prefix}10.${Font_color_suffix}  添加监控专线信息
|  ${Green_font_prefix}11.${Font_color_suffix}  删除监控专线信息
|  ${Green_font_prefix}12.${Font_color_suffix}  添加主干设备
|  ${Green_font_prefix}13.${Font_color_suffix}  删除主干设备
---------------------------------------------
    "

  read -e -p "--请输入数字[1-13]:" num
  case $num in
  1)
    check_python_status
    ;;
  2)
    remove_project
    ;;
  3)
    ;;
  4)
    ;;
  5)
    ;;
  6)
    add_ip
    ;;
  7)
    del_ip
    ;;
  8)
    add_dns
    ;;
  9)
    del_dns
    ;;
  10)
    add_zhuanxian
    ;;
  11)
    del_zhuanxian
    ;;
  12)
    add_cpu
    ;;
  13)
    del_cpu
    ;;
  *)
    echo -e "${error}输入错误，脚本退出。\n" && exit 1
    ;;
  esac
}

main
