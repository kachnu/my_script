#!/bin/bash
#Скрипт позволяет ввести ПК в домен
#author: kachnu
#email:  ya.kachnu@yandex.ua
#Основой для скрипта послужил ресурс http://zubarev.me/domainjoin

DIALOG=whiptail
if [ ! -x "`which "$DIALOG"`" ]
 then
  DIALOG=whiptail
  if [ ! -x "`which "$DIALOG"`" ]
  then DIALOG=dialog
  fi
fi

case $LANG in
  uk*|ru*|be*) #UA RU BE locales
               MAIN_LABEL="Ввод ПК в домен"
               MAIN_TEXT="Выберите действие:"
               RUN_ROOT_TEXT="Запуск скрипта $0 с правами администратора"
               MENU1="Установка пакетов для домена"
               MENU2="Настройка и ввод в домен"
               MENU3="Проверка входа в домен"
               MENU4="Бекап настроек"
               MENU5="Настройка аутентификации PAM"
               MENU6="Справка"
               MENU2_1="Имя ПК (mycorp-pc)"
               MENU2_2="Рабочая группа (MYGROUP)"
               MENU2_3="Имя домена (domain.com.ua)"
               MENU2_4="IP контроллера домена (192.168.205.1)"
               MENU2_5="Имя контроллера домена (main-dc1)"
               MENU2_6="Имя сервера точного времени NTP"
               MENU2_7="IP контроллера домена №2 (192.168.205.2)"
               MENU2_8="Имя контроллера домена №2 (main-dc2)"
               MENU2_9="ПРИМЕНИТЬ НАСТРОЙКИ И ЗАРЕГИСТРИРОВАТЬСЯ В ДОМЕНЕ"
               MENU3_1="Восстановить настройки из *.bak"
               MENU3_2="Сохранить текущие настройки *.bak"
               INFO_START_ADD="
**********
Сейчас будет произведена проверка, не втянут ли уже компьютер в какой-нибудь домен.
Внимание! Если вылезет страшная ошибка, не пугайтесь. Все так, как должно быть.
Просто продолжайте процедуру введения в домен.
**********
Если на этом этапе процесс завис и нет никакой реакции, просто нажмите Enter
"
               TEXT_ADD="
**********
Сейчас будет предложено авторизовать данный компьютер в домене. Пожалуйста, введите полное имя домена в верхнем регистре (DOMAIN.COM.UA), затем доменного пользователя с правами администратора, а затем его пароль.
**********
"
               TEXT_NAME_DOMAIN="Имя домена в верхнем регистре (DOMAIN.COM.UA): "
               TEXT_NAME_USER="Имя доменного пользователя (администратора): "
               TEXT_OK_ADD="Компьютер успешно введен в домен!
               
Резервные копии ваших оригинальных файлов имеют расширение *.bak и находятся в соответствующих папках.
Осталось только перезагрузить компьютер.
"
               TEXT_ERROR_ADD="В процессе присоединения к домену возникли ошибки.
Смотрите подробнее листинг консоли."
               EXIT_TEXT="
Нажмите Enter для перехода в главное меню"
               ATTENTION="ВНИМАНИЕ!"
               ERROR_VARIABLE1="Не указано значение -"
               ERROR_VARIABLE2="Повторить ввод данных?"
               TEXT_LDM_UBUNTU="
**********
Обнаружена система Ubuntu.

Отключен гостевой вход и активирована форма ручного ввода логина на экране приветствия.
Смотреть файл /usr/share/lightdm/lightdm.conf.d/59-ubuntu.conf
**********
"
               TEXT_LDM_DEBIAN="
**********
Обнаружена система Debian.

Отключен говстевой вход и активирована форма ручного ввода логина на экране приветствия.
Смотреть файл /usr/share/lightdm/lightdm.conf.d/09_debian.conf
**********
"
               HELP="Справка
____________________________

Скрипт $0 предназначен для ввода компьютера в домен.

1. $MENU1 - выполняется установка пакетов, в сборке эти пакеты будут находиться в /var/cache/apt/domain_packages , если данной папки нет, будет выполнена установка из интернета. 
Для работы скрипта требуются следующие пакеты: krb5-user samba winbind ntp libpam-krb5 libpam-winbind libnss-winbind libpam-ccreds nscd nss-updatedb libnss-db

2. $MENU2 - выполняется резервное копирование файлов настроек, настройка и сохранение в файлах параметров входа в домен, а также выполнение фдола в домен. 
Пункты настройки входа в домен отмеченные * обязательны для заполнения.

