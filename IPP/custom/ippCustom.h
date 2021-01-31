#ifndef IPPCUSTOM_H
#define IPPCUSTOM_H
//------------------------------------------------------------------------------
//  В файле описан макрос для проверки результатов работы функций IPP,
//  кроме того подключаются заголовочные файлы ippcore.h, ipps.h и ippvm.h
//
//  Главным определением является макрос CHK().
//  Обернутые им функции IPP в случае ошибки выводят в поток отладки подробные сообщения о неполадках,
//  а также имя файла и номер строки, содержащие код вызвавший ошибку.
//
//  Если в свойствах проекта определено IPP_CHK_WITH_EXCEPTIONS, то кроме вывода сообщения,
//  будет вызвано исключение (тип исключение - наследник QException, вызов иключения по значению).
//      для qmake : DEFINES += IPP_CHK_WITH_EXCEPTIONS
//
//  Если в свойствах проекта определено NO_IPP_DEBUG, то никакой обработки ошибок не будет.
//
//  ПРИМЕР:
//      try {
//          ...
//          CHK( ippsCopy_8u(...) );
//          ..
//      }
//      catch( const QException &e ) {
//          DoOnError( e.what() );
//      }
//      catch(...) {
//          DoOnError( ippCustom::lastMessage() );
//      }
//  Текст последней ошибки можно получить с помощью функции
//      ippCustom::lastMessage();
//  Закончилась ли последний вызов ошибкой можно проверить с помощью функции
//      ippCustom::isOk();
//------------------------------------------------------------------------------
#ifdef NO_IPP_DEBUG
    #define CHK( x ) x;
#else
    //--------------------------------------------------------------------------
    #include <string>
    #include <QException>
    // подключаем заголовочные файлы из IPP
    #include <ippcore.h>
    #include <ipps.h>
    #include <ippvm.h>
    //--------------------------------------------------------------------------
    // функции для проверки последней ошибки
    namespace ippCustom {
        std::string lastMessage();
        bool        isOk();
    }
    //--------------------------------------------------------------------------
    #ifdef IPP_CHK_WITH_EXCEPTIONS
        // Определение класса исключения для корректной передачи исключений
        // между потоками в QtConcurrent.
        class QtIppChkException : public QException {
        private:
            std::string message;
        public:
                        QtIppChkException( const QtIppChkException &e ) { this->message = e.message;       }
                        QtIppChkException( const QString &m )           { this->message = m.toStdString(); }
                        QtIppChkException( const std::string &m )       { this->message = m;               }
                        QtIppChkException( const char *m )              { this->message = std::string(m);  }

            const char* what()  const noexcept override { return message.c_str();              }    // std::exception interface
            void        raise() const          override { throw *this;                         }    // QException interface
            QException* clone() const          override { return new QtIppChkException(*this); }    // QException interface
        };
    #endif // IPP_CHK_WITH_EXCEPTIONS
    //--------------------------------------------------------------------------
    // служебные функции макроса
    namespace ippCustom {
        void prepare();
        void doOnError( IppStatus stts, const char *file, int line );
    }
    //--------------------------------------------------------------------------
    #define IPP_CUSTOM_ERR 0x7FFFFFFF // константа для обозначения ошибки не-IPP
    //--------------------------------------------------------------------------
    #define CHK( x )\
    {\
        IppStatus __stts;\
        ippCustom::prepare(); /*подготовка к работе*/\
        try { __stts = x; }   /*выполняем переданное выражение и сохраняем результат*/\
        catch(...) {\
            __stts = IppStatus(IPP_CUSTOM_ERR);    /*произошла неизвестная ошибка*/\
        }\
        if(Q_UNLIKELY( __stts != ippStsNoErr )) {\
            ippCustom::doOnError( __stts, __FILE__, __LINE__ ); /*формирование сообщения об ошибке*/\
        }\
    }
    //--------------------------------------------------------------------------
#endif  //NO_IPP_DEBUG
//------------------------------------------------------------------------------
#endif  //IPPCUSTOM_H
