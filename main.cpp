#include <QGuiApplication>
#include <QIcon>
#include <QQmlApplicationEngine>
#include "husapp.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    app.setWindowIcon(QIcon(":/images/logo.svg"));
    QQmlApplicationEngine engine;
    const QUrl url(QStringLiteral("qrc:/EasyLabel/Main.qml"));
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreated,
        &app,
        [url](QObject *obj, const QUrl &objUrl) {
            if (!obj && url == objUrl)
                QCoreApplication::exit(-1);
        },
        Qt::QueuedConnection);
    engine.load(url);
    HusApp::initialize(&engine);
    return app.exec();
}
