#!/usr/bin/env bash
# язык на который осуществяется перевод, например: 
# uk-українська, ru-русский, be-беларуска, en-english
LNG="ru"

text="$(xsel -o)"

answer="$(wget -U "Mozilla/5.0" -qO - "http://translate.googleapis.com/translate_a/single?client=gtx&sl=auto&tl=$LNG&dt=t&q=\
$(echo $text | sed "s/[\"'<>#]//g")")"

translate="$(echo "$answer" | awk -F"null,\"" '{print $1}' \
| awk -F".[[,]\"" '{ i=2; while (i<=NF) {print $i ; i=i+2}}' | awk -F",null" '{print $1}')"


#тест ответа сервера-переводчика, файл с запросом и ответом
echo "$text" > ~/test.txt
echo "++++++++++++++++++++++" >> ~/test.txt
echo "$answer" >> ~/test.txt


# сохранить перевод в буфер обмена
echo "$translate" | xclip -selection clipboard

# вывести во всплывающем сообщении
#notify-send -t 10000 --icon=info "$text" "$translate"
notify-send -t 10000 --icon=info "$translate"

# вывести в окне
#echo -e "$text\n ################### \n$translate" | zenity --text-info --title="Translation" 

exit 0



