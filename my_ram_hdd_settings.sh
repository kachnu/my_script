#!/bin/bash
# Скрипт предназначен для настройки параметров работы с дисками и памятью
# основой для создания скрипта послужили статьи
# http://vasilisc.com/tmp-on-tmpfs
# http://fx-files.ru/archives/704
# https://wiki.archlinux.org/index.php/Solid_State_Drives_(%D0%A0%D1%83%D1%81%D1%81%D0%BA%D0%B8%D0%B9)
# https://mikekuriger.wordpress.com/2013/06/13/how-to-tweak-and-optimize-ssd-in-ubuntu-linux/
# https://habrahabr.ru/post/129551/
#
# author: kachnu
# email: ya.kachnu@gmail.com

DIALOG=whiptail
if [ ! -x "`which "$DIALOG"`" ]
   then DIALOG=dialog
fi

EDITOR=nano

case $LANG in
  uk*|ru*|be*) #UA RU BE locales
               MAIN_LABEL="Настройка параметров работы с дисками и памятью"
               MAIN_TEXT="Выберите действие:"

               MENU_BACKUP="Backup настроек"
               MENU_PARTITION_FORM="Настройки монтирования"
               MENU_SYSCTL_FORM="Настройки Sysctl"
               MENU_SWAP_FORM="Настройки Swap"
               MENU_SCHEDULER_FORM="Настройки планировщика ввода/вывода"
               MENU_OTHER_FORM="Дополнительные настройки"
               MENU_TMP_TO_RAM="Временные файлы /tmp в ОЗУ"
               MENU_LOG_TO_RAM="Переменные /var/* в ОЗУ"
               MENU_AUTOSETTINGS_SSD="Автонастройка для SSD"
               MENU_EDIT_CONF="Редактирование конф. файлов"
               MENU_HELP="Справка"

               MAIN_PART="Выберите раздел:"
               MENU_DISCARD="TRIM через discard"
               MENU_FSTRIM="TRIM по расписанию fstrim"
               MENU_INFO_FSTRIM="n - выключить fstrim
d - включать fstrim каждый день
w - включать fstrim каждую неделю
m - включать fstrim каждый месяц"

               MENU_BARRIER="Снять барьер barrier=0"
               MENU_COMMIT="Задержка сброса commit=600"
               MENU_NOATIME="Не отслеживать доступ noatime"

               MENU_SWAPPINESS="Настроить порог swappiness"
               MENU_INFO_SWAPPINESS="Введите значение в % (от 0 до 100) свободной ОЗУ, при котором начнется задействование подкачки swap.
Для ОЗУ 2 GB = 30, 4 GB = 10, 6 GB or more = 0."
               MENU_VFS_CACHE_PRESSURECAT="Настроить vfs_cache_pressurecat"
               MENU_SCHED_AUTOGROUP_ENABLED="Включить sched_autogroup_enabled"
               MENU_INFO_VFS_CACHE_PRESSURECAT="Введите значение (от 0 до 1000), чтобы определить отношение ядра к освободившимся страницам памяти.
Чем ниже значение, тем дольше информация хранится в ОЗУ и меньше кэшируется, значение выше 100 способствует агрессивному кэшированию.
Для SSD рекомендуют 50, для HDD - 1000."
               MENU_LAPTOPMODE="Режим laptop и активация отложенной записи"
               MENU_DIRTY_WRITEBACK_CENTISECS="Отложенная запись dirty_writeback_centisecs"
               MENU_INFO_DIRTY_WRITEBACK_CENTISECS="Введите значение (от 0 до 60000), чтобы установить время задержки записи (запуска pdflush) на жесткий диск (100 ед. = 1 секунда).
Для SSD - 6000 (1 минута)"
               MENU_DIRTY_RATIO="Настроить dirty_ratio"
               MENU_INFO_DIRTY_RATIO="Введите значение в % (от 0 до 100) - доля свободной системной памяти в процентах, по достижении которой процесс, ведущий запись на диск, инициирует запись \"грязных\" данных.
Для SSD - 60"
               MENU_DIRTY_BACKGROUND_RATIO="Настроить dirty_background_ratio"
               MENU_INFO_DIRTY_BACKGROUND_RATIO="Введите значение в % (от 0 до 100) - доля свободной памяти в процентах от общей памяти всей системы, по достижении которой демон pdflush начинает сбрасывать данные их дискового кэша на сам диск.
Для SSD - 5"

               MENU_SWAP="Подкачка swap"
               MENU_FILE_SWAP="Файл подкачки"
               MENU_INFO_FILE_SWAP="Введите объем файла подкачки в МБ от 0 до"
               MENU_PARTITION_SWAP="Раздел подкачки"
               MENU_ZRAM="Технология ZRAM"
               MENU_ZSWAP="Технология ZSWAP"

               MENU_IDLE3="Таймер парковки головок HDD WD"
               MENU_INFO_IDLE3="Значение может быть целым числом от 1 до 255.
Таймер устанавливается в 0.1 сек для диапазона 1-128, и в 30 сек для диапазона 129-255.
Значение равное 0 - отключает парковку.
Скрипт работает для /dev/sda"
               MENU_PRELOAD="Сортировка в Preload"
               MENU_INFO_PRELOAD="0 - Без сортировки ввода/вывода.
Подходит для флэш-памяти и SSD.
1 - Сортировка на основе только пути к файлу.
Подходит для сетевых файловых систем.
2 - Сортировка в зависимости от количества индексных дескрипторов.
Снижает кол-во операций ввода/вывода, чем вариант - 3.
3 - Сортировка ввода/вывода на основе дискового блока. Самый сложный алгоритм.
Подходит для большинства файловых систем Linux."

               MENU_EDIT_FSTAB="Редактирование /etc/fstab"
               MENU_EDIT_SYSCTLCONF="Редактирование /etc/sysctl.conf"
               MENU_EDIT_GRUB="Редактирование /etc/default/grub"

               MENU_MAKE_RULE="Установить правило выбора планировщика"
               MENU_DEL_RULE="Удалить правило"
               MENU_CHOOSE_SCHEDULE="Выбор планировщика"
               MAIN_DEV="Выберите устройство:"
               MAIN_SCHE="Выберите планировщик:"

               HELP_EXIT="
Нажмите Enter для перехода в главное меню"
               ATTENTION="ВНИМАНИЕ!"
               RESTART_TEXT="Для применения настроек необходимо перезагрузить ПК!

Перезагрузить ПК сейчас?"
               POWER_OFF_TEXT="Для применения настроек необходимо выключить ПК!

Выключить ПК сейчас?"
               GRUB_TEXT="Для применения изменений в Grub, необходимо выполнить sudo update-grub

Обновить Grub сейчас?"
               HIB_SWAP_TEXT="Вы хотите использовать этот swap при гибернации?"
               AUTOSETTINGS_SSD_TEXT="Будут произведены следующие действия:
- изменены параметры монтирования /
- изменены параметры  sysctl
- изменены параметры  Preload
- включено ежедневное fstrim
- включено монтирование /tmp и логов в ОЗУ

Произвести указанные действия?"
               HELP="
____________________________________
   Справка

$0 - скрипт предназначен для настроки таких параметров системы как: журналирование, подкачка, способы хранения временных файлов, монтирование и т.д.
____________________________________
* $MENU_BACKUP - сохраняет/восстанавливает конфиругационые файлы:
  - /etc/fstab
  - /etc/sysctl.conf
  - /etc/default/grub
____________________________________
* $MENU_PARTITION_FORM - Позволяет настроить параметры монтирования разделов в /etc/fstab:
  - $MENU_DISCARD - включить TRIM с помощью параметра discard, нужно быть уверенным, что данный режим поддерживается апаратно и файловой системой
  - $MENU_FSTRIM - включить TRIM по расписанию с помощью fstrim
  - $MENU_BARRIER - позволяет повысить производительность за счет снятия барьера на запись, при этом есть риск нарушения целостности ФС, будьте внимательны - компьютер должен иметь гараниторанное электропитание (подходит для ноутбуков и ПК с UPS)
  - $MENU_COMMIT - установить минутную задержку сброса дискового кэша на сам диск
  - $MENU_NOATIME - не записывать время последнего доступа к файлам (использование данного параметра довольно спорно и не должно приносить существенной пользы, т.к. по умолчанию идет relatime - записывает последнее время, только если файл изменился)
____________________________________
* $MENU_SYSCTL_FORM - Позволяет настроить режимы работы системы, а именно пороги свопирования, установить отложенную записть и пороги сброса грязных страниц памяти.
  - $MENU_SWAPPINESS - установить размер свободной памяти ОЗУ при котором начинается высвобождение ОЗУ и кеширование в swap, т.е. объем свободной памяти при котором будет задействован swap
  - $MENU_SCHED_AUTOGROUP_ENABLED - активирует параметр ядра sched_autogroup_enabled - режим автоматической группировки задач, для повышения интерактивности на десктопе.
  - $MENU_VFS_CACHE_PRESSURECAT - установить уровень выделяемой памяти под кэш. Значение по умолчанию: 100. Увеличение этого параметра заставляет ядро активнее выгружать неиспользуемые страницы памяти из кеша, т.е. количество выделяемой оперативной памяти под кеш будет расти медленнее, что в свою очередь снизит вероятность того, что будет задействован раздел swap. При уменьшении этого параметра ядро, наоборот, будет дольше держать страницы памяти в кеше, в том числе и в swap'е. Это имеет смысл при небольшом количестве ОЗУ, например, если у нас 512 МБ памяти, то параметр vfs_cache_pressure можно выставить равным 50. Это позволит сократить количество дисковых операций в swap разделе, так удаление неиспользуемых страниц будет происходить реже. Дальнейшее уменьшение этого параметра может привести к нехватке памяти.
  - $MENU_LAPTOPMODE - при ключении режима laptopmode ядро будет копить данные, ожидающие записи на диск, и записывать их либо при острой необходимости, либо по истечении таймаута. Таймаут настраивается в dirty_writeback_centisecs
  - $MENU_DIRTY_WRITEBACK_CENTISECS - (default 500): в сотых долях секунд. Этот параметр означает как часто pdflush возобновляет работу для записи данных на диск. По умолчанию возобновляет работу 2 потока каждые 5 секунд.
