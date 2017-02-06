#!/bin/bash
#Скрипт по созданию собственной сборки, позволяет распаковать образ ISO и упаковать его обратно.
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
WORK_DIR="$HOME"

# Дополнительные свойства для текта:
BOLD='\033[1m'         #  ${BOLD}        # жирный шрифт (интенсивный цвет)
DBOLD='\033[2m'        #  ${DBOLD}       # полу яркий цвет (тёмно-серый, независимо от цвета)
NBOLD='\033[22m'       #  ${NBOLD}       # установить нормальную интенсивность
UNDERLINE='\033[4m'    #  ${UNDERLINE}   # подчеркивание
NUNDERLINE='\033[4m'   #  ${NUNDERLINE}  # отменить подчеркивание
BLINK='\033[5m'        #  ${BLINK}       # мигающий
NBLINK='\033[5m'       #  ${NBLINK}      # отменить мигание
INVERSE='\033[7m'      #  ${INVERSE}     # реверсия (знаки приобретают цвет фона, а фон -- цвет знаков)
NINVERSE='\033[7m'     #  ${NINVERSE}    # отменить реверсию
BREAK='\033[m'         #  ${BREAK}       # все атрибуты по умолчанию
NORMAL='\033[0m'       #  ${NORMAL}      # все атрибуты по умолчанию
# Цвет текста: 
BLACK='\033[0;30m'     #  ${BLACK}       # чёрный цвет знаков
RED='\033[0;31m'       #  ${RED}         # красный цвет знаков
GREEN='\033[0;32m'     #  ${GREEN}       # зелёный цвет знаков
YELLOW='\033[0;33m'    #  ${YELLOW}      # желтый цвет знаков
BLUE='\033[0;34m'      #  ${BLUE}        # синий цвет знаков
MAGENTA='\033[0;35m'   #  ${MAGENTA}     # фиолетовый цвет знаков
CYAN='\033[0;36m'      #  ${CYAN}        # цвет морской волны знаков
GRAY='\033[0;37m'      #  ${GRAY}        # серый цвет знаков
##################################
SelectDistributiv ()
{
DISTRIBUTIV=$($DIALOG --cancel-button "Выход" --title  "Выберите дистрибутив" --checklist \
"Выберите дистрибутив" 15 80 4 \
debian "Основные файлы находятся в папке образ_iso/live/" OFF \
ubuntu "Основные файлы находятся в папке образ_iso/casper/" OFF 3>&1 1>&2 2>&3 )
if [ $? != 0 ]
  then echo Нажали отмену; exit 1;
fi
DISTRIBUTIV=$(echo "$DISTRIBUTIV" | sed "s/\"//g")
if [[ $DISTRIBUTIV == '' ]]
 then SelectDistributiv
fi
}
##################################
Help ()
{
 echo -en "${CYAN} 
Скрипт $0 позволяет разбирать и собирать Live ISO дистрибутивов Debian и Ubuntu.
Скрипт автоматически распознает с каким дистрибутивом ведется работа. 
Пояснения по пунктам меню:
  1 Распаковать iso и создать временные файлы - создаются временная/рабочая папка mydistr, монтируется iso, производится копирование содержимого iso в папку mydistr_iso и распаковка filesystem.squashfs в папку mydistr_root. 
  2 Инструкции по изменению дистрибутива - описаны действия по изменению дистрибутива, установка программ и т.д.
  3 Подготовить iso (filesystem.squashfs и т.д.) - создается filesystem.squashfs из содержимого папки mydistr_root, копируются актуальное ядро и инит, обновляются списки установленных пакетов, производится подсчет контрольной суммы по MD5.
  4 Собрать  iso - генерируется iso-образ
  5 Удалить временные файлы и папки - удаление временных файлов и папок
  6 Выполнить всё: распаковка-инструкция-упаковка-очистка - выполняются поочередно пп 1-4 
  7 Справка - то что вы сейчас читаете
${NORMAL}
"
}
##################################
UnpackIsoSquashfs ()
{
echo "- Создание рабочей папки mydistr в домашней папке пользователя"
mkdir $WORK_DIR/mydistr
cd $WORK_DIR/mydistr

echo "- Создание папок mnt и mydistr_iso под iso-образ"
mkdir mnt
mkdir mydistr_iso

echo "- Ввод пути к iso-образу CD/DVD"
while true; do
 WAY=$($DIALOG --title "Путь к образу ISO" --inputbox "Введите путь к iso-образу CD/DVD (можно воспользоваться ф-цией Copy way-контекстного меню Thunar)" 10 60 $WAY 3>&1 1>&2 2>&3)
 if [ $? != 0 ]
  then echo Нажали отмену - переход в главное меню ; MainForm ; break
 fi
 if [ -f "$WAY" ];
 then
  {
  case $WAY in
   *.iso ) echo "- Монтирование iso-образа $WAY в папку mnt/" ; sudo mount -o loop $WAY mnt;  break;; 
   * ) $DIALOG --title "ВНИМАНИЕ!" --msgbox "Файл $WAY не является iso-образом. Повторите ввод!" 10 60 ;;
  esac
  }
  else $DIALOG --title "ВНИМАНИЕ!" --msgbox "Файл $WAY не найден. Повторите ввод!" 10 60 
 fi