3. $MENU3 - проводится проверка соединения с доменом, при удачном подключении выводится сообщение - \"Join is OK.\"

4. $MENU4 - возможность восстановить файлы в исходное состояние или сделать бекам уже настроенной конфигурации

5. $MENU5 - настройка способов аутентификации. 
Поумолчанию (до установки пакетов для домена) активированы пункты:
 [*] Unix authentication   
 [*] Register user sessions in the systemd control group hierarchy 
 [*] GNOME Keyring Daemon - Login keyring management
Поэтому чтобы вернуться к \"стандартной\" аутентификации необходимо отключать лишние пункты.
____________________________"
             
               ;;
            *) #All locales
               MAIN_LABEL="Enter the PC domain"
               MAIN_TEXT="Select an action:"
               RUN_ROOT_TEXT="Run the script $0 administrator"
               MENU1="Installation packages for domain"
               MENU2="Setup and enter the domain"
               MENU3="Check domain logon"
               MENU4="Backup settings"
               MENU5="Authentication configuration"
               MENU6="Help"
               MENU2_1="PC name(mycorp-pc)"
               MENU2_2="Working group (MYGROUP)"
               MENU2_3="Domain Name (domain.com.ua)"
               MENU2_4="IP domain controller (192.168.205.1)"
               MENU2_5="Name domain controller (main-dc1)"
               MENU2_6="Name the time server NTP"
               MENU2_7="IP domain controller 2 (192.168.205.2)"
               MENU2_8="Name domain controller 2 (main-dc2)"
               MENU2_9="Apply settings and registered in the domain"
               MENU3_1="Restore from *.bak"
               MENU3_2="Save the current settings *.bak"
               INFO_START_ADD="
**********
Who will check not drawn if the computer is already in some domain.
Attention! If you come out a terrible mistake, do not panic. All is as it should be .
Just continue with the introduction of the domain.
**********
If at this stage of the process depends, and there is no reaction, just click Enter
"
               TEXT_ADD="
**********
СWho will be asked to authorize this computer to the domain. Please enter the full domain name in uppercase (DOMAIN.COM.UA), then the domain admin user and then the password.
**********
"
               TEXT_NAME_DOMAIN="The domain name in uppercase (DOMAIN.COM.UA): "
               TEXT_NAME_USER="The name of the domain user: "
               TEXT_OK_ADD="The computer was successfully introduced in the domain!
               
Backup copies of your original files have the extension * .bak and contained in appropriate folders.
It remains only to restart the computer.
"
               TEXT_ERROR_ADD="In the process of joining a domain errors occur .
See more listing the console."
               EXIT_TEXT="
Press Enter to go to the main menu"
               ATTENTION="ATTENTION!"
               ERROR_VARIABLE1="Not Specified value -"
               ERROR_VARIABLE2="Repeat data entry?"
               TEXT_LDM_UBUNTU="
**********
Detected system Ubuntu.

Disabled govstevoy input and activated manually entering the login form on the welcome screen.
See file /usr/share/lightdm/lightdm.conf.d/59-ubuntu.conf
**********
"
               TEXT_LDM_DEBIAN="
**********
Detected system Debian.

Disabled govstevoy input and activated manually entering the login form on the welcome screen.
See file /usr/share/lightdm/lightdm.conf.d/09_debian.conf
**********
"
               HELP="Help
____________________________

Script $0 for input into the computer domain.

1. $MENU1 - installs a package to assemble these packages will be in /var/cache/apt/domain_packages , if this folder does not exist , the installation will be carried out from the Internet  
For the script requires the following packages: krb5-user samba winbind ntp libpam-krb5 libpam-winbind libnss-winbind libpam-ccreds nscd nss-updatedb libnss-db

2. $MENU2 - backed up configuration files , configuration files and save the login domain , and performing fdola domain .
Setting Items domain logon marked * are required.

3. $MENU3 - the connection is checked with a domain with a successful connection message is displayed - \"Join is OK.\"

4. $MENU4 - configuration files to restore to its original state or make beks already customized configuration

5. $MENU5 - configure authentication methods .
Defaul ( to install packages for the domain ) activated items:
 [*] Unix authentication   
 [*] Register user sessions in the systemd control group hierarchy 
 [*] GNOME Keyring Daemon - Login keyring management
