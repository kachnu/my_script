#!/bin/bash
#Скрипт позволяет упростить пользование утилитой e4rat
#author: kachnu
# email: ya.kachnu@yandex.ua

DIALOG=whiptail
if [ ! -x "`which "$DIALOG"`" ]
 then
  DIALOG=whiptail
  if [ ! -x "`which "$DIALOG"`" ]
  then DIALOG=dialog
  fi
fi

if [ $(id -u) -ne 0 ] #Проверка на запуск с правами root
then
 echo "Start $0 with root"
 sudo $0 
 exit 0
fi

case $LANG in
  uk*|ru*|be*) #UA RU BE locales
               MAIN_LABEL="Cкрипт для e4rat"
               MAIN_TEXT="Выберите действие:"
               MENU1="Шаг 1 - Сбор информации для e4rat"
               MENU2="Шаг 2 - Преобразование файлов и включение e4rat"
               MENU3="Задать время сбора информации"
               MENU4="Убрать e4rat из параметров загрузки"
               MENU5="Добавить e4rat в параметры загрузки"
               MENU6="Редактировать файл настроек e4rat"
               MENU7="Справка"
               HELP_EXIT="Нажмите Enter для перехода в главное меню"
               ATTENTION="ВНИМАНИЕ!"
               CHECK_PO="- не найдено!"
               REBOOT_TEXT="Для продолжения необходимо перезагрузить систему!
               
Перезагрузить систему сейчас?"
               TIME_TEXT="Введите время (секунд) в течение, которого e4rat будет собирать информацию о запускаемых программах/процессах"
               ERROR_TIME="- не является числом. Повторите ввод!"
               DEL_LABEL="Исключение e4rat из параметров загрузки"
               DEL_TEXT="Grub будет приведен в вид по умолчанию:
GRUB_CMDLINE_LINUX_DEFAULT=\"quiet\"
Настройки Grub будут обновлены.

Выполнить действие?"
               ADD_LABEL="Добавление e4rat в параметры загрузки"
               ADD_TEXT="Параметры Grub будут изменены:
GRUB_CMDLINE_LINUX_DEFAULT=\"quiet init=/sbin/e4rat-preload\"
Настройки Grub будут обновлены.

Выполнить действие?"
               HELP="
____________________________________
   Справка

$0 - скрипт помогающий настроить e4rat.
E4rat может быть полезной в системах с одним пользователем, использующим автозапуск Х-в, при этом также можно ускорить запуск нужных программ. 
На серверах или при загрузке в CLI - время загрузки системы может снизиться не на много. 
Для SSD-дисков вообще нет смысла использовать, поскольку у них отсутствуют движущиеся части и, как следствие, отсутствуют (почти) задержки, однако, пользователям таких дисков, может быть полезно ознакомиться с Ureadahead.
E4rat - проект Andreas Rid и Gundolf Kiefer, расшифровывается как e4 'reduced access time' (сокращение времени доступа), применяется ТОЛЬКО в файловой системе  ext4. 
 
 В набор утилит e4rat входит: e4rat-collect, e4rat-realloc и e4rat-preload.
- e4rat-collect запускается во время обучающей загрузки ОС и составляет список нужных для инициализации ОС файлов.
- e4rat-realloc перераспределяет блоки файлов, попавших в список так, чтобы они располагались в одной области жесткого диска.
- e4rat-preload заранее помещает файлы в память для ускорения загрузки.

 В скрипте $0 :
Шаг1 - подготавливает систему для запуска e4rat-collect, после перезагрузки начинает действовать e4rat-collect, который собирает в течении заданного времени (по умолчанию 120 секунд) информацию о запущеных приложениях.
Только по истечение срока сбора данных можно приступать к Шагу 2.
Шаг2 - подготавливает систему для запуска e4rat-realloc, после перезагрузки выполняется e4rat-realloc и добавляется e4rat-preload в параметры запуска системы.
Также скрипт позволяет менять время сбора информации, редактировать файл настроек /etc/e4rat.conf, вручную добавлять/исключать e4rat-preload из параметров запуска системы.
___________________________________"
               STEP1_LABEL="Шаг 1"
               STEP1_TEXT1="В параметры загрузки системы будет добавлена утилита e4rat-collect.