Возможно недокументированное поведение, которое пресекает попытки уменьшения dirty_writeback_centisecs для более агрессивного кэширования данных процессом pdflush. Например, в ранних версиях ядра 2.6 Linux в файле mm/page-writeback.c код включал логику, которая описывалась \"если запись на диск длится дольше, чем параметр dirty_writeback_centisecs, тогда нужно поставить интервал в 1 секунду\". Эта логика описана только в коде ядра, и ее функционирование зависит от версии ядра Linux. Так как это не очень хорошо, поэтому вы будете защищены от уменьшения этого параметра.
  - $MENU_DIRTY_RATIO - (default 40) - максимальный процент общей оперативной памяти, который может быть выделен под страничный кэш, до того как pdflush будет писать данные на диск.
Второй по значимости параметр для настройки. При значительном снижении этого параметра приложения, которые должны писать на диск, будут блокироваться все вместе.
  - $MENU_DIRTY_BACKGROUND_RATIO - (default 10): Максимальный процент оперативной памяти, который может быть заполнен страничным кэшем до записи данных на диск. Некоторые версии ядра Linux могут этот параметр устанавливать в 5%.
В большинстве документации этот параметр описывается как процент от общей оперативной памяти, но согласно исходным кодам ядра Linux это не так. Глядя на meminfo, параметр dirty_background_ratio расчитывается от величины MemFree + Cached - Mapped. Поэтому для нашей демонстрационной системы 10% составляет немного меньше, чем 250MB, но не 400MB.
Основной инструмент настройки. Обычно уменьшают этот параметр. Если ваша цель снизить количество данных, хранимое в кэше, так что данные будут писаться на диск постепенно, а не все сразу, то уменьшение этого параметра наиболее эффективный путь. Значение по умолчанию наиболее приемлимо для систем имеющих много оперативной памяти и медленные диски.
____________________________________
* $MENU_SWAP_FORM - Позволяет настроить подкачку SWAP в системе
  - $MENU_SWAP - вкл/откл подкачки, при этом также вкл/откл \"Спящий режим\"
  - $MENU_FILE_SWAP - ипользование файла в качестве подкачки
  - $MENU_PARTITION_SWAP - использование раздела жесткого диска в качестве подкачки
  - $MENU_ZRAM - создание в ОЗУ сжатого раздела подкачки SWAP, уменьшает износ HDD и SSD
  - $MENU_ZSWAP - отличается от ZRAM тем, что использует существующий swap-раздел на диске, а в ОЗУ создаётся пул со сжатыми данными (кэшем). После того как пул до отказа забьётся сжатыми данными, он сбросит их в раздел подкачки и снова начнёт принимать и сжимать данные
____________________________________
* $MENU_SCHEDULER_FORM - Позволяет выборать планировщика ввода/вывода на ходу или создать правило выбора планировщика
  - $MENU_MAKE_RULE - Создает правило выбора планировщика для устройств HDD, SSD, USB
  - $MENU_DEL_RULE - Удаляет правило выбора планировщика
  - $MENU_CHOOSE_SCHEDULE - Выбор планировщика ввода/вывода на ходу, выбор сохранится до перезагрузки ПК

    NOOP — наиболее простой планировщик. Он банально помещает все запросы в очередь FIFO и исполняет их вне зависимости от того, пытаются ли приложения читать или писать. Планировщик этот, тем не менее, пытается объединять однотипные запросы для сокращения операций ввода/вывода.
    CFQ - Заключается его алгоритм в следующем. Каждому процессу назначается своя очередь запросов ввода/вывода. Каждой очереди затем присваивается квант времени. Планировщик же циклически обходит все процессы и обслуживает каждый из них, пока не закончится очередь либо не истечет заданный квант времени. Если очередь закончилась раньше, чем истек выделенный для нее квант времени, планировщик подождет (по умолчанию 10 мс) и, в случае напрасного ожидания, перейдет к следующей очереди. Отмечу, что в рамках каждой очереди чтение имеет приоритет над записью.
    Deadline - В основе его работы, как это ясно из названия, лежит предельный срок выполнения — то есть планировщик пытается выполнить запрос в указанное время. В дополнение к обычной отсортированной очереди, которая появилась еще в Linus Elevator, в нем есть еще две очереди — на чтение и на запись. Чтение опять же более приоритетно, чем запись. Кроме того, запросы объединяются в пакеты. Пакетом называется последовательность запросов на чтение либо на запись, которая идет в сторону б?льших секторов («алгоритм лифта»). После его обработки планировщик смотрит, есть ли запросы на запись, которые не обслуживались длительное время, и в зависимости от этого решает, создавать ли пакет на чтение либо же на запись.
____________________________________
* $MENU_OTHER_FORM
  - $MENU_IDLE3 - установить время парковки головок жесткого диска WD и продлить время работы жиска (только для /dev/sda)
  - $MENU_PRELOAD - установить тип сортировки блоков информации для preload
____________________________________
* $MENU_TMP_TO_RAM - Все временные файлы будут храниться в ОЗУ, что повышает быстродействие и уменьшает износ HDD и SSD
Данная технология уже давно применяется в Solaris, Fedora и ArchLinux
Не рекомендуется использовать на ПК с малым объемом ОЗУ
____________________________________
* $MENU_LOG_TO_RAM - Позволяет хранить логи в ОЗУ, уменьшает износ HDD и SSD, однако логи исчезают после перезагрузки ПК
____________________________________
* $MENU_AUTOSETTINGS_SSD - Автоматическое конфигурирование системы (параметров монтирования, свопирования, пределов сброса страниц памяти и т.д.) на работу с SSD
____________________________________"
               ;;
            *) #All locales
               MAIN_LABEL="Configure disk and memory"
               MAIN_TEXT="Select an action:"

               MENU_BACKUP="Backup settings"
               MENU_PARTITION_FORM="Mount options"
               MENU_SYSCTL_FORM="Settings Sysctl"
               MENU_SWAP_FORM="Settings Swap"
               MENU_SCHEDULER_FORM="Scheduler settings"
               MENU_OTHER_FORM="Additional settings"
               MENU_TMP_TO_RAM="Temporary files / tmp on RAM"
               MENU_LOG_TO_RAM="Logs /var/* to RAM"
               MENU_AUTOSETTINGS_SSD="Auto-tuning for the SSD"
               MENU_EDIT_CONF="Edit config files"
               MENU_HELP="Help"

               MAIN_PART="Choose partition:"
               MENU_DISCARD="TRIM with discard"
               MENU_FSTRIM="TRIM scheduled fstrim"
               MENU_INFO_FSTRIM="n - off fstrim
d - on fstrim everyday
w - on fstrim every week
m - on fstrim every month"

               MENU_BARRIER="Remove the barrier barrier=0"
               MENU_COMMIT="Reset delay commit=600"
               MENU_NOATIME="Do not track access - noatime"

               MENU_SWAPPINESS="Adjust the threshold swappiness"
               MENU_INFO_SWAPPINESS="Enter the value in % (0 to 100) of free memory, in which the activation of the swap.
For RAM 2 GB = 30 GB = 4, 10, 6 GB or more = 0."
               MENU_SCHED_AUTOGROUP_ENABLED="Activate sched_autogroup_enabled"
               MENU_VFS_CACHE_PRESSURECAT="Customize vfs_cache_pressure cat"
               MENU_INFO_VFS_CACHE_PRESSURECAT="Enter a value (from 0 to 1000) to determine the ratio of the core to make a memory page.
The lower the value, the longer the information is stored in the RAM and is cached smaller value above 100 facilitates aggressive caching.
For SSD recommend 50 to HDD - 1000."
               MENU_LAPTOPMODE="Laptop mode and activate delayed write"
               MENU_DIRTY_WRITEBACK_CENTISECS="Delayed entry dirty_writeback_centisecs"
               MENU_INFO_DIRTY_WRITEBACK_CENTISECS="Enter a value (from 0 to 60000), to set the delay time of recording (start pdflush) on the hard disk (100 pcs. = 1 second).
For SSD - 6000 (1 minute)"
               MENU_DIRTY_RATIO="Customize dirty_ratio"
               MENU_INFO_DIRTY_RATIO="Enter a value in % (0 to 100) - the proportion of free system memory as a percentage, which reaches the process leading to the disk recording initiates record \"dirty\" data.
For SSD - 60"
               MENU_DIRTY_BACKGROUND_RATIO="Customize dirty_background_ratio"
               MENU_INFO_DIRTY_BACKGROUND_RATIO="Enter a value in % (0 to 100) - the proportion of free memory as a percentage of the total memory of the entire system, which reaches pdflush demon begins to dump their data in the disk cache disk itself.
For SSD - 5"

               MENU_SWAP="Swapping"
               MENU_FILE_SWAP="Swap file"
               MENU_INFO_FILE_SWAP="Enter the swap file size in MB from 0 to"
               MENU_PARTITION_SWAP="Swap partition"
               MENU_ZRAM="Technology ZRAM"
               MENU_ZSWAP="Technology ZSWAP"

               MENU_IDLE3="Parking Timer HDD WD heads"
               MENU_INFO_IDLE3="The value can be an integer from 1 to 255.
The timer is set to 0.1 seconds for the range of 1-128, and 30 seconds for the 129-255 range.
A value of 0 - disables the parking lot.
The script works for /dev/sda"
               MENU_PRELOAD="Sorting Preload"
               MENU_INFO_PRELOAD="0 - No I/O sorting.
Useful on Flash memory for example.
1 - Sort based on file path only.
Useful for network filesystems.
2 -	Sort based on inode number.
Does less house-keeping I/O than the next option.
3 - Sort I/O based on disk block.  Most sophisticated.
And useful for most Linux filesystems."

               MENU_EDIT_FSTAB="Edit /etc/fstab"
               MENU_EDIT_SYSCTLCONF="Edit /etc/sysctl.conf"
               MENU_EDIT_GRUB="Edit /etc/default/grub"

               MENU_MAKE_RULE="Set selection rule scheduler"
               MENU_DEL_RULE="Delete a rule"
               MENU_CHOOSE_SCHEDULE="Choosing the scheduler"
               MAIN_DEV="Select your device:"
               MAIN_SCHE="Select the scheduler:"

               HELP_EXIT="
