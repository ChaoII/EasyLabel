#pragma once

#include <QObject>
#include <QThread>
#include <QVector>
#include <QPair>
#include <QString>
#include <algorithm>
#include <random>

class ExportWorker : public QObject {
    Q_OBJECT

public:
    explicit ExportWorker(QObject *parent = nullptr);

public slots:
    void startExport(const QString &exportDir,
                     const QString &imageDir,
                     const QString &resultDir,
                     int annotationType,
                     int exportType,
                     double trainSplitRate,
                     const QString& templateFile="");

signals:
    void exportProgress(double progress);  // 进度信号
    void exportFinished();
    void exportError(const QString &error);

private:
    bool exportToDirectory(const QString &exportDir,
                           const QString &imageDir,
                           const QString &resultDir,
                           int annotationType,
                           int exportType,
                           double trainSplitRate,
                           const QString &templateFile);

    template<typename T>
    void shuffleQVector(QVector<T> &vector) {
        std::random_device rd;
        std::mt19937 g(rd());
        std::shuffle(vector.begin(), vector.end(), g);
    }
};