После перезагрузки, данная утилита будет в течение -" 
               STEP1_TEXT2="секунд будет собирать информацию о запускаемых программах и процессах.
Только по истечению данного времени можно приступить к Шагу 2.

Настройки Grub будут обновлены.
Выполнить действие?"
               STEP2_LABEL="Шаг 2"
               STEP2_TEXT="Следующая загрузка системы произойдет с режиме - single.
После перезагрузки возникнет черный экран с буковками.
В это время будет выполняться утилита e4rat-realloc, которая будет производить дефрагментацию и расстановку приложений на основании ранее собранной информации.
Затем в параметры запуска системы будет добавлена утилита e4rat-preload.
После всех изменений система сама перегрузиться с задействованным e4rat.

Настройки Grub будут обновлены.
Выполнить действие?"
               ;;
            *) #All locales
               MAIN_LABEL="Scripts for e4rat"
               MAIN_TEXT="Select an action :"
               MENU1="Step 1 - Gathering information for e4rat"
               MENU2="Step 2 - File conversion and integration e4rat"
               MENU3="Set the time of collecting information"
               MENU4="Remove e4rat from boot options"
               MENU5="Add e4rat to boot options"
               MENU6="Edit the configuration file e4rat"
               MENU7="Help"
               HELP_EXIT="Press Enter to go to the main menu"
               ATTENTION="ATTENTION!"
               CHECK_PO="- Not found!"
               REBOOT_TEXT="To continue, you must reboot the system!
               
Reboot Sistem now?"
               TIME_TEXT="Enter the time (seconds) during which e4rat will collect information about running programs/processes"
               ERROR_TIME="- Not a number. Re-enter!"
               DEL_LABEL="E4rat exception of boot options"
               DEL_TEXT="Grub default:
GRUB_CMDLINE_LINUX_DEFAULT=\"quiet\"
Grub settings will be updated.

Perform an action?"
               ADD_LABEL="Adding e4rat boot options"
               ADD_TEXT="Grub settings will be changed:
GRUB_CMDLINE_LINUX_DEFAULT=\"quiet init=/sbin/e4rat-preload\"
Grub settings will be updated.

Perform an action?"
               HELP="
____________________________________
   Help

$0 - script helps configure e4rat.
E4rat may be useful in systems with one user , using the X- autostart in while you can also speed up the launch of the necessary programs.
On the server or when loaded into CLI - boot time can be reduced not by much.
For SSD- drives generally does not make sense to use, because they have no moving parts and as a result, there are no (almost) the delay, however, users of these discs may be helpful to review Ureadahead.
E4rat - Project Andreas Rid and Gundolf Kiefer, stands for e4 'reduced access time', applied only in the file system ext4.
 
The set of tools included e4rat : e4rat-collect, e4rat-realloc and e4rat-preload.
- e4rat-collect runs during a training boot and lists needed for the OS initialization files.
- e4rat-realloc reallocates blocks of files belonging to a list so that they are located in one area of ​​the hard disk.
- e4rat-preload advance puts the files into memory for faster loading.

 The script $0 :
Step 1 - prepare the system to start e4rat-collect, after a reboot takes effect e4rat-collect, which collects for a given time (default is 120 seconds), the information about running applications .
Only upon the expiration of the data collection can begin to Step 2.
Step 2 - prepare the system to start e4rat-realloc, after the restart is performed e4rat-realloc and added e4rat-preload to the startup parameters of the system.
The script allows you to change the time of collection of information , edit the configuration file /etc/e4rat.conf, manually add/exclude e4rat-preload settings from system startup.
___________________________________"
               STEP1_LABEL="Step 1"
               STEP1_TEXT1="The boot options will be added to the system utility e4rat-collect.
After restarting , this utility is for -" 
               STEP1_TEXT2="seconds to collect information about running programs and processes.