Press Enter to go to the main menu"
               ATTENTION="ATTENTION!"
               RESTART_TEXT="To apply the settings, restart the PC!

Restart the PC now?"
               POWER_OFF_TEXT="To apply the settings, turn on the PC!

Turn off the PC now?"
               GRUB_TEXT="To apply changes to Grub, you must execute sudo update-grub
               
Update Grub now?"
               HIB_SWAP_TEXT="You want to use this swap during hibernation?"
               AUTOSETTINGS_SSD_TEXT="The following actions will be performed:
- Change mount options /
- Sysctl settings changed
- Preload parameters changed
- Inclusive daily fstrim
- Inclusive mounting /tmp and logs in RAM

Perform these steps?"
               HELP="
____________________________________
   Справка

$0 - скрипт предназначен для настроки таких параметров системы как: журналирование, подкачка, способы хранения временных файлов, монтирование и т.д.
____________________________________
* $MENU_BACKUP - сохраняет/восстанавливает конфиругационые файлы:
  - /etc/fstab
  - /etc/sysctl.conf
  - /etc/default/grub
____________________________________
* $MENU_PARTITION_FORM - Позволяет настроить параметры монтирования разделов в /etc/fstab:
  - $MENU_DISCARD - включить TRIM с помощью параметра discard, нужно быть уверенным, что данный режим поддерживается апаратно и файловой системой
  - $MENU_FSTRIM - включить TRIM по расписанию с помощью fstrim
  - $MENU_BARRIER - позволяет повысить производительность за счет снятия барьера на запись, при этом есть риск нарушения целостности ФС, будьте внимательны - компьютер должен иметь гараниторанное электропитание (подходит для ноутбуков и ПК с UPS)
  - $MENU_COMMIT - установить минутную задержку сброса дискового кэша на сам диск
  - $MENU_NOATIME - не записывать время последнего доступа к файлам (использование данного параметра довольно спорно и не должно приносить существенной пользы, т.к. по умолчанию идет relatime - записывает последнее время, только если файл изменился)
____________________________________
* $MENU_SYSCTL_FORM - Позволяет настроить режимы работы системы, а именно пороги свопирования, установить отложенную записть и пороги сброса грязных страниц памяти.
  - $MENU_SWAPPINESS - установить размер свободной памяти ОЗУ при котором начинается высвобождение ОЗУ и кеширование в swap, т.е. объем свободной памяти при котором будет задействован swap
  - $MENU_SCHED_AUTOGROUP_ENABLED - активирует параметр ядра sched_autogroup_enabled - режим автоматической группировки задач, для повышения интерактивности на десктопе.
  - $MENU_VFS_CACHE_PRESSURECAT - установить уровень выделяемой памяти под кэш. Значение по умолчанию: 100. Увеличение этого параметра заставляет ядро активнее выгружать неиспользуемые страницы памяти из кеша, т.е. количество выделяемой оперативной памяти под кеш будет расти медленнее, что в свою очередь снизит вероятность того, что будет задействован раздел swap. При уменьшении этого параметра ядро, наоборот, будет дольше держать страницы памяти в кеше, в том числе и в swap'е. Это имеет смысл при небольшом количестве ОЗУ, например, если у нас 512 МБ памяти, то параметр vfs_cache_pressure можно выставить равным 50. Это позволит сократить количество дисковых операций в swap разделе, так удаление неиспользуемых страниц будет происходить реже. Дальнейшее уменьшение этого параметра может привести к нехватке памяти.
  - $MENU_LAPTOPMODE - при ключении режима laptopmode ядро будет копить данные, ожидающие записи на диск, и записывать их либо при острой необходимости, либо по истечении таймаута. Таймаут настраивается в dirty_writeback_centisecs
  - $MENU_DIRTY_WRITEBACK_CENTISECS - (default 500): в сотых долях секунд. Этот параметр означает как часто pdflush возобновляет работу для записи данных на диск. По умолчанию возобновляет работу 2 потока каждые 5 секунд.
Возможно недокументированное поведение, которое пресекает попытки уменьшения dirty_writeback_centisecs для более агрессивного кэширования данных процессом pdflush. Например, в ранних версиях ядра 2.6 Linux в файле mm/page-writeback.c код включал логику, которая описывалась \"если запись на диск длится дольше, чем параметр dirty_writeback_centisecs, тогда нужно поставить интервал в 1 секунду\". Эта логика описана только в коде ядра, и ее функционирование зависит от версии ядра Linux. Так как это не очень хорошо, поэтому вы будете защищены от уменьшения этого параметра.
  - $MENU_DIRTY_RATIO - (default 40) - максимальный процент общей оперативной памяти, который может быть выделен под страничный кэш, до того как pdflush будет писать данные на диск.
Второй по значимости параметр для настройки. При значительном снижении этого параметра приложения, которые должны писать на диск, будут блокироваться все вместе.
  - $MENU_DIRTY_BACKGROUND_RATIO - (default 10): Максимальный процент оперативной памяти, который может быть заполнен страничным кэшем до записи данных на диск. Некоторые версии ядра Linux могут этот параметр устанавливать в 5%.
В большинстве документации этот параметр описывается как процент от общей оперативной памяти, но согласно исходным кодам ядра Linux это не так. Глядя на meminfo, параметр dirty_background_ratio расчитывается от величины MemFree + Cached - Mapped. Поэтому для нашей демонстрационной системы 10% составляет немного меньше, чем 250MB, но не 400MB.
Основной инструмент настройки. Обычно уменьшают этот параметр. Если ваша цель снизить количество данных, хранимое в кэше, так что данные будут писаться на диск постепенно, а не все сразу, то уменьшение этого параметра наиболее эффективный путь. Значение по умолчанию наиболее приемлимо для систем имеющих много оперативной памяти и медленные диски.
____________________________________
* $MENU_SWAP_FORM - Позволяет настроить подкачку SWAP в системе
  - $MENU_SWAP - вкл/откл подкачки, при этом также вкл/откл \"Спящий режим\"
  - $MENU_FILE_SWAP - ипользование файла в качестве подкачки
  - $MENU_PARTITION_SWAP - использование раздела жесткого диска в качестве подкачки
  - $MENU_ZRAM - создание в ОЗУ сжатого раздела подкачки SWAP, уменьшает износ HDD и SSD
  - $MENU_ZSWAP - отличается от ZRAM тем, что использует существующий swap-раздел на диске, а в ОЗУ создаётся пул со сжатыми данными (кэшем). После того как пул до отказа забьётся сжатыми данными, он сбросит их в раздел подкачки и снова начнёт принимать и сжимать данные
____________________________________
* $MENU_SCHEDULER_FORM - Позволяет выборать планировщика ввода/вывода на ходу или создать правило выбора планировщика
  - $MENU_MAKE_RULE - Создает правило выбора планировщика для устройств HDD, SSD, USB
  - $MENU_DEL_RULE - Удаляет правило выбора планировщика
  - $MENU_CHOOSE_SCHEDULE - Выбор планировщика ввода/вывода на ходу, выбор сохранится до перезагрузки ПК

    NOOP — наиболее простой планировщик. Он банально помещает все запросы в очередь FIFO и исполняет их вне зависимости от того, пытаются ли приложения читать или писать. Планировщик этот, тем не менее, пытается объединять однотипные запросы для сокращения операций ввода/вывода.
    CFQ - Заключается его алгоритм в следующем. Каждому процессу назначается своя очередь запросов ввода/вывода. Каждой очереди затем присваивается квант времени. Планировщик же циклически обходит все процессы и обслуживает каждый из них, пока не закончится очередь либо не истечет заданный квант времени. Если очередь закончилась раньше, чем истек выделенный для нее квант времени, планировщик подождет (по умолчанию 10 мс) и, в случае напрасного ожидания, перейдет к следующей очереди. Отмечу, что в рамках каждой очереди чтение имеет приоритет над записью.
    Deadline - В основе его работы, как это ясно из названия, лежит предельный срок выполнения — то есть планировщик пытается выполнить запрос в указанное время. В дополнение к обычной отсортированной очереди, которая появилась еще в Linus Elevator, в нем есть еще две очереди — на чтение и на запись. Чтение опять же более приоритетно, чем запись. Кроме того, запросы объединяются в пакеты. Пакетом называется последовательность запросов на чтение либо на запись, которая идет в сторону б?льших секторов («алгоритм лифта»). После его обработки планировщик смотрит, есть ли запросы на запись, которые не обслуживались длительное время, и в зависимости от этого решает, создавать ли пакет на чтение либо же на запись.
____________________________________
* $MENU_OTHER_FORM
  - $MENU_IDLE3 - установить время парковки головок жесткого диска WD и продлить время работы жиска (только для /dev/sda)
  - $MENU_PRELOAD - установить тип сортировки блоков информации для preload
____________________________________
* $MENU_TMP_TO_RAM - Все временные файлы будут храниться в ОЗУ, что повышает быстродействие и уменьшает износ HDD и SSD
Данная технология уже давно применяется в Solaris, Fedora и ArchLinux
Не рекомендуется использовать на ПК с малым объемом ОЗУ
____________________________________
* $MENU_LOG_TO_RAM - Позволяет хранить логи в ОЗУ, уменьшает износ HDD и SSD, однако логи исчезают после перезагрузки ПК
____________________________________
* $MENU_AUTOSETTINGS_SSD - Автоматическое конфигурирование системы (параметров монтирования, свопирования, пределов сброса страниц памяти и т.д.) на работу с SSD
____________________________________"
               ;;

esac

#########################################################

SWAPFILE="/swapfile"

