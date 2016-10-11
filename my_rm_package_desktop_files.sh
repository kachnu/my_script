#!/bin/bash
# Скрипт предназначен для удаления пакетов на основании ярлыка *.desktop
# author: kachnu
# email:  ya.kachnu@yandex.ua

# объявляем пустой список пакетов на удаление
DEL_PACKAGES=""

# в качестве аргументов к скрипту прилагается список *.desktop, поочередно перебираем этот список
for DESKTOP_FILE in $@
    do
       # из *.desktop получаем исполняемую команду
       EXEC_FILE=$(cat "$DESKTOP_FILE" | grep Exec | sed "s/Exec=//g")
       # echo $EXEC_FILE >> ~/t1.txt
       
       # из команды выделяем путь к бинарнику
       BIN_WAY=$(echo $(which $EXEC_FILE) | awk '{print $NF}')
       # echo $BIN_WAY >> ~/t2.txt
       
       # на основании пути к бинарнику, находим пакет в котором он содержится
       PACKAGE=$(dpkg -S $BIN_WAY | awk '{print $1}' | sed "s/://g") 
       # echo $PACKAGEY >> ~/t3.txt
       
       # указываем те пакеты, которые нельзя удалять
       case $PACKAGE in
            gksu) PACKAGE="";;
            sudo) PACKAGE="";;
       esac
       
       # добавляем пакет к списку пакетов на удаление
       DEL_PACKAGES=$DEL_PACKAGES" "$PACKAGE
       
       # постепенно выводим на экран информацию о том какие пакеты собираемся удалять, если пакет не найден выводим - NO PACKAGE
       if [[ $PACKAGE == "" ]]
          then PACKAGE="NO PACKAGE"
       fi
       echo "Program $BIN_WAY was purge (uninstall) - $PACKAGE"
done
echo "############"

# если список пакетов на удаление не пустой - начинаем удаление пакетов, если список пустой выводим - No packages for uninstall!
if [[ $(echo $DEL_PACKAGES | sed "s/ //g") != "" ]]
     then sudo apt-get purge $DEL_PACKAGES && sudo apt-get autoremove
          echo "Press Enter to EXIT"
          read x
     else echo No packages for uninstall!
          echo "Press Enter to EXIT"
          read x
fi
exit 0