Only after this time can proceed to Step 2.

Grub settings will be updated.
Perform an action?"
               STEP2_LABEL="Step 2"
               STEP2_TEXT="Next loading will happen to the system mode - single.
After restarting there a black screen with the letters.
At this time, the utility will run e4rat-realloc, which will defragment and placement of applications on the basis of previously collected information.
Then, in the startup parameters of the system will be added to the utility e4rat-preload.
After all the changes in the system will reboot with the involved e4rat.

Grub settings will be updated.
Perform an action?"
               ;;
esac             
#########################################################
Check () #Функция проверки ПО
{
if [ -z "$1" ] #Проверка указан ли аргумент ф-ции
 then echo Argument check error; exit 1
fi
if [ ! -x "`which "$1"`" ] #Проверка наличия ПО
 then echo $1 $CHECK_PO
 exit 1
fi
}
#########################################################
Help () #Справка
{
echo "$HELP"
}
#########################################################
CollectInfo () #Шаг1
{
TIME=$(grep "timeout  " /etc/e4rat.conf  | sed "s/; timeout  //g" | sed "s/timeout  //g" | sed "s/ //g")
whiptail --title "$STEP1_LABEL" --yesno "$STEP1_TEXT1 $TIME $STEP1_TEXT2" 15 70
if [ $? == 0 ]
 then sed -i "s/GRUB_CMDLINE_LINUX_DEFAULT=\(.*\)/GRUB_CMDLINE_LINUX_DEFAULT=\"quiet init=\/sbin\/e4rat-collect\"/g" /etc/default/grub
      update-grub
 else MainForm
fi

}
#########################################################
DefragByInfo () #Шаг2
{
whiptail --title "$STEP2_LABEL" --yesno "$STEP2_TEXT" 18 60
if [ $? == 0 ]
 then echo -n '#! /bin/sh
echo "- Start script $0" > /dev/tty1
echo "- Update grub-info" > /dev/tty1
sed -i "s/GRUB_CMDLINE_LINUX_DEFAULT=\(.*\)/GRUB_CMDLINE_LINUX_DEFAULT=\"quiet init=\/sbin\/e4rat-preload\"/g" /etc/default/grub
update-grub
echo "- Delete temp files - /etc/rc1.d/S10my_e4rat_realloc and /etc/init.d/my_e4rat_realloc.sh" > /dev/tty1
rm -r /etc/rc1.d/S10my_e4rat_realloc
rm -r /etc/init.d/my_e4rat_realloc.sh
echo "- Start command: e4rat-realloc /var/lib/e4rat/startup.log" > /dev/tty1
echo "Wait, please. The system restarts automatically" > /dev/tty1
e4rat-realloc /var/lib/e4rat/startup.log
echo "- Reboot system"  > /dev/tty1
sleep 4s && reboot
exit 0
' > /etc/init.d/my_e4rat_realloc.sh
      chmod +x /etc/init.d/my_e4rat_realloc.sh
            ln /etc/init.d/my_e4rat_realloc.sh /etc/rc1.d/S10my_e4rat_realloc
      sed -i "s/GRUB_CMDLINE_LINUX_DEFAULT=\(.*\)/GRUB_CMDLINE_LINUX_DEFAULT=\"single\"/g" /etc/default/grub
      update-grub
 else MainForm
fi

}
########################################################
DefragByInfo2 () #Шаг2 - альтернативный с отображением выполнения e4rat-realloc 
{
whiptail --title "$STEP2_LABEL" --yesno "$STEP2_TEXT" 18 60
if [ $? == 0 ]
 then cp /root/.bashrc /root/.bashrc.backup
 echo -n '#! /bin/sh
echo "- Update grub-info"
sed -i "s/GRUB_CMDLINE_LINUX_DEFAULT=\(.*\)/GRUB_CMDLINE_LINUX_DEFAULT=\"quiet init=\/sbin\/e4rat-preload\"/g" /etc/default/grub
update-grub
echo "- mv /root/.bashrc.backup  /root/.bashrc"
mv /root/.bashrc.backup  /root/.bashrc
echo "- Start command: e4rat-realloc /var/lib/e4rat/startup.log"
echo "Wait, please."
e4rat-realloc /var/lib/e4rat/startup.log
echo "- Turn Enter for reboot system"
read x 
reboot
exit 0
' > /root/.bashrc
      chmod +x /root/.bashrc     
      sed -i "s/GRUB_CMDLINE_LINUX_DEFAULT=\(.*\)/GRUB_CMDLINE_LINUX_DEFAULT=\"single\"/g" /etc/default/grub
      update-grub
 else MainForm
fi

}