#########################################################
RestartPC ()
{
$DIALOG --title "$ATTENTION" --yesno "$RESTART_TEXT" 10 60
if [ $? == 0 ]
   then sudo reboot
fi
}
#########################################################
PowerOffPC ()
{
$DIALOG --title "$ATTENTION" --yesno "$POWER_OFF_TEXT" 10 60
if [ $? == 0 ]
   then sudo shutdown now
fi
}
#########################################################
UpdateGrub ()
{
$DIALOG --title "$ATTENTION" --yesno "$GRUB_TEXT" 10 60
if [ $? == 0 ]
   then sudo update-grub
fi
}
#########################################################
CheckStateMain ()
{
if [ -f /etc/fstab.backup ]
   then TIME_BACKUP=`date +%F_%T -r /etc/fstab.backup`
        TIME_BACKUP="(recovery-"$TIME_BACKUP")"
   else TIME_BACKUP="(make backup)"
fi

STATE_AUTOMOUNT_TMP=$(cat /etc/fstab | grep "^tmpfs /tmp tmpfs")
if [ "$STATE_AUTOMOUNT_TMP" != '' ]
   then STATE_AUTOMOUNT_TMP="ON"
   else STATE_AUTOMOUNT_TMP="OFF"
fi
STATE_STATUS_TMP=$(mount | grep "/tmp")
if [ "$STATE_STATUS_TMP" != '' ]
   then STATE_STATUS_TMP="ON"
   else STATE_STATUS_TMP="OFF"
fi

STATE_AUTOMOUNT_LOG=$(cat /etc/fstab | grep "^tmpfs /var/")
if [ "$STATE_AUTOMOUNT_LOG" != '' ]
   then STATE_AUTOMOUNT_LOG="ON"
   else STATE_AUTOMOUNT_LOG="OFF"
fi
STATE_STATUS_LOG=$(mount | grep "/var/")
if [ "$STATE_STATUS_LOG" != '' ]
   then STATE_STATUS_LOG="ON"
   else STATE_STATUS_LOG="OFF"
fi
}
#########################################################
CheckStateSwap ()
{
STATE_AUTOMOUNT_SWAP=$(cat /etc/fstab | grep "swap" | sed -e '/\#/d')
if [ "$STATE_AUTOMOUNT_SWAP" != '' ]
   then STATE_AUTOMOUNT_SWAP="ON"
   else STATE_AUTOMOUNT_SWAP="OFF"
fi
STATE_STATUS_SWAP=$(cat /proc/swaps | sed -e '1d')
if [ "$STATE_STATUS_SWAP" != '' ]
   then STATE_STATUS_SWAP="ON"
   else STATE_STATUS_SWAP="OFF"
fi
VALUE_SWAP=$((`free | grep Swap | awk '{print $2}'`/1024))
if [ "$VALUE_SWAP" != '' ]
   then VALUE_SWAP=", size-"$VALUE_SWAP"MB"
fi

if [ -f $SWAPFILE ]
   then STATE_FILE_SWAP="ON"
        VALUE_FILE_SWAP=$((`du $SWAPFILE | awk '{print $1}'`/1024))
        VALUE_FILE_SWAP_TEXT=", size-"$VALUE_FILE_SWAP"MB"
   else STATE_FILE_SWAP="OFF"
        VALUE_FILE_SWAP_TEXT=""
fi

FREE_SPASE_ROOT=$((`df / | sed -e '1d' | awk '{print $4}'`/1024-500))

STATE_PARTITION_SWAP=`cat /proc/swaps | grep partition | grep sd..`
if [ "$STATE_PARTITION_SWAP" != '' ]
   then STATE_PARTITION_SWAP="ON"
        SWAP_PARTITION=`cat /proc/swaps | grep partition | grep sd.. | awk '{print $1}'`
        SWAP_PARTITION_XXX=`echo "$SWAP_PARTITION" | awk  -F"/" '{print $3}'`
        UUID_SWAP_PARTITION=`ls -l /dev/disk/by-uuid | grep $SWAP_PARTITION_XXX | awk '{print $9}'`
        VALUE_SWAP_PARTITION=$((`cat /proc/swaps | grep partition | grep sd.. | awk '{print $3}'`/1024))
        VALUE_PARTITION_SWAP_TEXT=", size-"$VALUE_SWAP_PARTITION"MB"
   else STATE_PARTITION_SWAP="OFF"
fi

STATE_ZRAM=`cat /proc/swaps | grep zram`
if [ "$STATE_ZRAM" != '' ]
   then STATE_ZRAM="ON"
        CPUS=`grep -c processor /proc/cpuinfo`
        VALUE_ZRAM=$((`cat /proc/swaps | grep zram0 | awk '{print $3}'`/1024*$CPUS))
        VALUE_ZRAMP_TEXT=", size-"$VALUE_ZRAM"MB"
   else STATE_ZRAM="OFF"
        VALUE_ZRAMP_TEXT=""
fi

#STATE_ZSWAP=`dmesg | grep zswap`
#if [ "$STATE_ZSWAP" != '' ]
   #then STATE_ZSWAP="ON"
   #else STATE_ZSWAP="OFF"
#fi

if [ $(cat /sys/module/zswap/parameters/enabled) = 'Y' ]
   then STATE_ZSWAP="ON"
   else STATE_ZSWAP="OFF"
fi

STATE_AUTORUN_ZSWAP=`cat /etc/default/grub | grep zswap`
if [ "$STATE_AUTORUN_ZSWAP" != '' ]
   then STATE_AUTORUN_ZSWAP="ON"
   else STATE_AUTORUN_ZSWAP="OFF"
fi
}
#########################################################
CheckStateSysctl ()
{
SWAPPINESS=$(cat /proc/sys/vm/swappiness)

SCHED_AUTOGROUP_ENABLED=$(cat /proc/sys/kernel/sched_autogroup_enabled)
if [ "$SCHED_AUTOGROUP_ENABLED" != '0' ]
   then SCHED_AUTOGROUP_ENABLED="ON"
   else SCHED_AUTOGROUP_ENABLED="OFF"
fi

VFS_CACHE_PRESSURECAT=$(cat /proc/sys/vm/vfs_cache_pressure)

LAPTOP_MODE=$(cat /proc/sys/vm/laptop_mode)
if [ "$LAPTOP_MODE" != '0' ]
   then LAPTOP_MODE="ON"
   else LAPTOP_MODE="OFF"
fi

DIRTY_WRITEBACK_CENTISECS=$(cat /proc/sys/vm/dirty_writeback_centisecs)

DIRTY_RATIO=$(cat /proc/sys/vm/dirty_ratio)

DIRTY_BACKGROUND_RATIO=$(cat /proc/sys/vm/dirty_background_ratio)
}
#########################################################
SysctlForm ()
{
CheckStateSysctl
ANSWER=$($DIALOG  --cancel-button "Back" --title "$MENU_SYSCTL_FORM" --menu \
    "$MAIN_TEXT" 16 64\
    8\
       "$MENU_SWAPPINESS ($SWAPPINESS% free RAM)" ""\
       "$MENU_SCHED_AUTOGROUP_ENABLED (status-$SCHED_AUTOGROUP_ENABLED)" ""\
       "$MENU_VFS_CACHE_PRESSURECAT ($VFS_CACHE_PRESSURECAT filesystem caches)" ""\
       "$MENU_LAPTOPMODE (status-$LAPTOP_MODE)" ""\
       "$MENU_DIRTY_WRITEBACK_CENTISECS ($DIRTY_WRITEBACK_CENTISECS centisecs)" ""\
       "$MENU_DIRTY_RATIO ($DIRTY_RATIO% RAM)" ""\
       "$MENU_DIRTY_BACKGROUND_RATIO ($DIRTY_BACKGROUND_RATIO% RAM)" "" 3>&1 1>&2 2>&3)
if [ $? != 0 ]
   then MainForm
fi
case $ANSWER in
   "$MENU_SWAPPINESS"* )
                  while true; do
                     SWAPPINESS=$($DIALOG --title "$MENU_SWAPPINESS" --inputbox "$MENU_INFO_SWAPPINESS" 14 60 $SWAPPINESS 3>&1 1>&2 2>&3)
                     if [ $? != 0 ]
                        then SysctlForm ; break
                     fi

                     if [[ "$SWAPPINESS" -ge 0 ]] && [[ "$SWAPPINESS" -le 100 ]]
                        then break
                     fi
                  done

                  sudo sed -i '/^vm.swappiness/d' /etc/sysctl.conf
                  echo -e "vm.swappiness=$SWAPPINESS" | sudo tee -a /etc/sysctl.conf
                  ;;
   "$MENU_SCHED_AUTOGROUP_ENABLED"* )
                  if [ "$SCHED_AUTOGROUP_ENABLED" = "OFF" ]
                    then sudo sed -i '/^kernel.sched_autogroup_enabled/d' /etc/sysctl.conf
                         echo -e "kernel.sched_autogroup_enabled=1" | sudo tee -a /etc/sysctl.conf
                    else
                         sudo sed -i '/^kernel.sched_autogroup_enabled/d' /etc/sysctl.conf
                         echo -e "kernel.sched_autogroup_enabled=0" | sudo tee -a /etc/sysctl.conf
                  fi
                  ;;
   "$MENU_VFS_CACHE_PRESSURECAT"* )
                  while true; do
                     VFS_CACHE_PRESSURECAT=$($DIALOG --title "$MENU_VFS_CACHE_PRESSURECAT" --inputbox "$MENU_INFO_VFS_CACHE_PRESSURECAT" 14 60 $VFS_CACHE_PRESSURECAT 3>&1 1>&2 2>&3)
                     if [ $? != 0 ]
                        then SysctlForm ; break
                     fi

                     if [[ "$VFS_CACHE_PRESSURECAT" -ge 0 ]] && [[ "$VFS_CACHE_PRESSURECAT" -le 1000 ]]
                        then break
                     fi
                  done

                  sudo sed -i '/^vm.vfs_cache_pressure/d' /etc/sysctl.conf
                  echo -e "vm.vfs_cache_pressure=$VFS_CACHE_PRESSURECAT" | sudo tee -a /etc/sysctl.conf
                  ;;
   "$MENU_LAPTOPMODE"* )
                  if [ "$LAPTOP_MODE" = "OFF" ]
                    then
                         sudo sed -i '/^vm.laptop_mode/d' /etc/sysctl.conf
                         echo -e "vm.laptop_mode=5" | sudo tee -a /etc/sysctl.conf
                    else
                         sudo sed -i '/^vm.laptop_mode/d' /etc/sysctl.conf
                         echo -e "vm.laptop_mode=0" | sudo tee -a /etc/sysctl.conf
                  fi
                  ;;
   "$MENU_DIRTY_WRITEBACK_CENTISECS"* )
                  while true; do
                     DIRTY_WRITEBACK_CENTISECS=$($DIALOG --title "$MENU_DIRTY_WRITEBACK_CENTISECS" --inputbox "$MENU_INFO_DIRTY_WRITEBACK_CENTISECS" 14 60 $DIRTY_WRITEBACK_CENTISECS 3>&1 1>&2 2>&3)
                     if [ $? != 0 ]
                        then SysctlForm ; break
                     fi

                     if [[ "$DIRTY_WRITEBACK_CENTISECS" -ge 0 ]] && [[ "$DIRTY_WRITEBACK_CENTISECS" -le 60000 ]]
                        then break
                     fi
                  done

                  sudo sed -i '/^vm.dirty_writeback_centisecs/d' /etc/sysctl.conf
                  echo -e "vm.dirty_writeback_centisecs=$DIRTY_WRITEBACK_CENTISECS" | sudo tee -a /etc/sysctl.conf
                  ;;
   "$MENU_DIRTY_RATIO"* )
                  while true; do
                     DIRTY_RATIO=$($DIALOG --title "$MENU_DIRTY_RATIO" --inputbox "$MENU_INFO_DIRTY_RATIO" 14 60 $DIRTY_RATIO 3>&1 1>&2 2>&3)
                     if [ $? != 0 ]
                        then SysctlForm ; break
                     fi

                     if [[ "$DIRTY_RATIO" -ge 0 ]] && [[ "$DIRTY_RATIO" -le 100 ]]
                        then break
                     fi
                  done

                  sudo sed -i '/^vm.dirty_ratio/d' /etc/sysctl.conf
                  echo -e "vm.dirty_ratio=$DIRTY_RATIO" | sudo tee -a /etc/sysctl.conf
                  ;;
   "$MENU_DIRTY_BACKGROUND_RATIO"* )
                  while true; do
                     DIRTY_BACKGROUND_RATIO=$($DIALOG --title "$MENU_DIRTY_BACKGROUND_RATIO" --inputbox "$MENU_INFO_DIRTY_BACKGROUND_RATIO" 14 60 $DIRTY_BACKGROUND_RATIO 3>&1 1>&2 2>&3)
                     if [ $? != 0 ]
                        then SysctlForm ; break
                     fi

                     if [[ "$DIRTY_BACKGROUND_RATIO" -ge 0 ]] && [[ "$DIRTY_BACKGROUND_RATIO" -le 100 ]]
                        then break
                     fi
                  done

                  sudo sed -i '/^vm.dirty_background_ratio/d' /etc/sysctl.conf
                  echo -e "vm.dirty_background_ratio=$DIRTY_BACKGROUND_RATIO" | sudo tee -a /etc/sysctl.conf
                  ;;
