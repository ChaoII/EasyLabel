#pragma once
#include <QObject>
#include <QQmlEngine>

class QmlUtilsCpp : public QObject
{
    Q_OBJECT
    QML_SINGLETON
    QML_ELEMENT

public:

    Q_INVOKABLE QString now() const;

    explicit QmlUtilsCpp(QObject *parent = nullptr) ;

signals:
};

