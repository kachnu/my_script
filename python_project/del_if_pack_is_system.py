#!/usr/bin/env python3
# Скрипт не отслеживает версии пакетов!
import os

# формируем список установленных пакетов
install_packages = os.popen("dpkg -l | grep 'ii' | awk ' {print $2} '").read()
install_packages = install_packages.split("\n")
# print (install_packages)

# формируем список пакетов находящихс в папке со скриптом
packages = os.popen("ls | grep '.deb' | sed -r 's|_.+||'").read()
packages = packages.split("\n")
# print(packages)

# сравниваем есть ли пакет в системе, если есть - удаляем его
for i in packages:
    if i in install_packages and i != '':
        os.system(u"rm {0:s}_*.deb".format(i))
        print((u"{0:s} - REMOVE!".format(i)))
    elif i != '':
        print((u"{0:s} - not found in system.".format(i)))