esac

sudo sync
sudo sysctl -p

SysctlForm
}
#########################################################
SwapForm ()
{
CheckStateSwap
ANSWER=$($DIALOG  --cancel-button "Back" --title "$MENU_SWAP_FORM" --menu \
    "$MAIN_TEXT" 16 64\
    8\
       "$MENU_SWAP (automount-$STATE_AUTOMOUNT_SWAP, status-$STATE_STATUS_SWAP$VALUE_SWAP)" ""\
       "$MENU_FILE_SWAP (present-$STATE_FILE_SWAP$VALUE_FILE_SWAP_TEXT)" ""\
       "$MENU_PARTITION_SWAP (status-$STATE_PARTITION_SWAP$VALUE_PARTITION_SWAP_TEXT)" ""\
       "$MENU_ZRAM (status-$STATE_ZRAM$VALUE_ZRAMP_TEXT)" ""\
       "$MENU_ZSWAP (status-$STATE_ZSWAP, autorun-$STATE_AUTORUN_ZSWAP)" "" 3>&1 1>&2 2>&3)
if [ $? != 0 ]
   then MainForm
fi
case $ANSWER in
   "$MENU_SWAP"* ) if [ "$STATE_AUTOMOUNT_SWAP" = "OFF" ]
                      then sudo sed -i '/swap/s/\#//g' /etc/fstab
                      else sudo sed -i '/swap/s/^/\#/g' /etc/fstab
                   fi

                   if [ "$STATE_STATUS_SWAP" = "OFF" ]
                      then sudo swapon -a
                           sudo rm /etc/polkit-1/localauthority/90-mandatory.d/disable-hibernate.pkla
                      else sudo swapoff -a
                           echo -e "[Disable hibernate (upower)]
Identity=unix-user:*
Action=org.freedesktop.upower.hibernate
ResultActive=no
ResultInactive=no
ResultAny=no

[Disable hibernate (logind)]
Identity=unix-user:*
Action=org.freedesktop.login1.hibernate
ResultActive=no

[Disable hibernate for all sessions (logind)]
Identity=unix-user:*
Action=org.freedesktop.login1.hibernate-multiple-sessions
ResultActive=no" | sudo tee /etc/polkit-1/localauthority/90-mandatory.d/disable-hibernate.pkla
                   fi
                  ;;
   "$MENU_FILE_SWAP"* )
                  if [ "$STATE_FILE_SWAP" = "OFF" ]
                      then
                           while true; do
                                 VALUE_FILE_SWAP=$($DIALOG --title "$MENU_FILE_SWAP" --inputbox "$MENU_INFO_FILE_SWAP $FREE_SPASE_ROOT" 14 60 $VALUE_FILE_SWAP 3>&1 1>&2 2>&3)
                                 if [ $? != 0 ]
                                    then SwapForm ; break
                                 fi

                                 if [[ "$VALUE_FILE_SWAP" -ge 0 ]] && [[ "$VALUE_FILE_SWAP" -le "$FREE_SPASE_ROOT" ]]
                                     then break
                                 fi
                           done
                           sudo touch $SWAPFILE
                           sudo chmod 0600 $SWAPFILE
                           echo "Please wait for the swap file is created..."
                           sudo dd if=/dev/zero of=$SWAPFILE bs=1024k count=$VALUE_FILE_SWAP
                           sudo mkswap $SWAPFILE
                           echo -e "#Mount $SWAPFILE \n$SWAPFILE   none    swap    sw    0    0" | sudo tee -a /etc/fstab
                           sudo swapon $SWAPFILE

                           $DIALOG --title "$ATTENTION" --yesno "$HIB_SWAP_TEXT" 10 60
                           if [ $? == 0 ]
                               then
                                    UUID_FILE_SWAP=`sudo swaplabel $SWAPFILE | awk '{print $2}'`
                                    RESUME_OFFSET=`sudo filefrag -v $SWAPFILE | grep -P " 0:" | awk '{print $4}' | sed "s/\.//g"`
                                    echo -e "resume=UUID=$UUID_FILE_SWAP resume_offset=$RESUME_OFFSET" | sudo tee /etc/initramfs-tools/conf.d/resume
                                    sudo update-initramfs -u
                                    FOR_GRUB=`cat /etc/initramfs-tools/conf.d/resume`
                                    AddParmToGrub "$FOR_GRUB"
                                    sudo update-grub
                                    sudo rm /etc/polkit-1/localauthority/90-mandatory.d/disable-hibernate.pkla
                           fi
                      else
                           sudo swapoff $SWAPFILE
                           sudo rm -f $SWAPFILE
                           sudo sed -i '/swapfile/d' /etc/fstab
                           sudo swapon -a
                           FOR_GRUB=`cat /etc/initramfs-tools/conf.d/resume`
                           if [ "$(cat /etc/default/grub | grep resume)" != '' ]
                              then RmParmFromGrub "$FOR_GRUB"
                                   sudo update-grub
                           fi
                   fi
                  ;;
   "$MENU_PARTITION_SWAP"* )
                  if [ "$STATE_PARTITION_SWAP" = "OFF" ]
                      then
                           SWAP_PARTITIONS=`sudo lsblk -f -l | grep swap | awk '{print $1" "$2}'`
                           SWAP_PARTITION=$($DIALOG  --cancel-button "Back" --title "$MENU_PARTITION_SWAP" --menu \
                           "$MAIN_PART" 16 60 8 $SWAP_PARTITIONS 3>&1 1>&2 2>&3)
                           if [ $? != 0 ]
                               then echo "Cancel or not found a swap partition"
                                    SwapForm
                           fi

                           UUID_SWAP_PARTITION=`ls -l /dev/disk/by-uuid | grep $SWAP_PARTITION | awk '{print $9}'`
                           echo "$UUID_SWAP_PARTITION"
                           if [[ `cat /etc/fstab | grep $UUID_SWAP_PARTITION` ]]
                               then sudo sed -i '/swap/s/\#//g' /etc/fstab
                               else echo -e "#Mount $SWAP_PARTITION \nUUID=$UUID_SWAP_PARTITION	swap	swap	sw	0	0" | sudo tee -a /etc/fstab
                           fi
                           sudo swapon -a
                           $DIALOG --title "$ATTENTION" --yesno "$HIB_SWAP_TEXT" 10 60
                           if [ $? == 0 ]
                               then
                                    FOR_GRUB=`cat /etc/initramfs-tools/conf.d/resume`
                                    if [ "$(cat /etc/default/grub | grep resume)" != '' ]
                                       then RmParmFromGrub "$FOR_GRUB"
                                            sudo update-grub
                                    fi
                                    echo -e "RESUME=$(grep swap /etc/fstab| awk '{ print $1 }')" | sudo tee /etc/initramfs-tools/conf.d/resume
                                    sudo update-initramfs -u
                                    sudo rm /etc/polkit-1/localauthority/90-mandatory.d/disable-hibernate.pkla

                           fi
                      else
                           sudo sed -i "/${UUID_SWAP_PARTITION}/d" /etc/fstab
                           sudo sed -i "/ ${SWAP_PARTITION_XXX}/d" /etc/fstab
                           sudo swapoff -U $UUID_SWAP_PARTITION
                  fi
                  ;;
   "$MENU_ZRAM"* )
                  if [ "$STATE_ZRAM" = "OFF" ]
                     then echo '#!/bin/sh