done

# Определяем с каким дистрибутивом имеем дело
if [ -d mnt/live/ ]
 then DISTRIBUTIV=debian
fi
if [ -d mnt/casper/ ]
 then DISTRIBUTIV=ubuntu
fi
if [[ -d mnt/live/ && -d mnt/casper/ ]]
 then SelectDistributiv
fi
if [[ $DISTRIBUTIV == '' ]]
 then echo "В образе нет папок casper/ или live/ я не могу определиться какой это дистрибутив - Чао, Пупсики!"
      sudo umount mnt
      sudo rm -r mnt 
      sudo rm -r mydistr_iso
      exit 1
fi
echo "- Работаем с дистрибутивом - $DISTRIBUTIV "  

echo "- Копирование содержимого mnt/ в mydistr_iso (кроме filesystem.squashfs)"
case $DISTRIBUTIV in
     debian) rsync --exclude=/live/filesystem.squashfs -a mnt/ mydistr_iso ;;
     ubuntu) rsync --exclude=/casper/filesystem.squashfs -a mnt/ mydistr_iso ;;
     *) echo "debian или ubuntu?" ; exit 1 ;;
esac

echo "- Распаковывание образа системы (файл filesystem.squashfs) и помещение его в mydistr_root"
case $DISTRIBUTIV in
     debian) sudo unsquashfs mnt/live/filesystem.squashfs ;;
     ubuntu) sudo unsquashfs mnt/casper/filesystem.squashfs ;;
     *) echo "debian или ubuntu?" ; exit 1 ;;
esac
sudo mv squashfs-root mydistr_root

echo "- Отмонтирование iso-образа от mnt/ и удаление временной папки mnt"
sudo umount mnt
sudo rmdir mnt

