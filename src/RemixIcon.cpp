#include "RemixIcon.h"
#include <QGuiApplication>
#include <QFontDatabase>

// 自动生成时间: 2025-10-30 01:01:56

RemixIcon *RemixIcon::instance()
{
    static RemixIcon *instance = new RemixIcon;
    return instance;
}

RemixIcon *RemixIcon::create(QQmlEngine *qmlEngine, QJSEngine *jsEngine)
{
    Q_UNUSED(qmlEngine)
    Q_UNUSED(jsEngine)
    return instance();
}

QVariantMap RemixIcon::allIconNames()
{
    QVariantMap iconMap;
    QMetaEnum me = QMetaEnum::fromType<RemixIcon::Type>();
    for (int i = 0; i < me.keyCount(); i++) {
        iconMap[QString::fromLatin1(me.key(i))] = me.value(i);
    }

    return iconMap;
}

RemixIcon::RemixIcon(QObject *parent)
    : QObject(parent)
{

}

RemixIcon::~RemixIcon()
{
}