### BEGIN INIT INFO
# Provides:          zram
# Required-Start:    $local_fs
# Required-Stop:     $local_fs
# Default-Start:     S
# Default-Stop:      0 1 6
# Short-Description: Use compressed RAM as in-memory swap
# Description:       Use compressed RAM as in-memory swap
### END INIT INFO

# Author: Antonio Galea <antonio.galea@gmail.com>
# Thanks to Przemysław Tomczyk for suggesting swapoff parallelization

FRACTION=25

MEMORY=$((`cat /proc/meminfo | grep ^MemTotal: | sed -e "s/[^0-9]//g"`* 1024))
CPUS=`grep -c processor /proc/cpuinfo`
SIZE=$(( MEMORY * FRACTION / 100 / CPUS ))

case "$1" in
  "start")
    param=`modinfo zram|grep num_devices|cut -f2 -d:|tr -d " "`
    modprobe zram $param=$CPUS
    for n in `seq $CPUS`; do
      i=$((n - 1))
      echo $SIZE > /sys/block/zram$i/disksize
      mkswap /dev/zram$i
      swapon /dev/zram$i -p 10
    done
    ;;
  "stop")
    for n in `seq $CPUS`; do
      i=$((n - 1))
      swapoff /dev/zram$i && echo "disabled disk $n of $CPUS" &
    done
    wait
    sleep 2
    modprobe -r zram
    ;;
  *)
    echo "Usage: `basename $0` (start | stop)"
    exit 1
    ;;
esac' | sudo tee /etc/init.d/zram
                          sudo chmod +x /etc/init.d/zram
                          echo '[Unit]
Description=Manage swap spaces on zram.
After=local-fs.target
RequiresMountsFor=/
RequiresMountsFor=/sys
RequiresMountsFor=/var

[Service]
RemainAfterExit=yes
ExecStart=/etc/init.d/zram start
ExecStop=/etc/init.d/zram stop
TimeoutStopSec=600
Nice=-19
OOMScoreAdjust=-1000
CPUAccounting=true
CPUQuota=5%
MemoryHigh=16M
MemoryMax=64M
ProtectHome=true

[Install]
WantedBy=local-fs.target' | sudo tee /etc/systemd/system/systemd-zram.service
                          sudo systemctl enable systemd-zram || sudo insserv zram
                          sudo systemctl start systemd-zram || sudo /etc/init.d/zram start
                     else
                          sudo systemctl stop systemd-zram || sudo /etc/init.d/zram stop
                          sudo systemctl disable systemd-zram || sudo insserv -r zram
                          sudo rm -f /etc/systemd/system/systemd-zram.service
                          sudo rm -f /etc/init.d/zram
                  fi
                  sleep 1
                  ;;
   "$MENU_ZSWAP"* )
                  if [ "$STATE_ZSWAP" = "OFF" ]
                     then echo 1 | sudo tee /sys/module/zswap/parameters/enabled
                     else echo 0 | sudo tee /sys/module/zswap/parameters/enabled
                  fi
                  if [ "$STATE_AUTORUN_ZSWAP" = "OFF" ]
                     then AddParmToGrub "zswap.enabled=1"
                          sudo update-grub
                          #RestartPC
                     else RmParmFromGrub "zswap.enabled=1"
                          sudo update-grub
                          #RestartPC
                  fi
                  ;;
esac

SwapForm
}
########################################################
CheckStateOther ()
{
STATE_IDLE3_TOOLS=`dpkg -l | grep idle3-tools`
if [ "$STATE_IDLE3_TOOLS" = '' ]
   then STATE_IDLE3_TOOLS="idle3-tools is not installed"
   else STATE_IDLE3_TOOLS=`sudo idle3ctl -g103 /dev/sda | awk '{print $5}'`
        if [ "$STATE_IDLE3_TOOLS" = '' ]
           then STATE_IDLE3_TOOLS=`sudo idle3ctl -g103 /dev/sda`
        fi
fi

SETTING_PRELOAD_SORTSTRATEGY=`cat /etc/preload.conf | grep ^sortstrategy | awk '{print $NF }'|sed "s/=//g"`
}
########################################################
OtherForm ()
{
CheckStateOther
ANSWER=$($DIALOG  --cancel-button "Back" --title "$MENU_OTHER_FORM" --menu \
    "$MAIN_TEXT" 16 70\
    8\
       "$MENU_IDLE3 (state-$STATE_IDLE3_TOOLS)" ""\
       "$MENU_PRELOAD (setting-$SETTING_PRELOAD_SORTSTRATEGY)" "" 3>&1 1>&2 2>&3)
if [ $? != 0 ]
   then MainForm
fi
case $ANSWER in
   "$MENU_IDLE3"* )
                  if [ "$STATE_IDLE3_TOOLS" != "idle3-tools is not installed" ]
                      then
                           while true; do
                                IDLE3=`sudo idle3ctl -g /dev/sda | awk '{print $5}'`
                                IDLE3=$($DIALOG --title "$MENU_IDLE3" --inputbox "$MENU_INFO_IDLE3" 14 60 $IDLE3 3>&1 1>&2 2>&3)
                                if [ $? != 0 ]
                                   then OtherForm ; break
                                fi

                                if [[ "$IDLE3" -ge 0 ]] && [[ "$IDLE3" -le 255 ]]
                                   then break
                                fi
                           done
                           if [ $IDLE3 = 0 ]
                              then sudo idle3ctl -d /dev/sda
                              else sudo idle3ctl -s$IDLE3 /dev/sda
                           fi
                           PowerOffPC
                      else echo Please install idle3-tools !
                           sleep 1
                  fi
                  ;;
   "$MENU_PRELOAD"* )
                  while true; do
                     SETTING_PRELOAD_SORTSTRATEGY=$($DIALOG --title "$MENU_PRELOAD" --inputbox "$MENU_INFO_PRELOAD" 18 60 $SETTING_PRELOAD_SORTSTRATEGY 3>&1 1>&2 2>&3)
                     if [ $? != 0 ]
                        then OtherForm ; break
                     fi

                     if [[ "$SETTING_PRELOAD_SORTSTRATEGY" -ge 0 ]] && [[ "$SETTING_PRELOAD_SORTSTRATEGY" -le 3 ]]
                        then break
                     fi
                  done
                  sudo sed -i '/^sortstrategy/d' /etc/preload.conf
                  echo -e "sortstrategy = $SETTING_PRELOAD_SORTSTRATEGY" | sudo tee -a /etc/preload.conf
                  sudo /etc/init.d/preload restart
                  ;;
esac

