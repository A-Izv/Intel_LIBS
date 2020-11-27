#ifndef IPPCUSTOM_H
#define IPPCUSTOM_H
//------------------------------------------------------------------------------
#include <QDebug>
//------------------------------------------------------------------------------
// подключаем заголовочные файлы из IPP
#include <ippcore.h>
#include <ipps.h>
#include <ippvm.h>
//------------------------------------------------------------------------------
#define IPP_CUSTOM_ERR 0x7FFFFFFF // константа для обозначения ошибки не-IPP
//------------------------------------------------------------------------------
// чтобы не плодить строки - объявляем строковые константы
extern const QString IPP_CUSTOM_MSG;
extern const QString IPP_CUSTOM_IPP;
extern const QString IPP_CUSTOM_UNKNOWN;
//------------------------------------------------------------------------------
#define CHK( x )\
{\
    IppStatus __stts;\
    try {\
        __stts = x;   /*выполняем переданное выражение и сохраняем результат*/\
    }\
    catch(...) {\
        __stts = IppStatus(IPP_CUSTOM_ERR);    /*произошла неизвестная ошибка*/\
    }\
    if(Q_UNLIKELY( __stts != ippStsNoErr )) {\
        /*формируем сообщение по шаблону*/\
        QString errStr = IPP_CUSTOM_MSG.\
                             arg(__FILE__).     /*подставляем имя файла*/\
                             arg(__LINE__).     /*подставляем номер строки*/\
                             arg(__stts != IppStatus(IPP_CUSTOM_ERR) ?\
                                           IPP_CUSTOM_IPP.arg(ippGetStatusString(__stts))\
                                           :\
                                           IPP_CUSTOM_UNKNOWN\
                             );\
        qCritical() << errStr;\
        /*/throw(errStr);/*/\
    }\
}
//------------------------------------------------------------------------------
#endif
