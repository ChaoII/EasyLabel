#include "qmlutilscpp.h"
#include <QDateTime>

QmlUtilsCpp::QmlUtilsCpp(QObject *parent)
    : QObject{parent}
{

}

QString QmlUtilsCpp::now() const{
    return  QDateTime::currentDateTime().toString("yyyy-MM-ddTHH:mm:ss.zzz");
}
