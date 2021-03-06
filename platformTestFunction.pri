#----------------------------------------------------------------------------------------
# Функция возвращает одно из значений:
#       minGW32 - если компилятор определен как 32-х битный MinGW
#       minGW64 - если компилятор определен как 64-х битный MinGW
#       other   - если определить не удалось
#----------------------------------------------------------------------------------------
# Никаких гарантий работоспособности и обязательств. 31/07/2019
#----------------------------------------------------------------------------------------
defineReplace(platformTest) {
    RESULT = other  # результат по умолчанию - 'other'
    win32{  # условие - выполняется только если платформа windows (для Qt 5.12.4 выполняется и для Windows32, и для Windows64)
        VAR = $$system(set PATH)    # получаем значение системной переменной PATH (выполняем 'set PATH')

        VAR = $$split( VAR, ;)      # разбиваем полученную строку по символу ';'
        VAR = $$find(  VAR, mingw ) # ищем элементы списка, содержащие подстроку 'mingw'
        VAR = $$first( VAR )        # получаем первый из найденных элементов (например, 'Path=C:\Qt\Qt5.12.4\Tools\mingw730_64\bin')

        VAR = $$split( VAR, \\)     # разбиваем полученную строку по символу '\'
        VAR = $$find(  VAR, mingw ) # ищем элементы списка, содержащие подстроку 'mingw'
        VAR = $$first( VAR )        # получаем первый из найденных элементов (например, 'mingw730_64')

        TMP = $$find(  VAR, 32 )    # проверяем наличие подстроки '32'
        !isEmpty( TMP ) {           # если результат не пустой, то...
            RESULT = minGW32            # возвращаемое значение  -  minGW32
        } else {                    # иначе
            TMP = $$find( VAR, 64 )     # проверяем наличие подстроки '64'
            !isEmpty( TMP ) {           # если результат не пустой, то...
                RESULT = minGW64            # возвращаемое значение  -  minGW64
            }
        }
        #message($$VAR)  # отладочный вывод
    }
    return($$RESULT)    # возвращаем результат
}
#----------------------------------------------------------------------------------------
