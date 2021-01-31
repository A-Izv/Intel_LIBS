//------------------------------------------------------------------------------
#include "ippCustom.h"
#include <QDebug>
#include <mutex>
//------------------------------------------------------------------------------
namespace ippCustom {
//------------------------------------------------------------------------------
#ifdef IPP_CHK_WITH_EXCEPTIONS
    #define IPP_CHK_ERR_REACTION    \
        QtIppChkException e(m); /*/создаем объект исключения/*/\
        e.raise();              /*/вызываем исключение/*/
#else
    #define IPP_CHK_ERR_REACTION /*/пустышка/*/
#endif
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
std::string CHKlastMessage;     // сохраняемое сообщение об ошибке
std::mutex  CHKMutex;           // мьютекс для корректной многопоточной обработки
//------------------------------------------------------------------------------
bool isOk() {
    CHKMutex.lock();
    bool result = CHKlastMessage.empty();
    CHKMutex.unlock();

    return result;
}
//------------------------------------------------------------------------------
std::string lastMessage() {
    CHKMutex.lock();
    std::string result = CHKlastMessage;
    CHKMutex.unlock();

    return result;
}
//------------------------------------------------------------------------------
void prepare()
{
    CHKMutex.lock();
    CHKlastMessage.clear();
    CHKMutex.unlock();
}
//------------------------------------------------------------------------------
void doOnError( IppStatus stts, const char *file, int line )
{
 // формируем сообщение
    std::string m;
    m += "In file '";
    m += file;
    m += "' on line ";
    m += std::to_string(line);
    m += " occured an ";
    if( stts != IppStatus(IPP_CUSTOM_ERR) ) {
        m += "IPP error: '";
        m += ippGetStatusString(stts);
        m += "'";
    } else {
        m += "unknown error.";
    }

 // запоминаем сообщение
    CHKMutex.lock();
    CHKlastMessage = m;
    CHKMutex.unlock();
 // выводим в поток отладки
    qDebug() << m.c_str();
 // (возможно) вызываем исключение
    IPP_CHK_ERR_REACTION;
}
//------------------------------------------------------------------------------
} /* namespace ippCustom */