OtherForm
}
#########################################################
CheckStatePartition ()
{
MOUNT_POINT=$(cat /etc/fstab | grep "$PARTITION" | awk '{print $2" "}')

if [[ `echo $PARTITION | grep "^UUID"` ]]
   then
        UUID=`echo "$PARTITION" | sed s/UUID=//g`
        DISK="/dev/"`ls -l /dev/disk/by-uuid | grep $UUID | awk '{print $NF }' | sed s/[./0-9]//g`
   else
        DISK=`echo "$PARTITION" | sed s/[0-9]//g`
fi

MOUNT_DISCARD=$(cat /etc/fstab | grep $PARTITION | grep discard)
if [ "$MOUNT_DISCARD" != "" ]
   then MOUNT_DISCARD="ON"
   else MOUNT_DISCARD="OFF"
fi
STATE_DISCARD=$(mount | grep $MOUNT_POINT | grep discard)
if [ "$STATE_DISCARD" != '' ]
   then STATE_DISCARD="ON"
   else STATE_DISCARD="OFF"
fi

CRON_TRIM="n"
STATE_CRON_TRIM="OFF"

if [[ `cat /etc/cron.daily/trim | grep " $MOUNT_POINT"` ]]
   then CRON_TRIM="d"
        STATE_CRON_TRIM="ON"
fi

if [[ `cat /etc/cron.weekly/trim | grep " $MOUNT_POINT"` ]]
   then CRON_TRIM="w"
        STATE_CRON_TRIM="ON"
fi

if [[ `cat /etc/cron.monthly/trim | grep " $MOUNT_POINT"` ]]
   then CRON_TRIM="m"
        STATE_CRON_TRIM="ON"
fi

MOUNT_BARRIER=$(cat /etc/fstab | grep $PARTITION | grep barrier)
if [ "$MOUNT_BARRIER" != "" ]
   then MOUNT_BARRIER="ON"
   else MOUNT_BARRIER="OFF"
fi
STATE_BARRIER=$(mount | grep $MOUNT_POINT | grep barrier)
if [ "$STATE_BARRIER" != '' ]
   then STATE_BARRIER="ON"
   else STATE_BARRIER="OFF"
fi

MOUNT_COMMIT=$(cat /etc/fstab | grep $PARTITION | grep commit)
if [ "$MOUNT_COMMIT" != "" ]
   then MOUNT_COMMIT="ON"
   else MOUNT_COMMIT="OFF"
fi
STATE_COMMIT=$(mount | grep $MOUNT_POINT | grep commit)
if [ "$STATE_COMMIT" != '' ]
   then STATE_COMMIT="ON"
   else STATE_COMMIT="OFF"
fi

MOUNT_NOATIME=$(cat /etc/fstab | grep $PARTITION | grep noatime)
if [ "$MOUNT_NOATIME" != "" ]
   then MOUNT_NOATIME="ON"
   else MOUNT_NOATIME="OFF"
fi
STATE_NOATIME=$(mount | grep $MOUNT_POINT | grep noatime)
if [ "$STATE_NOATIME" != '' ]
   then STATE_NOATIME="ON"
   else STATE_NOATIME="OFF"
fi
}
#########################################################
AddParmToFstab ()
{
PARM=$1","
DATA=`cat /etc/fstab | grep $PARTITION`
NEW_DATA=`echo $DATA | awk -v v1=$PARM '{print $1" "$2" "$3" "v1$4" "$5" "$6}' | sed "s/ /\t/g"`
sudo sed -i "s|${DATA}|${NEW_DATA}|g" /etc/fstab
}
#########################################################
RmParmFromFstab ()
{
PARM=$1","
DATA=`cat /etc/fstab | grep $PARTITION`
NEW_DATA=`echo $DATA | sed "s/${PARM}//g" | sed "s/ /\t/g"`
sudo sed -i "s|${DATA}|${NEW_DATA}|g" /etc/fstab
}
#########################################################
AddParmToGrub ()
{
PARM="$1"
DATA=`cat /etc/default/grub | grep GRUB_CMDLINE_LINUX_DEFAULT`
NEW_DATA=`echo "$DATA" | sed "s/\"//g" | awk -F= -v v1="$PARM" '{print $1"=\""v1" " $2"\""}'`
sudo sed -i "s|${DATA}|${NEW_DATA}|g" /etc/default/grub
}
#########################################################
RmParmFromGrub ()
{
PARM="$1"
DATA=`cat /etc/default/grub | grep GRUB_CMDLINE_LINUX_DEFAULT`
NEW_DATA=`echo "$DATA" | sed "s/${PARM} //g"`
sudo sed -i "s|${DATA}|${NEW_DATA}|g" /etc/default/grub
}
#########################################################
PartitionForm ()
{
CheckStatePartition
ANSWER=$($DIALOG  --cancel-button "Back" --title "$PARTITION" --menu \
    "$MAIN_TEXT" 16 60\
    8\
       "$MENU_DISCARD (mount-$MOUNT_DISCARD, state-$STATE_DISCARD) " ""\
       "$MENU_FSTRIM (state-$STATE_CRON_TRIM, cron-$CRON_TRIM)" ""\
       "$MENU_BARRIER (mount-$MOUNT_BARRIER, state-$STATE_BARRIER)" ""\
       "$MENU_COMMIT (mount-$MOUNT_COMMIT, state-$STATE_COMMIT)" ""\
       "$MENU_NOATIME (mount-$MOUNT_NOATIME, state-$STATE_NOATIME)" "" 3>&1 1>&2 2>&3)
if [ $? != 0 ]
   then MainForm
fi

case $ANSWER in
   "$MENU_DISCARD"* )
                    SUPPORTED_TRIM=`sudo hdparm -I $DISK | grep "TRIM supported"`
                    if [[ $SUPPORTED_TRIM == '' ]]
                       then echo "TRIM is NOT supported by hard disk - $DISK !"
                       else echo "TRIM is supported by hard disk - $DISK"
                    fi

                    OPTION="discard"
                    if [ "$MOUNT_DISCARD" = "OFF" ] && [[ $SUPPORTED_TRIM != '' ]]
                        then AddParmToFstab $OPTION
                        else RmParmFromFstab $OPTION
                    fi
                    sudo mount -o remount $MOUNT_POINT
                    ;;
   "$MENU_FSTRIM"* )
                    while true; do
                      CRON_TRIM=$($DIALOG --title "$MENU_FSTRIM" --inputbox "$MENU_INFO_FSTRIM" 16 60 $CRON_TRIM 3>&1 1>&2 2>&3)
                      if [ $? != 0 ]
                         then PartitionForm ; break
                      fi
                      MOUNT_POINT_RESP=`echo $MOUNT_POINT | sed 's|/|\\\/|g'`
                      case $CRON_TRIM in
                          "n" ) sudo sed -i "/ ${MOUNT_POINT_RESP}/d" /etc/cron.daily/trim
                                sudo sed -i "/ ${MOUNT_POINT_RESP}/d" /etc/cron.weekly/trim
                                sudo sed -i "/ ${MOUNT_POINT_RESP}/d" /etc/cron.monthly/trim
                                break
                                ;;
                          "d" ) if [ ! -f /etc/cron.daily/trim ]
                                   then echo -e "#\x21/bin/sh\\nfstrim -v $MOUNT_POINT" | sudo tee /etc/cron.daily/trim
                                        sudo chmod +x /etc/cron.daily/trim
                                   else sudo sed -i "/ ${MOUNT_POINT_RESP}/d" /etc/cron.daily/trim
                                        echo -e "fstrim -v $MOUNT_POINT" | sudo tee -a /etc/cron.daily/trim
                                fi
                                break
                                ;;
                          "w" ) if [ ! -f /etc/cron.weekly/trim ]
                                   then echo -e "#\x21/bin/sh\\nfstrim -v $MOUNT_POINT" | sudo tee /etc/cron.weekly/trim
                                        sudo chmod +x /etc/cron.weekly/trim
                                   else sudo sed -i "/ ${MOUNT_POINT_RESP}/d" /etc/cron.weekly/trim
                                        echo -e "fstrim -v $MOUNT_POINT" | sudo tee -a /etc/cron.weekly/trim
                                fi
                                break
                                ;;
                          "m" ) if [ ! -f /etc/cron.monthly/trim ]
                                   then echo -e "#\x21/bin/sh\\nfstrim -v $MOUNT_POINT" | sudo tee /etc/cron.monthly/trim
                                        sudo chmod +x /etc/cron.monthly/trim
                                   else sudo sed -i "/ ${MOUNT_POINT_RESP}/d" /etc/cron.monthly/trim
                                        echo -e "fstrim -v $MOUNT_POINT" | sudo tee -a /etc/cron.monthly/trim
                                fi
                                break
                                ;;
                      esac
                    done
                    ;;
   "$MENU_BARRIER"* )
                    OPTION="barrier=0"
                    if [ "$MOUNT_BARRIER" = "OFF" ]
                        then AddParmToFstab $OPTION
                        else RmParmFromFstab $OPTION
                    fi
                    sudo mount -o remount $MOUNT_POINT
                    ;;
   "$MENU_COMMIT"* )
                    OPTION="commit=600"
                    if [ "$MOUNT_COMMIT" = "OFF" ]
                        then AddParmToFstab $OPTION
                        else RmParmFromFstab $OPTION
                    fi
                    sudo mount -o remount $MOUNT_POINT
                    ;;
   "$MENU_NOATIME"* )
                    OPTION="noatime"
                    if [ "$MOUNT_NOATIME" = "OFF" ]
                        then AddParmToFstab $OPTION
                        else RmParmFromFstab $OPTION
                    fi
                    sudo mount -o remount $MOUNT_POINT
                    ;;
esac

PartitionForm
}
#########################################################
MountForm ()
{
MOUNT_PARTITIONS=`cat /etc/fstab | grep ^UUID | awk '{print $1" "$2 }'`
MOUNT_PARTITIONS=$MOUNT_PARTITIONS" "`cat /etc/fstab | grep ^/dev | awk '{print $1" "$2 }'`

PARTITION=$($DIALOG  --cancel-button "Back" --title "$MENU_PARTITION_FORM" --menu \
    "$MAIN_PART" 16 60 8 $MOUNT_PARTITIONS  3>&1 1>&2 2>&3)
if [ $? != 0 ]
   then MainForm
fi

PartitionForm
}
#########################################################
RuleScheForm ()
{
if ! [ -f /etc/udev/rules.d/60-schedulers.rules ]; then
echo -e "# HDD
ACTION==\"add|change\", KERNEL==\"sd[a-z]\", ATTR{queue/rotational}==\"1\", ATTR{queue/scheduler}=\"cfq\"
# SSD
ACTION==\"add|change\", KERNEL==\"sd[a-z]\", ATTR{queue/rotational}==\"0\", ATTR{queue/scheduler}=\"deadline\"
# USB
SUBSYSTEMS==\"usb\", ACTION==\"add|change\", KERNEL==\"sd?\", RUN+=\"/bin/sh -c 'echo deadline > /sys/block/%k/queue/scheduler'\"" | sudo tee -a /etc/udev/rules.d/60-schedulers.rules
fi

HDD_SCHE=`cat /etc/udev/rules.d/60-schedulers.rules | grep ATTR\{queue\/rotational\}==\"1\"| sed 's/\"//g' | awk -F= '{print $NF}'`
if [ -z ${HDD_SCHE// /} ]
 then HDD_SCHE='-'
fi

SSD_SCHE=`cat /etc/udev/rules.d/60-schedulers.rules | grep ATTR\{queue\/rotational\}==\"0\"| sed 's/\"//g' | awk -F= '{print $NF}'`
if [ -z ${SSD_SCHE// /} ]
 then SSD_SCHE='-'
fi

USB_SCHE=`cat /etc/udev/rules.d/60-schedulers.rules | grep usb | grep RUN | awk -F">" '{print $1}'| awk '{print $NF}'`
if [ -z ${USB_SCHE/ /} ]
 then USB_SCHE='-'
fi

RULE_LIST="HDD "$HDD_SCHE" SSD "$SSD_SCHE" USB "$USB_SCHE
RULE=$($DIALOG  --cancel-button "Back" --title "$MENU_MAKE_RULE" --menu \
    "$MAIN_DEV" 16 60 8 $RULE_LIST 3>&1 1>&2 2>&3)
if [ $? != 0 ]
   then SchedulerForm
fi

SCHEDULERS="cfq . deadline . noop ."

SCHEDULER=$($DIALOG  --cancel-button "Back" --title "$DEV" --menu \
    "$MAIN_SCHE" 16 60 8 $SCHEDULERS 3>&1 1>&2 2>&3)
if [ $? != 0 ]
   then RuleScheForm
fi

case $RULE in
   HDD) sudo sed -i '/HDD/d' /etc/udev/rules.d/60-schedulers.rules
        sudo sed -i '/rotational\}=="1"/d' /etc/udev/rules.d/60-schedulers.rules
        echo -e "# HDD
ACTION==\"add|change\", KERNEL==\"sd[a-z]\", ATTR{queue/rotational}==\"1\", ATTR{queue/scheduler}=\"$SCHEDULER\"" | sudo tee -a /etc/udev/rules.d/60-schedulers.rules
        ;;
   SSD) sudo sed -i '/SSD/d' /etc/udev/rules.d/60-schedulers.rules
        sudo sed -i '/rotational\}=="0"/d' /etc/udev/rules.d/60-schedulers.rules
        echo -e "# SSD
ACTION==\"add|change\", KERNEL==\"sd[a-z]\", ATTR{queue/rotational}==\"0\", ATTR{queue/scheduler}=\"$SCHEDULER\"" | sudo tee -a /etc/udev/rules.d/60-schedulers.rules
        ;;
   USB) sudo sed -i '/USB/d' /etc/udev/rules.d/60-schedulers.rules
        sudo sed -i '/RUN/d' /etc/udev/rules.d/60-schedulers.rules
        echo -e "# USB
SUBSYSTEMS==\"usb\", ACTION==\"add|change\", KERNEL==\"sd?\", RUN+=\"/bin/sh -c 'echo $SCHEDULER > /sys/block/%k/queue/scheduler'\"" | sudo tee -a /etc/udev/rules.d/60-schedulers.rules
        ;;
esac

RuleScheForm
}
#########################################################
DevForm ()
{
DEV_LIST=""
for i in $(lsblk -d | grep sd. | awk '{print $1"_"$3"_"$4"_"$6 }'); do
   SCHEDULER_DEV=`cat /sys/block/$(echo $i | awk -F"_" '{ print $1 }')/queue/scheduler | cut -d"[" -f2 | cut -d"]" -f1`
   DEV_LIST=$DEV_LIST" "$i" "$SCHEDULER_DEV
done

DEV=$($DIALOG  --cancel-button "Back" --title "$MENU_CHOOSE_SCHEDULE" --menu \
    "$MAIN_DEV" 16 60 8 $DEV_LIST 3>&1 1>&2 2>&3)
if [ $? != 0 ]
   then SchedulerForm
fi

SCHEDULERS=`cat /sys/block/$(echo $DEV | awk -F"_" '{ print $1 }')/queue/scheduler | sed 's/\[//g' | sed 's/\]//g' | sed "s/ / . /g"`

SCHEDULER=$($DIALOG  --cancel-button "Back" --title "$DEV" --menu \
    "$MAIN_SCHE" 16 60 8 $SCHEDULERS 3>&1 1>&2 2>&3)
if [ $? != 0 ]
   then DevForm
fi

echo -e "$SCHEDULER" | sudo tee -a /sys/block/$(echo $DEV | awk -F"_" '{ print $1 }')/queue/scheduler

DevForm
}
#########################################################
SchedulerForm ()
{
ANSWER=$($DIALOG  --cancel-button "Back" --title "$MENU_SCHEDULER_FORM" --menu \
    "$MAIN_TEXT" 20 60\
    4\
       "$MENU_MAKE_RULE" ""\
       "$MENU_DEL_RULE" ""\
       "$MENU_CHOOSE_SCHEDULE" "" 3>&1 1>&2 2>&3)
if [ $? != 0 ]
   then MainForm
fi
case $ANSWER in
   "$MENU_MAKE_RULE" )
              RuleScheForm
              ;;
   "$MENU_DEL_RULE" )
              sudo rm /etc/udev/rules.d/60-schedulers.rules
              ;;
   "$MENU_CHOOSE_SCHEDULE" )
              DevForm
              ;;