So to return to the \"default\" authentication, you must disable the extra items .
____________________________" ;;

esac    

if [ "$(whoami)" != 'root' ]; then
        echo $RUN_ROOT_TEXT;
        sudo $0
        exit 0
fi

#############################
GetVariables () #Получение переменных из файлов настроек
{
NAME_PC=$(cat /etc/hostname)	
NAME_WGROUP=$(cat /etc/samba/smb.conf | grep ^workgroup |awk '{print $3}')
name_group=$(cat /etc/resolvconf/resolv.conf.d/head | grep ^domain | awk '{print $2}')
IP_C1_DOMEN=$(cat /etc/resolvconf/resolv.conf.d/head | grep -m1 ^nameserver | awk '{print $2}')
NAME_C1_DOMEN=$(cat /etc/hosts | grep -m1 ^$IP_C1_DOMEN | awk '{print $3}')
NAME_NTP=$(cat /etc/ntp.conf | grep -m1 ^server | awk '{print $2}' | sed "s/.${name_group}//g" | sed "s/0.debian.pool.ntp.org//g")
IP_C2_DOMEN=$(cat /etc/resolvconf/resolv.conf.d/head | grep -m2 ^nameserver | awk 'FNR==2 {print $2}')
NAME_C2_DOMEN=$(cat /etc/hosts | grep -m1 ^$IP_C2_DOMEN | awk '{print $3}')
}
#############################
InstallPackages () #Установка пакетов для входа в Домен
{
DOMAIN_PACKAGES="/var/cache/apt/domain_packages"	
cd /etc/ && tar czpf pam.d.tar.gz pam.d
if [ -d "$DOMAIN_PACKAGES" ]
 then dpkg -i $DOMAIN_PACKAGES/*.deb || apt-get update && apt-get install -f 
 else
      apt-get update
      apt-get install -y krb5-user samba winbind ntp libpam-krb5 libpam-winbind libnss-winbind libpam-ccreds nscd nss-updatedb libnss-db
fi
}
#############################
BackupSettings () #Резервирование настроек
{
if ! [ -f /etc/resolvconf/resolv.conf.d/head.bak ] ; then
	cp /etc/resolvconf/resolv.conf.d/head /etc/resolvconf/resolv.conf.d/head.bak
fi

if ! [ -f /etc/hostname.bak ] ; then
	cp /etc/hostname /etc/hostname.bak
fi

if ! [ -f /etc/hosts.bak ] ; then
	cp /etc/hosts /etc/hosts.bak
fi

if ! [ -f /etc/ntp.conf.bak ] ; then
	cp /etc/ntp.conf /etc/ntp.conf.bak
fi

if ! [ -f /etc/krb5.conf.bak ] ; then
	cp /etc/krb5.conf /etc/krb5.conf.bak
fi

if ! [ -f /etc/samba/smb.conf.bak ] ; then
	cp /etc/samba/smb.conf /etc/samba/smb.conf.bak
fi

if ! [ -f /etc/security/limits.conf.bak ] ; then
	cp /etc/security/limits.conf /etc/security/limits.conf.bak
fi

if ! [ -f /etc/nsswitch.conf.bak ] ; then
	cp /etc/nsswitch.conf /etc/nsswitch.conf.bak
fi

if ! [ -f /etc/pam.d/common-session.bak ] ; then
	cp /etc/pam.d/common-session /etc/pam.d/common-session.bak
fi
}
#############################
ForseBackupSettings ()
{
if [ -f /etc/resolvconf/resolv.conf.d/head ] ; then
	cp /etc/resolvconf/resolv.conf.d/head /etc/resolvconf/resolv.conf.d/head.bak
fi

if [ -f /etc/hostname ] ; then
	cp /etc/hostname /etc/hostname.bak
fi

if [ -f /etc/hosts ] ; then
	cp /etc/hosts /etc/hosts.bak
fi

if [ -f /etc/ntp.conf ] ; then
	cp /etc/ntp.conf /etc/ntp.conf.bak
fi

if [ -f /etc/krb5.conf ] ; then
	cp /etc/krb5.conf /etc/krb5.conf.bak
fi

if [ -f /etc/samba/smb.conf ] ; then
	cp /etc/samba/smb.conf /etc/samba/smb.conf.bak
fi

if [ -f /etc/security/limits.conf ] ; then
	cp /etc/security/limits.conf /etc/security/limits.conf.bak
fi

if [ -f /etc/nsswitch.conf ] ; then
	cp /etc/nsswitch.conf /etc/nsswitch.conf.bak
fi

if [ -f /etc/pam.d/common-session ] ; then
	cp /etc/pam.d/common-session /etc/pam.d/common-session.bak
fi
}
#############################
UnBackupSettings () #Возвращение настроек из бекапа
{
if [ -f /etc/resolvconf/resolv.conf.d/head.bak ] ; then
	mv /etc/resolvconf/resolv.conf.d/head.bak /etc/resolvconf/resolv.conf.d/head
fi

if [ -f /etc/hostname.bak ] ; then
	mv /etc/hostname.bak /etc/hostname
fi

if [ -f /etc/hosts.bak ] ; then
	mv /etc/hosts.bak /etc/hosts
fi

if [ -f /etc/ntp.conf.bak ] ; then
	mv /etc/ntp.conf.bak /etc/ntp.conf
fi

if [ -f /etc/krb5.conf.bak ] ; then
	mv /etc/krb5.conf.bak /etc/krb5.conf
fi

if [ -f /etc/samba/smb.conf.bak ] ; then
	mv /etc/samba/smb.conf.bak /etc/samba/smb.conf
fi

if [ -f /etc/security/limits.conf.bak ] ; then
	mv /etc/security/limits.conf.bak /etc/security/limits.conf
fi

if [ -f /etc/nsswitch.conf.bak ] ; then
	mv /etc/nsswitch.conf.bak /etc/nsswitch.conf
fi

if [ -f /etc/pam.d/common-session.bak ] ; then
	mv /etc/pam.d/common-session.bak /etc/pam.d/common-session
fi

}
#############################
ChangeSettings () #Редактирование файлов настроек в зависимости от переменных
{
NAME_GROUP=$(echo $name_group | sed 's/[[:lower:]]/\u&/g')
if ! [ -d /etc/resolvconf/resolv.conf.d ]
 then mkdir /etc/resolvconf/resolv.conf.d
fi
echo "# Dynamic resolv.conf(5) file for glibc resolver(3) generated by resolvconf(8)
#     DO NOT EDIT THIS FILE BY HAND -- YOUR CHANGES WILL BE OVERWRITTEN
domain $name_group
search $name_group
nameserver $IP_C1_DOMEN
#nameserver $IP_C2_DOMEN" > /etc/resolvconf/resolv.conf.d/head
if [[ $IP_C2_DOMEN != '' ]] && [[ $NAME_C2_DOMEN != '' ]]
 then sed -i "s/#nameserver ${IP_C2_DOMEN}/nameserver ${IP_C2_DOMEN}/g" /etc/resolvconf/resolv.conf.d/head
fi
echo "$NAME_PC" > /etc/hostname
echo "127.0.0.1	localhost
127.0.1.1	$NAME_PC.$name_group $NAME_PC
$IP_C1_DOMEN	$NAME_C1_DOMEN.$name_group	$NAME_C1_DOMEN
#$IP_C2_DOMEN	$NAME_C2_DOMEN.$name_group	$NAME_C2_DOMEN

# The following lines are desirable for IPv6 capable hosts
::1     ip6-localhost ip6-loopback
fe00::0 ip6-localnet
ff00::0 ip6-mcastprefix
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters" > /etc/hosts
if [[ $IP_C2_DOMEN != '' ]] && [[ $NAME_C2_DOMEN != '' ]]
 then sed -i "s/#${IP_C2_DOMEN}/${IP_C2_DOMEN}/g" /etc/hosts
fi
echo "# /etc/ntp.conf, configuration for ntpd; see ntp.conf(5) for help

driftfile /var/lib/ntp/ntp.drift


# Enable this if you want statistics to be logged.
#statsdir /var/log/ntpstats/

statistics loopstats peerstats clockstats
filegen loopstats file loopstats type day enable
filegen peerstats file peerstats type day enable
filegen clockstats file clockstats type day enable

# Specify one or more NTP servers.

# Use servers from the NTP Pool Project. Approved by Ubuntu Technical Board
# on 2011-02-08 (LP: #104525). See http://www.pool.ntp.org/join.html for
# more information.
#server $NAME_NTP.$name_group
server 0.debian.pool.ntp.org iburst
server 1.debian.pool.ntp.org iburst
server 2.debian.pool.ntp.org iburst
server 3.debian.pool.ntp.org iburst

# Use Ubuntu's ntp server as a fallback.
server ntp.ubuntu.com

# Access control configuration; see /usr/share/doc/ntp-doc/html/accopt.html for
# details.  The web page <http://support.ntp.org/bin/view/Support/AccessRestrictions>
# might also be helpful.
#
# Note that \"restrict\" applies to both servers and clients, so a configuration
# that might be intended to block requests from certain clients could also end
# up blocking replies from your own upstream servers.

# By default, exchange time with everybody, but don't allow configuration.
restrict -4 default kod notrap nomodify nopeer noquery
restrict -6 default kod notrap nomodify nopeer noquery

# Local users may interrogate the ntp server more closely.
restrict 127.0.0.1
restrict ::1

# Clients from this (example!) subnet have unlimited access, but only if
# cryptographically authenticated.
#restrict 192.168.123.0 mask 255.255.255.0 notrust


# If you want to provide time to your local subnet, change the next line.
# (Again, the address is an example only.)
#broadcast 192.168.123.255

# If you want to listen to time broadcasts on your local subnet, de-comment the
# next lines.  Please do this only if you trust everybody on the network!
#disable auth
#broadcastclient
" > /etc/ntp.conf
if [[ $NAME_NTP != '' ]]
 then sed -i "s/#server ${NAME_NTP}/server ${NAME_NTP}/g" /etc/ntp.conf
fi
echo "[libdefaults]
    default_realm = $NAME_GROUP
    kdc_timesync = 1
    ccache_type = 4
    forwardable = true
    proxiable = true
    v4_instance_resolve = false
    v4_name_convert = {
	host = {
	    rcmd = host
	    ftp = ftp
	}
	plain = {
	    something = something-else
	}
    }
    fcc-mit-ticketflags = true

[realms]
    $NAME_GROUP = {
	kdc = $NAME_C1_DOMEN.$name_group
	#kdc = $NAME_C2_DOMEN.$name_group
	admin_server = $NAME_C1_DOMEN.$name_group
	default_domain = $NAME_GROUP
    }

[domain_realm]
    .$name_group = $NAME_GROUP
    $name_group = $NAME_GROUP
[login]
    krb4_convert = false
    krb4_get_tickets = false" > /etc/krb5.conf
if [[ $IP_C2_DOMEN != '' ]] && [[ $NAME_C2_DOMEN != '' ]]
 then sed -i "s/#kdc = ${NAME_C2_DOMEN}/kdc = ${NAME_C2_DOMEN}/g" /etc/krb5.conf
fi
echo "[global]
workgroup = $NAME_WGROUP
realm = $NAME_GROUP
security = ADS
encrypt passwords = true
dns proxy = no 
socket options = TCP_NODELAY
domain master = no
local master = no
preferred master = no
os level = 0
domain logons = no
idmap config * : range = 10000-20000
idmap config * : backend = tdb 
winbind enum groups = yes
winbind enum users = yes
winbind use default domain = yes
template shell = /bin/bash
winbind refresh tickets = yes
winbind offline logon = yes
winbind cache time = 3600
usershare allow guests = yes
usershare owner only = false

[printers]
comment = All Printers
browseable = no
path = /var/spool/samba
printable = yes
guest ok = no
read only = yes
create mask = 0700

# Windows clients look for this share name as a source of downloadable
# printer drivers
[print$]
comment = Printer Drivers
path = /var/lib/samba/printers
browseable = yes
read only = yes
guest ok = no" > /etc/samba/smb.conf
echo "# /etc/security/limits.conf
#
#Each line describes a limit for a user in the form:
#
#<domain>        <type>  <item>  <value>
#
#Where:
#<domain> can be:
#        - a user name
#        - a group name, with @group syntax
#        - the wildcard *, for default entry
#        - the wildcard %, can be also used with %group syntax,
#                 for maxlogin limit
#        - NOTE: group and wildcard limits are not applied to root.
#          To apply a limit to the root user, <domain> must be
#          the literal username root.
#
#<type> can have the two values:
#        - \"soft\" for enforcing the soft limits
#        - \"hard\" for enforcing hard limits
#
#<item> can be one of the following:
#        - core - limits the core file size (KB)
#        - data - max data size (KB)
#        - fsize - maximum filesize (KB)
#        - memlock - max locked-in-memory address space (KB)
#        - nofile - max number of open files
#        - rss - max resident set size (KB)
#        - stack - max stack size (KB)
#        - cpu - max CPU time (MIN)
#        - nproc - max number of processes
#        - as - address space limit (KB)
#        - maxlogins - max number of logins for this user
#        - maxsyslogins - max number of logins on the system
#        - priority - the priority to run user process with
#        - locks - max number of file locks the user can hold
#        - sigpending - max number of pending signals
#        - msgqueue - max memory used by POSIX message queues (bytes)
#        - nice - max nice priority allowed to raise to values: [-20, 19]
#        - rtprio - max realtime priority
#        - chroot - change root to directory (Debian-specific)
#
#<domain>      <type>  <item>         <value>
#

#*               soft    core            0
#root            hard    core            100000
#*               hard    rss             10000
#@student        hard    nproc           20
#@faculty        soft    nproc           20
#@faculty        hard    nproc           50
#ftp             hard    nproc           0
#ftp             -       chroot          /ftp
#@student        -       maxlogins       4

# End of file
*               -    nofile            16384
root            -    nofile            16384" > /etc/security/limits.conf
echo "# /etc/nsswitch.conf
#
# Example configuration of GNU Name Service Switch functionality.
# If you have the \`glibc-doc-reference' and \`info' packages installed, try:
# \`info libc \"Name Service Switch\"' for information about this file.

passwd:         compat winbind
group:          compat winbind
shadow:         compat

hosts:          dns mdns4_minimal [NOTFOUND=return] mdns4 files
networks:       files

protocols:      db files
services:       db files
ethers:         db files
rpc:            db files

netgroup:       nis
" > /etc/nsswitch.conf
echo "#
# /etc/pam.d/common-session - session-related modules common to all services
#
# This file is included from other service-specific PAM config files,
# and should contain a list of modules that define tasks to be performed
# at the start and end of sessions of *any* kind (both interactive and
# non-interactive).
#
# As of pam 1.0.1-6, this file is managed by pam-auth-update by default.
# To take advantage of this, it is recommended that you configure any
# local modules either before or after the default block, and use
# pam-auth-update to manage selection of other modules.  See
# pam-auth-update(8) for details.

# here are the per-package modules (the \"Primary\" block)
session	[default=1]			pam_permit.so
# here's the fallback if no module succeeds
session	requisite			pam_deny.so
# prime the stack with a positive return value if there isn't one already;
# this avoids us returning an error just because nothing sets a success code
# since the modules above will each just jump around
session	required			pam_permit.so
# The pam_umask module will set the umask according to the system default in
# /etc/login.defs and user settings, solving the problem of different
# umask settings with different shells, display managers, remote sessions etc.
# See \"man pam_umask\".
session optional			pam_umask.so
# and here are more per-package modules (the \"Additional\" block)
session	optional			pam_krb5.so minimum_uid=1000
session	required	pam_unix.so 
session	optional			pam_winbind.so 
session	optional	pam_systemd.so 
session  optional  pam_mkhomedir.so skel=/etc/skel/ umask=0077 
# end of pam-auth-update config" > /etc/pam.d/common-session
}
#############################
RestartNetDemon () #Перезапуск сетевых служб
{
/etc/init.d/networking restart
/etc/init.d/ntp restart
/etc/init.d/winbind stop
smbd restart
/etc/init.d/winbind start
}
#############################
AddToDomain () #Вход в домен
{
echo "$INFO_START_ADD"

if [ "$(net ads testjoin)" != "Join is OK" ]; then
	echo "$TEXT_ADD"
	
	echo -n "$TEXT_NAME_DOMAIN"
	read DOMAINNAME
	
	echo -n "$TEXT_NAME_USER"
	read DOMAINUSER
	
	net ads join -U $DOMAINUSER -D $DOMAINNAME
fi


if [ "$(lsb_release -si)" = "Ubuntu" ]; then
	if [ -f /usr/share/lightdm/lightdm.conf.d/50-ubuntu.conf ]; then
	    if ! [ -f /usr/share/lightdm/lightdm.conf.d/59-ubuntu.conf ]; then
			cp /usr/share/lightdm/lightdm.conf.d/50-ubuntu.conf /usr/share/lightdm/lightdm.conf.d/59-ubuntu.conf
			echo "greeter-show-manual-login=true" >> /usr/share/lightdm/lightdm.conf.d/59-ubuntu.conf
			echo "allow-guest=false" >> /usr/share/lightdm/lightdm.conf.d/59-ubuntu.conf
			echo "" >> /usr/share/lightdm/lightdm.conf.d/59-ubuntu.conf
			echo "$TEXT_LDM_UBUNTU"
	    fi
	fi
fi

if [ "$(lsb_release -si)" = "Debian" ]; then
	if [ -f /usr/share/lightdm/lightdm.conf.d/01_debian.conf ]; then
	    if ! [ -f /usr/share/lightdm/lightdm.conf.d/09_debian.conf ]; then
			cp /usr/share/lightdm/lightdm.conf.d/01_debian.conf /usr/share/lightdm/lightdm.conf.d/09_debian.conf
			echo "greeter-show-manual-login=true" >> /usr/share/lightdm/lightdm.conf.d/09_debian.conf
			echo "allow-guest=false" >> /usr/share/lightdm/lightdm.conf.d/09_debian.conf
			echo "" >> /usr/share/lightdm/lightdm.conf.d/09_debian.conf
			echo "$TEXT_LDM_DEBIAN"
	    fi
	fi
fi

echo ""

if [ "$(net ads testjoin)" = "Join is OK" ]; then
	echo "$TEXT_OK_ADD"
else
	echo "$TEXT_ERROR_ADD"
fi
}
#############################
Help () #Справка
{
clear
echo "$HELP"
}
#############################
CheckVariables () #Функция проверки данных
{
if [[ $(echo $1) == '' ]] 
 then $DIALOG --title "$ATTENTION" --yesno "$ERROR_VARIABLE1 \"$2\"\\n\\n$ERROR_VARIABLE2" 10 60
   if [ $? == 0 ]
     then SettingForm
     else MainForm
   fi
fi
}
#############################
SettingForm () #Форма настроек
{
ANSWER=$($DIALOG  --cancel-button "Exit" --title "$MAIN_LABEL" --menu \
    "$MAIN_TEXT" 16 62\
    9\
        1 "* $MENU2_1: $NAME_PC"\
        2 "* $MENU2_2: $NAME_WGROUP"\
        3 "* $MENU2_3: $name_group"\
        4 "* $MENU2_4: $IP_C1_DOMEN"\
        5 "* $MENU2_5: $NAME_C1_DOMEN"\
        6 "$MENU2_6: $NAME_NTP"\
        7 "$MENU2_7: $IP_C2_DOMEN"\
        8 "$MENU2_8: $NAME_C2_DOMEN"\
        9 "$MENU2_9" 3>&1 1>&2 2>&3)
if [ $? != 0 ]
 then echo Exit ; MainForm
fi
case $ANSWER in
  1 ) NAME_PC=$($DIALOG --title "$MENU2_1" --inputbox "" 10 60 $NAME_PC 3>&1 1>&2 2>&3 | sed "s/[^a-zA-Z0-9.-]//g")
      if [ $? != 0 ]
        then NAME_PC=$(cat /etc/hostname);
      fi 
      SettingForm;; 
  2 ) NAME_WGROUP=$($DIALOG --title "$MENU2_2" --inputbox "" 10 60 $NAME_WGROUP 3>&1 1>&2 2>&3 | sed "s/[^a-zA-Z0-9.-]//g")
      if [ $? != 0 ]
        then NAME_WGROUP=$(cat /etc/samba/smb.conf | grep ^workgroup |awk '{print $3}');
      fi 
      SettingForm;;
  3 ) name_group=$($DIALOG --title "$MENU2_3" --inputbox "" 10 60 $name_group 3>&1 1>&2 2>&3 | sed "s/[^a-zA-Z0-9.-]//g")
      if [ $? != 0 ]
        then name_group=$(cat /etc/resolvconf/resolv.conf.d/head | grep ^domain | awk '{print $2}');
      fi 
      SettingForm;;
  4 ) IP_C1_DOMEN=$($DIALOG --title "$MENU2_4" --inputbox "" 10 60 $IP_C1_DOMEN 3>&1 1>&2 2>&3 | sed "s/[^0-9.]//g")
      if [ $? != 0 ]
        then IP_C1_DOMEN=$(cat /etc/resolvconf/resolv.conf.d/head | grep -m1 ^nameserver | awk '{print $2}');
      fi 
      SettingForm;;
  5 ) NAME_C1_DOMEN=$($DIALOG --title "$MENU2_5" --inputbox "" 10 60 $NAME_C1_DOMEN 3>&1 1>&2 2>&3 | sed "s/[^a-zA-Z0-9.-]//g")
      if [ $? != 0 ]
        then IP_C1_DOMEN=$(cat /etc/resolvconf/resolv.conf.d/head | grep -m1 ^nameserver | awk '{print $2}');
        NAME_C1_DOMEN=$(cat /etc/hosts | grep -m1 ^$IP_C1_DOMEN | awk '{print $3}')
      fi 
      SettingForm;;
  6 ) NAME_NTP=$($DIALOG --title "$MENU2_6" --inputbox "" 10 60 $NAME_NTP 3>&1 1>&2 2>&3 | sed "s/[^a-zA-Z0-9.-]//g")
      if [ $? != 0 ]
        then NAME_NTP=$(cat /etc/ntp.conf | grep -m1 ^server | awk '{print $2}' | sed "s/.${name_group}//g" | sed "s/0.debian.pool.ntp.org//g")
      fi 
      SettingForm;;
  7 ) IP_C2_DOMEN=$($DIALOG --title "$MENU2_7" --inputbox "" 10 60 $IP_C2_DOMEN 3>&1 1>&2 2>&3 | sed "s/[^0-9.]//g")
      if [ $? != 0 ]
        then IP_C2_DOMEN=$(cat /etc/resolvconf/resolv.conf.d/head | grep -m2 ^nameserver | awk 'FNR==2 {print $2}');
      fi 
      SettingForm;;  
  8 ) NAME_C2_DOMEN=$($DIALOG --title "$MENU2_8" --inputbox "" 10 60 $NAME_C2_DOMEN 3>&1 1>&2 2>&3 | sed "s/[^a-zA-Z0-9.-]//g")
      if [ $? != 0 ]
        then IP_C2_DOMEN=$(cat /etc/resolvconf/resolv.conf.d/head | grep -m2 ^nameserver | awk 'FNR==2 {print $2}');
        NAME_C2_DOMEN=$(cat /etc/hosts | grep -m2 ^$IP_C2_DOMEN | awk 'FNR==2 {print $3}')
      fi 
      SettingForm;;   
  9 ) #Проверка введеных значений
      CheckVariables "$NAME_PC" "$MENU2_1"
      CheckVariables "$NAME_WGROUP" "$MENU2_2"
      CheckVariables "$name_group" "$MENU2_3"
      CheckVariables "$IP_C1_DOMEN" "$MENU2_4"
      CheckVariables "$NAME_C1_DOMEN" "$MENU2_5"
      #Применение настроек и ввод ПК в домен
      BackupSettings
      ChangeSettings
      RestartNetDemon
      AddToDomain;;
  * ) echo oops! - $ANSWER ;;
esac
echo "$EXIT_TEXT"
read input
MainForm
}
#############################
BackupForm () #Форма бекапа настроек
{
ANSWER=$($DIALOG  --cancel-button "Exit" --title "$MAIN_LABEL" --menu \
    "$MAIN_TEXT" 13 50\
    3\
        1 "$MENU3_1"\
        2 "$MENU3_2" 3>&1 1>&2 2>&3)
if [ $? != 0 ]
 then echo Exit ; MainForm
fi
case $ANSWER in
  1 ) UnBackupSettings;;  
  2 ) ForseBackupSettings;; 
  * ) echo oops! - $ANSWER ;;
esac
echo "$EXIT_TEXT"
read input
MainForm
}
#############################
CheckState ()
{
if [ "$(net ads testjoin)" = "Join is OK" ]; then
	STATE_DOMAIN="- Domain ON"
else
	STATE_DOMAIN="- Domain OFF"
fi
}
#############################
MainForm () #Главная форма
{
#CheckState
ANSWER=$($DIALOG  --cancel-button "Exit" --title "$MAIN_LABEL $STATE_DOMAIN" --menu \
    "$MAIN_TEXT" 13 50\
    6\
        1 "$MENU1"\
        2 "$MENU2"\
        3 "$MENU3"\
        4 "$MENU4"\
        5 "$MENU5"\
        6 "$MENU6" 3>&1 1>&2 2>&3)
if [ $? != 0 ]
 then echo Exit ; exit 0
fi
case $ANSWER in
  1 ) InstallPackages ;;
  2 ) GetVariables; 
      SettingForm ;; 
  3 ) echo "**********"
      net ads testjoin ;;   
  4 ) BackupForm ;;
  5 ) pam-auth-update --force;;
  6 ) Help;;
  * ) echo oops! - $ANSWER ;;
esac
echo "$EXIT_TEXT"
read input
MainForm
}

MainForm

exit 0
