@rem Ќикаких гарантий работоспособности и об€зательств. 02/03/2018
@rem
@echo off
    rem создаем локальные переменные, содержащие „»—Ћј
    setlocal enabledelayedexpansion
    set /A COPY_CNT = 0
    set /A SKIP_CNT = 0
    set RESULT=

    rem провер€ем существование директории с исходными файлами
    IF NOT EXIST "%~1\*.*" (
        set RESULT=%RESULT% directory %~1 doesn't exist 
        goto :end
    )
    rem провер€ем существование директории назначени€
    IF NOT EXIST "%~2\*.*" (
        md "%~2"
        if ERRORLEVEL 1 goto :errorCOPY

        set RESULT=%RESULT% destination directory has been created and
    )

    rem переходим в каталог с исходными файлами
    cd /D "%~1"

    rem перебираем все файлы в каталоге
    FOR   %%j IN ("*.*") DO (

        rem если в каталоге назначени€ файл отсутствует, то копируем его 
        IF NOT EXIST "%~2\%%j" (
            rem команда копировани€ с автоматическим подтверждением перезаписи и выводом сообщений в устройство NUL (т.е. в никуда)
            copy /Y "%~1\%%j" "%~2\%%j" > NUL

            rem при ошибке завершаем работу
            if ERRORLEVEL 1 goto :errorCOPY

            set /A COPY_CNT+=1
        ) ELSE (
            set /A SKIP_CNT+=1
        )
    )

    rem выводим сообщение о числе скопированных и пропущенных файлов
    IF %COPY_CNT% EQU 0 (
        set RESULT=%RESULT% nothing to copy,
    ) ELSE (
        IF %COPY_CNT% EQU 1 (
            set RESULT=%RESULT% 1 file has been copied,
        ) ELSE (
            set RESULT=%RESULT% !COPY_CNT! files have been copied,
        )
    )


    IF %SKIP_CNT% EQU 0 (
        set RESULT=%RESULT% nothing to skip
    ) ELSE (
        IF %SKIP_CNT% EQU 1 (
            set RESULT=%RESULT% 1 file has been skipped
        ) ELSE (
            set RESULT=%RESULT% !SKIP_CNT! files have been skipped
        )
    )

    goto :end

:errorCOPY
    set RESULT=%RESULT% an error occured 
    goto :end

:end
    echo %RESULT%