esac

SchedulerForm
}
#########################################################
EditForm ()
{
ANSWER=$($DIALOG  --cancel-button "Back" --title "$MENU_EDIT_CONF" --menu \
    "$MAIN_TEXT" 20 60\
    4\
       "$MENU_EDIT_FSTAB" ""\
       "$MENU_EDIT_SYSCTLCONF" ""\
       "$MENU_EDIT_GRUB" "" 3>&1 1>&2 2>&3)
if [ $? != 0 ]
   then MainForm
fi
case $ANSWER in
   "$MENU_EDIT_CONF" )
              EditForm
              ;;
   "$MENU_EDIT_FSTAB" )
              sudo $EDITOR /etc/fstab
              ;;
   "$MENU_EDIT_SYSCTLCONF" )
              sudo $EDITOR /etc/sysctl.conf
              ;;
   "$MENU_EDIT_GRUB")
              sudo $EDITOR /etc/default/grub
              UpdateGrub
              ;;
esac

EditForm
}
#########################################################
MainForm ()
{
CheckStateMain
ANSWER=$($DIALOG  --cancel-button "Exit" --title "$MAIN_LABEL" --menu \
    "$MAIN_TEXT" 20 60\
    12\
       "$MENU_BACKUP $TIME_BACKUP" ""\
       "$MENU_PARTITION_FORM" ""\
       "$MENU_SYSCTL_FORM" ""\
       "$MENU_SWAP_FORM" ""\
       "$MENU_SCHEDULER_FORM" ""\
       "$MENU_OTHER_FORM" ""\
       "$MENU_TMP_TO_RAM (automount-$STATE_AUTOMOUNT_TMP, status-$STATE_STATUS_TMP)" ""\
       "$MENU_LOG_TO_RAM (automount-$STATE_AUTOMOUNT_LOG, status-$STATE_STATUS_LOG)" ""\
       "$MENU_AUTOSETTINGS_SSD" ""\
       "$MENU_EDIT_CONF" ""\
       "$MENU_HELP" "" 3>&1 1>&2 2>&3)
if [ $? != 0 ]
   then echo Exit ; exit 0
fi
case $ANSWER in
   "$MENU_PARTITION_FORM" )
              MountForm
              ;;
   "$MENU_SYSCTL_FORM" )
              SysctlForm
              ;;
   "$MENU_SWAP_FORM" )
              SwapForm
              ;;
   "$MENU_SCHEDULER_FORM" )
              SchedulerForm
              ;;
   "$MENU_OTHER_FORM" )
              OtherForm
              ;;
   "$MENU_TMP_TO_RAM"* )
              if [ "$STATE_AUTOMOUNT_TMP" = "OFF" ]
                 then echo -e "#Mount /tmp to RAM ( /tmp tmpfs) \ntmpfs /tmp tmpfs rw,nosuid,nodev 0 0" | sudo tee -a /etc/fstab
                 else sudo sed -i '/ \/tmp tmpfs/d' /etc/fstab
              fi
              RestartPC
              ;;
   "$MENU_LOG_TO_RAM"* )
              if [ "$STATE_AUTOMOUNT_LOG" = "OFF" ]
                 then echo -e "#Mount /var/* to RAM
tmpfs /var/tmp tmpfs defaults 0 0
tmpfs /var/lock tmpfs defaults 0 0
#tmpfs /var/log tmpfs defaults,size=20M 0 0
tmpfs /var/spool/postfix tmpfs defaults 0 0" | sudo tee -a /etc/fstab
                 else sudo sed -i '/\/var\//d' /etc/fstab
              fi
              RestartPC
              ;;
   "$MENU_AUTOSETTINGS_SSD" )
              $DIALOG --title "$ATTENTION" --yesno "$AUTOSETTINGS_SSD_TEXT" 16 60
              if [ $? == 0 ]
                 then
                      # setup mount /
                      PARTITION=`cat /etc/fstab | grep -P "\t/\t" | awk '{print $1}'`
                      if [ "$PARTITION"='' ]
                         then ARTITION=`cat /etc/fstab | grep -P " / " | awk '{print $1}'`
                      fi
                      OPTION="barrier=0,commit=600,noatime"
                      AddParmToFstab $OPTION
                      sudo mount -o remount /

                      # setup sysctl
                      sudo sed -i '/^vm./d' /etc/sysctl.conf
                      echo -e "vm.swappiness=0
vm.vfs_cache_pressure=50
vm.laptop_mode=5
vm.dirty_writeback_centisecs=6000
vm.dirty_ratio=60
vm.dirty_background_ratio=5" | sudo tee -a /etc/sysctl.conf
                      sudo sync
                      sudo sysctl -p

                      # logs and tmp to RAM
                      sudo sed -i '/ \/tmp tmpfs/d' /etc/fstab
                      sudo sed -i '/\/var\//d' /etc/fstab
                      echo -e "#Mount /tmp to RAM ( /tmp tmpfs) \ntmpfs /tmp tmpfs rw,nosuid,nodev 0 0" | sudo tee -a /etc/fstab
                      echo -e "#Mount /var/* to RAM
tmpfs /var/tmp tmpfs defaults 0 0
tmpfs /var/lock tmpfs defaults 0 0
#tmpfs /var/log tmpfs defaults,size=20M 0 0
tmpfs /var/spool/postfix tmpfs defaults 0 0" | sudo tee -a /etc/fstab

                      # setup preload sortstrategy
                      sudo sed -i '/^sortstrategy/d' /etc/preload.conf
                      echo -e "sortstrategy = 0" | sudo tee -a /etc/preload.conf
                      sudo /etc/init.d/preload restart

                      #setup auto fstrim
                      echo -e "#\x21/bin/sh\\nfstrim -v / " | sudo tee /etc/cron.daily/trim
                      sudo chmod +x /etc/cron.daily/trim

                      RestartPC
              fi
              ;;
   "$MENU_BACKUP"* )
              if [ "$TIME_BACKUP" == "(make backup)" ]
                 then
                      sudo cp /etc/fstab  /etc/fstab.backup
                      sudo cp /etc/sysctl.conf /etc/sysctl.conf.backup
                      sudo cp /etc/default/grub /etc/default/grub.backup
                 else
                      sudo mv /etc/fstab.backup /etc/fstab
                      sudo mv /etc/sysctl.conf.backup /etc/sysctl.conf
                      DIFF_GRUB=`diff /etc/default/grub.backup /etc/default/grub`
                      echo diff $DIFF_GRUB
                      if [ "$DIFF_GRUB" != '' ]
                          then sudo mv /etc/default/grub.backup /etc/default/grub
                               sudo update-grub
                      fi
                      sudo rm /etc/cron.daily/trim
                      sudo rm /etc/cron.weekly/trim
                      sudo rm /etc/cron.monthly/trim

                      RestartPC
              fi
              ;;
   "$MENU_EDIT_CONF" )
              EditForm
              ;;
   "$MENU_HELP" )
              echo "$HELP"
              echo "$HELP_EXIT"
              read x
              ;;
esac

MainForm
}
#########################################################

MainForm

exit 0
