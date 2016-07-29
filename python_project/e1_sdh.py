#!/usr/bin/python3

error_message = '''
!!!!!!!!
Введены неверные данные!
help - для получения справки
exit - для выхода
!!!!!!!!
'''

help_text='''
********
Номер потока Е1 - целое число от 1 до 63,
Адрес в структуре STM - a.b.c, где a,b,c - цифры (1<=a<=3, 1<=b<=7, 1<=c<=3)
или x.a.b.c, где x - номер STM-1 (1<=x<=4)
возможен ввод адреса без точек: abc или xabc
********
'''

def virt_v_e1(list_arg):
    return ((int(list_arg[0]) - 1) * 21 + (int(list_arg[1]) - 1) * 3 + int(list_arg[2]))


def e1_v_virt(arg):
    list_arg = []
    list_arg.append(str(int((arg - 1) / 21) + 1))
    list_arg.append(str(int((arg - 1) % 21 / 3) + 1))
    list_arg.append(str(int((arg - 1) % 21 % 3) + 1))
    return '.'.join(list_arg)


while True:
    arg = input("Введите номер потока или его адрес:")
    if '.' in arg:
        list_arg = arg.split('.')
        try:
            if len(list_arg) == 3 and 1 <= int(list_arg[0]) <= 3 and 1 <= int(list_arg[1]) <= 7 \
                    and 1 <= int(list_arg[2]) <= 3:
                print('Поток №', virt_v_e1(list_arg))
            elif len(list_arg) == 4 and 1 <= int(list_arg[0]) <= 4 and 1 <= int(list_arg[1]) <= 3 \
                    and 1 <= int(list_arg[2]) <= 7 and 1 <= int(list_arg[3]) <= 3:
                print('STM-1 №', list_arg[0])
                del list_arg[0]
                print('Поток №', virt_v_e1(list_arg))
            else:
                print(error_message)
        except ValueError:
            print(error_message)
    elif arg == 'exit':
        break
    elif arg == 'help':
        print(help_text)
    elif len(arg) == 3:
        list_arg = list(arg)
        try:
            if 1 <= int(list_arg[0]) <= 3 and 1 <= int(list_arg[1]) <= 7 and 1 <= int(list_arg[2]) <= 3:
                print('Поток №', virt_v_e1(list_arg))
            else:
                print(error_message)
        except ValueError:
            print(error_message)
    elif len(arg) == 4:
        list_arg = list(arg)
        try:
            if 1 <= int(list_arg[0]) <= 4 and 1 <= int(list_arg[1]) <= 3 and 1 <= int(list_arg[2]) <= 7 \
                    and 1 <= int(list_arg[3]) <= 3:
                print('STM-1 №', list_arg[0])
                del list_arg[0]
                print('Поток №', virt_v_e1(list_arg))
            else:
                print(error_message)
        except ValueError:
            print(error_message)
    else:
        try:
            arg = int(arg)
            if 1 <= arg <= 63:
                print('Адрес -', e1_v_virt(arg))
            else:
                print(error_message)
        except ValueError:
            print(error_message)
