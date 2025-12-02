#include <QFontDatabase>
#include <QGuiApplication>
#include <QIcon>
#include <QtGui/QFontDatabase>
#include <QQmlApplicationEngine>
#include "HuskarUI/husapp.h"

int main(int argc, char* argv[]) {
    QGuiApplication app(argc, argv);
    app.setWindowIcon(QIcon(":/resources/images/logo.svg"));
    QQmlApplicationEngine engine;
    const QUrl url(QStringLiteral("qrc:/EasyLabel/qml/Main.qml"));
    QFontDatabase::addApplicationFont(":/resources/fonts/remixicon.ttf");
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreated,
        &app,
        [url](QObject* obj, const QUrl& objUrl) {
            if (!obj && url == objUrl)
                QCoreApplication::exit(-1);
        }, Qt::QueuedConnection);
    engine.load(url);
    HusApp::initialize(&engine);
    return app.exec();
}
