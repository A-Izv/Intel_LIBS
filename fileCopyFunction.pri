#----------------------------------------------------------------------------------------
# Функция копирует все файлы, расположенные в каталоге,
# переданном в первом параметре, к предполагаемому месту расположения
# скомпилированного исполняемого файла.
# Второй параметр используется только как префикс при выводе сообщений.
#
# Например:
#
#    binPath = c:/Library/bin                       # задаем путь до файлов библиотеки
#
#    include(fileCopyFunction.pri)                  # подключаем этот файл
#    copyFilesToExeFolder( $$binPath, myLibrary )   # копируем
#
# Все содержимое каталога, имя которого сохранено в переменной $$binPath
# (без подкаталогов) будет скопированно
# в директорию к скомпилированному EXE-файлу.
# Также в поток основных сообщений будет выведена информация
# в формате "myLibrary : <текст сообщения>"
#!!! Для правильной работы функции рядом с этим файлом должен находится
#!!! скрипт копирования  <smartCopy.bat>.
#!!! Скрипт копирует только отсутствующие файлы.
#----------------------------------------------------------------------------------------
# Никаких гарантий работоспособности и обязательств. 25/04/2018
#----------------------------------------------------------------------------------------
defineTest(copyFilesToExeFolder) {
    binPath = $$1   # сохраняем первый аргумент функции
    libName = $$2   # сохраняем второй аргумент функции

    # копируем DLL к месту расположения исполняемого файла
    CONFIG( build_pass ) {   # защита от лишних вызовов
        ELEMENT_COUNT = $$split(OUT_PWD, /)     # разбиваем путь на элементы по символу '/'
        ELEMENT_COUNT = $$size(ELEMENT_COUNT)   # получаем число элементов в сформированном списке

        greaterThan(ELEMENT_COUNT, 0) { # защита от вызова с пустым путем назначения (его размер почему-то не воспринимается как нулевой, ф-я isEmpty тоже не отрабатывает)
         # подготовка переменных
            DLL_SRC = $$binPath         # исходный каталог с DLL
            CPY_CMD = smartCopy.bat     # скрипт, выполняющий копирование (только отсутствующих файлов)

            # анализ переменной CONFIG не дает правильных результатов, анализируем путь назначения
            OUT     = $$split(OUT_PWD,-)    # разделяем путь назначения на элементы по символу '-'
            OUT     = $$lower($$last(OUT))  # получаем последний элемент пути, он, обычно, debug или release - это нам и надо

            # если вдруг последний элемент не debug/release, то такой формат пути нам не знаком - лучше уж ничего не сделать
            equals(OUT, "debug") {
                libName = $$libName : debug build
                DLL_DST = $$OUT_PWD/debug           # формируем путь для копирования файлов
            } else {
                equals(OUT, "release") {
                    libName = $$libName : release build
                    DLL_DST = $$OUT_PWD/release     # формируем путь для копирования файлов
                } else {
                    equals(OUT, "profile") {
                        libName = $$libName : profile build
                        DLL_DST = $$OUT_PWD/release # формируем путь для копирования файлов
                    } else {
                        message($$libName : +++ wrong path structure = do nothing)
                        DLL_DST =   # обнуляем переменную DLL_DST т.к. OUT не равен debug/release
                    }
                }
            }
         # выполняем внешний скрипт
            isEmpty( DLL_DST ) {
                message($$libName : +++ destination dir name is empty ---)
            } else {
                # преобразуем разделители на обратный слэш и заключаем в кавычки
                CPY_CMD =                $$system_path($$CPY_CMD)
                DLL_SRC = $$system_quote($$system_path($$DLL_SRC))
                DLL_DST = $$system_quote($$system_path($$DLL_DST))

                # смена текущей директории
                DIR_CHNG_CMD     = cd /D $$system_quote($$system_path($$PWD))   # команда перехода в диреторию со скриптом копирования (текущую)
                DIR_CHNG_CMD_OUT = $$system($$DIR_CHNG_CMD)                     # выполняем команду и сохраняем ее вывод
                #message($$libName : dir change command is $$DIR_CHNG_CMD)
                #message($$libName : dir change : $$DIR_CHNG_CMD_OUT)           # отображаем вывод исполненной команды

                # команда копирования
                CPY_CMD = $$CPY_CMD $$DLL_SRC $$DLL_DST                         # команда копирования (только отсутствующих файлов)
                CPY_CMD_OUT = $$system($$CPY_CMD)                               # выполняем команду и сохраняем ее вывод
                #message($$libName : dir copy command is $$CPY_CMD)
                message($$libName : $$CPY_CMD_OUT)                              # отображаем вывод исполненной команды

                #вывод сообщений в лог (не каждое выполнение отрабатывает message, ~ половина работает "тихо")
                #LOG_CMD = $$system(echo $$system_quote(-------------------------------------)  >> log.txt )
                #LOG_CMD = $$system(echo $$system_quote($$libName : config=$$CONFIG)            >> log.txt )
                #LOG_CMD = $$system(echo $$system_quote($$libName : outPWD=$$OUT_PWD)           >> log.txt )
                #LOG_CMD = $$system(echo $$system_quote($$libName : cpyCMD=$$CPY_CMD)           >> log.txt )
            }
        } else {
            message($$libName : +++ destination dir name is empty)
        }
    }
}
#----------------------------------------------------------------------------------------