echo "Этап создания исходных папок и файлов закончен"
beep
}
##################################
ManEditDirtrib ()
{
echo -en "${UNDERLINE}
Следующая последовательность команд написана в качестве мануала и нужна для установки ПО в новой сборке.
${NORMAL} ${BLUE} 
cd $WORK_DIR/mydistr
sudo -s

cp /etc/apt/apt.conf.d/proxy mydistr_root/etc/apt/apt.conf.d/
cp /etc/hosts mydistr_root/etc/
cp /etc/resolv.conf mydistr_root/etc/
mount --bind /dev/ mydistr_root/dev
chroot mydistr_root

mount -t proc none /proc
mount -t sysfs none /sys
mount -t devpts none /dev/pts
export HOME=/root
export LC_ALL=C
${NORMAL}
Издеваемся над дистром, ставим программы apt-get update upgrade dist-upgrade purge install -f или aptitude
${BLUE} 
apt-get clean
rm -rf /tmp/* ~/.bash_history /home/*
umount /proc || umount -lf /proc
umount /sys
umount /dev/pts
exit

umount mydistr_root/dev
rm mydistr_root/etc/hosts
rm mydistr_root/etc/resolv.conf
rm mydistr_root/etc/apt/apt.conf.d/proxy
${NORMAL}____________
Удачного изменения дистрибутива! " 
beep
}
##################################
MakeSquashfs ()
{
if [ -d $WORK_DIR/mydistr/ ];
 then echo "- Переход в рабочую папку $WORK_DIR/mydistr/"; cd $WORK_DIR/mydistr/ ;
 else $DIALOG --title "ВНИМАНИЕ!" --msgbox "Рабочая папка $WORK_DIR/mydistr/ отсутсвует!!! Начните работу с первого пункта " 10 60 ; MainForm;
fi

# Определяем с каким дистрибутивом имеем дело
if [ -d mydistr_iso/live/ ]
 then DISTRIBUTIV=debian
fi
if [ -d mydistr_iso/casper/ ]
 then DISTRIBUTIV=ubuntu
fi
if [[ -d mydistr_iso/live/ && -d mydistr_iso/casper/ ]]
 then SelectDistributiv
fi
if [[ $DISTRIBUTIV == '' ]]
 then echo "В рабочей папке mydistr_iso нет casper/ или live/ я не могу определиться какой это дистрибутив - Чао, Пупсики!"; exit 1
fi
#DISTRIBUTIV=$(cat mydistr_root/etc/*release* | grep -w "ID" | sed "s/ID=//g")
echo "- Работаем с дистрибутивом - $DISTRIBUTIV " 

echo "- Копирование ядра и инит "
SPISOK_YADER=$(find mydistr_root/boot/vmlinuz* | sed "s/mydistr_root\/boot\///g" | sed "s/$/ ядро NO/" )
if [[ $SPISOK_YADER == '' ]]
 then echo Происходит какая-то срань - не могу найти ядра в mydistr_root/boot/
      exit 1
fi
ANSWER_YADRO=$($DIALOG --title "Выбор ядра" --checklist \
"Выберите ядро которое будет использоваться в LIVE" 15 60 4 \
$SPISOK_YADER 3>&1 1>&2 2>&3 )
if [ $? != 0 ]
  then echo Нажали отмену - переход в главное меню 
       MainForm 
fi
if [[ $ANSWER_YADRO == '' ]]
  then echo не выбрано ядро
      MainForm
fi
YADRO=$(echo $ANSWER_YADRO | sed "s/\"//g")
INIT=$(echo $YADRO | sed "s/vmlinuz/initrd.img/g")
echo "Будет скопировано ядро - $YADRO и инит - $INIT"

case $DISTRIBUTIV in
    debian) sudo cp mydistr_root/boot/$YADRO mydistr_iso/live/vmlinuz
            sudo cp mydistr_root/boot/$INIT mydistr_iso/live/initrd.img
            ;;
    ubuntu) sudo cp mydistr_root/boot/$YADRO mydistr_iso/casper/vmlinuz
            sudo cp mydistr_root/boot/$INIT mydistr_iso/casper/initrd.gz
            gzip -dc mydistr_iso/casper/initrd.gz | sudo lzma -7 > mydistr_iso/casper/initrd.lz
            ;;
         *) echo "debian или ubuntu?" ; exit 1 ;;
esac

case $DISTRIBUTIV in
     debian) echo "- Создание списка установленных пакетов mydistr_iso/live/filesystem.packages"
             sudo rm mydistr_iso/live/filesystem.manifest
             sudo rm mydistr_iso/live/filesystem.packages
             sudo chroot mydistr_root dpkg-query -W --showformat='${Package} ${Version}\n' | sudo tee mydistr_iso/live/filesystem.packages
             ;;
     ubuntu) echo "- Создание списка установленных пакетов mydistr_iso/casper/filesystem.manifest"
             chmod +w mydistr_iso/casper/filesystem.manifest
             sudo chroot mydistr_root dpkg-query -W --showformat='${Package} ${Version}\n' > mydistr_iso/casper/filesystem.manifest
             sudo cp mydistr_iso/casper/filesystem.manifest mydistr_iso/casper/filesystem.manifest-desktop
             sudo sed -i '/ubiquity/d' mydistr_iso/casper/filesystem.manifest-desktop
             sudo sed -i '/casper/d' mydistr_iso/casper/filesystem.manifest-desktop
             sudo sh -c "printf $(sudo du -sx --block-size=1 mydistr_root | cut -f1) > mydistr_iso/casper/filesystem.size"
             ;;
        *) echo "debian или ubuntu?" ; exit 1 ;;
esac

echo "- Удаление filesystem.squashfs "
case $DISTRIBUTIV in
     debian) sudo rm mydistr_iso/live/filesystem.squashfs ;;
     ubuntu) sudo rm mydistr_iso/casper/filesystem.squashfs ;;
          *) echo "debian или ubuntu?" ; exit 1 ;;
esac

echo "- Создание образа filesystem.squashfs на основании содержимого mydistr_root"
case $DISTRIBUTIV in
     debian) sudo mksquashfs mydistr_root mydistr_iso/live/filesystem.squashfs -no-fragments -b 1048576 ;;
     ubuntu) sudo mksquashfs mydistr_root mydistr_iso/casper/filesystem.squashfs -no-fragments -b 1048576 ;;
          *) echo "debian или ubuntu?" ; exit 1 ;;
esac

echo "- Подсчет контрольной суммы MD5"
cd mydistr_iso
sudo rm md5sum.txt
find -type f -print0 | sudo xargs -0 md5sum | grep -v isolinux/boot.cat | sudo tee md5sum.txt
beep
}
##################################
MakeIso ()
{
echo "- Ввод пути для сохранения iso-образа"
while true; do
 WAY=$($DIALOG --title "Путь для сохранения ISO" --inputbox "Введите путь и имя для сохранения iso-образа CD/DVD (можно воспользоваться ф-цией Copy way-контекстного меню Thunar)" 10 60 $WAY 3>&1 1>&2 2>&3)
 if [ $? != 0 ]
  then echo Нажали отмену - переход в главное меню ; MainForm ; break
 fi
 DIRWAY=$(dirname $WAY)
 if [ -d "$DIRWAY" ];
 then
 {
  case $WAY in
   *.iso ) echo "- Создание iso-образа CD/DVD $WAY" 
           if [[ -x "`which xorriso`" ]]
            then 
                 if [[ -f /usr/lib/syslinux/mbr/isohdpfx.bin ]] ; then
                    isohybrid_opt="-isohybrid-mbr /usr/lib/syslinux/mbr/isohdpfx.bin"
                 elif [[ -f /usr/lib/syslinux/isohdpfx.bin ]] ; then
                    isohybrid_opt="-isohybrid-mbr /usr/lib/syslinux/isohdpfx.bin"
                 elif [[ -f /usr/lib/ISOLINUX/isohdpfx.bin ]] ; then
                    isohybrid_opt="-isohybrid-mbr /usr/lib/ISOLINUX/isohdpfx.bin"
                 else
			        echo "Can't create isohybrid.  File: isohdpfx.bin not found. The resulting image will be a standard iso file."
                 fi
                sudo xorriso -as mkisofs -r -J -joliet-long -l ${isohybrid_opt} -partition_offset 16 -V "$DISTRIBUTIV-custom"  -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot \
    -boot-load-size 4 -boot-info-table -o "$WAY" $WORK_DIR/mydistr/mydistr_iso | tee >($DIALOG --title="Creating CD/DVD image file..." --progress --pulsate --auto-close --width 300) 
                break
           fi 
           if [[ -x "`which genisoimage`" ]]
            then sudo genisoimage -D -r -V "$DISTRIBUTIV-custom" -cache-inodes -J -l -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table -o $WAY $WORK_DIR/mydistr/mydistr_iso 
                 break
           fi
           if [[ -x "`which mkisofs`" ]]
            then sudo mkisofs -D -r -V "$DISTRIBUTIV-custom" -cache-inodes -J -l -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table -o $WAY $WORK_DIR/mydistr/mydistr_iso 
                 break
           fi
           ;; 
           
     * ) $DIALOG --title "ВНИМАНИЕ!" --msgbox "Файл $WAY не является iso-образом. Повторите ввод!" 10 60 ;;
  esac
 }
 else $DIALOG --title "ВНИМАНИЕ!" --msgbox "Указанная папка $DIRWAY не существует. Повторите ввод!" 10 60 
 fi
done
echo "Все действия выполнены. Файл iso находится по адресу $WAY"
beep 
}
##################################
RmWorkFiles ()
{
ANSWER=$($DIALOG  --title "Удаление временных файлов" --menu \
    "Выберите действие" 13 55\
    6\
        1 "Оставить временные файлы"\
        2 "Удалить все временные папки и файлы $WORK_DIR/mydistr/"\
        3 "Удалить только $WORK_DIR/mydistr/mydistr_iso"\
        4 "Удалить только $WORK_DIR/mydistr/mydistr_root" 3>&1 1>&2 2>&3)
if [ $? != 0 ]
 then echo Нажали отмену; MainForm
fi	
case $ANSWER in
 1 ) MainForm ;;
 2 ) sudo rm -r $WORK_DIR/mydistr ;; 
 3 ) sudo rm -r $WORK_DIR/mydistr/mydistr_iso ;; 
 4 ) sudo rm -r $WORK_DIR/mydistr/mydistr_root ;; 
 * ) Неожиданный ответ: $ANSWER ; exit 1 ;;
esac
echo "Все действия выполнены"
}
##################################
MainForm ()
{
ANSWER=$($DIALOG  --cancel-button "Выход" --title "Собираем дистрибутивчик $DISTRIBUTIV" --menu \
    "Выберите действие" 16 70\
    8\
        1 "Распаковать iso и создать временные файлы"\
        2 "Инструкции по изменению дистрибутива"\
        3 "Подготовить iso (filesystem.squashfs и т.д.)"\
        4 "Собрать iso"\
        5 "Удалить временные файлы и папки"\
        6 "Выполнить всё: распакова-инструкция-упаковка-очистка"\
        7 "Справка" 3>&1 1>&2 2>&3)
if [ $? != 0 ]
 then echo Нажали Выход - выходим с нулем ; exit 0
fi
case $ANSWER in
    1) UnpackIsoSquashfs 
       echo "Нажмите Enter для перехода в главное меню" 
       read x
       MainForm
       ;;
    2) ManEditDirtrib 
       echo "Нажмите Enter для перехода в главное меню" 
       read x
       MainForm
       ;;
    3) MakeSquashfs
       echo "Нажмите Enter для перехода в главное меню" 
       read x
       MainForm ;;
    4) MakeIso
       echo "Нажмите Enter для перехода в главное меню" 
       read x
       MainForm;;
    5) RmWorkFiles 
       echo "Нажмите Enter для перехода в главное меню" 
       read x
       MainForm;;   
    6) UnpackIsoSquashfs
       echo "- После проведения изменений, наберите next и нажмите Enter, для перехода к этапу формирования iso-образа" 
       while true; do
        read NEXT
        case $NEXT in
         next ) echo "- Выполнен переход к этапу формирования iso-образа CD/DVD";  break;; 
         * ) echo "Наберите next и нажмите Enter, для продолжения";;
        esac
       done
       ManEditDirtrib
       MakeSquashfs
       MakeIso
       RmWorkFiles
       echo "Нажмите Enter для перехода в главное меню" 
       read x
       MainForm
       ;;       
    7) Help  
       echo "Нажмите Enter для перехода в главное меню" 
       read x
       MainForm
       ;;
    *) echo Неожиданнй ответ: $ANSWER
       exit 1
       ;;
esac
}
##################################


MainForm

exit 0