#########################################################
Adde4rat () #Добавление e4rat в автозагрузку
{
whiptail --title "$ADD_LABEL" --yesno "$ADD_TEXT" 13 60
if [ $? == 0 ]
 then sed -i "s/GRUB_CMDLINE_LINUX_DEFAULT=\(.*\)/GRUB_CMDLINE_LINUX_DEFAULT=\"quiet init=\/sbin\/e4rat-preload\"/g" /etc/default/grub
      update-grub
 else MainForm
fi
}
#########################################################
Dele4rat () #Исключение e4rat из автозагрузки
{
whiptail --title "$DEL_LABEL" --yesno "$DEL_TEXT" 13 60
if [ $? == 0 ]
 then sed -i "s/GRUB_CMDLINE_LINUX_DEFAULT=\(.*\)/GRUB_CMDLINE_LINUX_DEFAULT=\"quiet\"/g" /etc/default/grub
      update-grub
 else MainForm
fi	
}
#########################################################
RebootSystem () #Перезагрузка
{
whiptail --title "$ATTENTION" --yesno "$REBOOT_TEXT" 10 60
if [ $? == 0 ]
 then reboot
 else MainForm
fi
}
#########################################################
EditTime () #Функция установки времени сбора информации
{
TIME=$(grep "timeout  " /etc/e4rat.conf  | sed "s/; timeout  //g" | sed "s/timeout  //g" | sed "s/ //g")
while true; do
 TIME=$($DIALOG --title "Time" --inputbox "$TIME_TEXT" 10 60 $TIME 3>&1 1>&2 2>&3)
 if [ $? != 0 ]
  then echo to Mainmenu ; MainForm ; break
 fi
 case $TIME in
  *[!0-9]*|"") $DIALOG --title "$ATTENTION" --msgbox "$TIME $ERROR_TIME" 10 60 ;;
           * ) sed -i "s/; timeout  /timeout  /g" /etc/e4rat.conf
               sed -i "s/timeout  \(.*\)/timeout  ${TIME}/g" /etc/e4rat.conf
               break;;
  esac
done
}
#########################################################
MainForm () #Главная форма
{
ANSWER=$($DIALOG  --cancel-button "Exit" --title "$MAIN_LABEL" --menu \
    "$MAIN_TEXT" 13 60\
    7\
        1 "$MENU1"\
        2 "$MENU2"\
        3 "$MENU3"\
        4 "$MENU4"\
        5 "$MENU5"\
        6 "$MENU6"\
        7 "$MENU7" 3>&1 1>&2 2>&3)
if [ $? != 0 ]
 then echo Exit ; exit 0
fi
case $ANSWER in
    1) Check e4rat-collect
       CollectInfo
       RebootSystem
       ;;
    2) Check e4rat-realloc
       Check e4rat-preload
       DefragByInfo
       RebootSystem
       ;;
    3) EditTime
       MainForm
       ;;   
    4) Dele4rat
       MainForm
       ;;  
    5) Adde4rat
       Check e4rat-preload
       RebootSystem
       ;;
    6) Check nano
       nano /etc/e4rat.conf
       MainForm
       ;; 
    7) Help
       echo $HELP_EXIT 
       read x
       MainForm
       ;;              
    *) echo oops! - $ANSWER
       exit 1
       ;;
esac
}
#########################################################

MainForm

exit 0
