#include "ExportWorker.h"
#include "filelistmodel.h"
#include "DetectionAnnotationModel.h"
#include <QDebug>
#include <QDir>

ExportWorker::ExportWorker(QObject *parent) : QObject(parent) {}

void ExportWorker::startExport(const QString &exportDir,
                               const QString &imageDir,
                               const QString &resultDir, int annotationType,
                               int exportType, double trainSplitRate) {
    try {
        bool success =
            exportToDirectory(exportDir, imageDir, resultDir, annotationType,
                                         exportType, trainSplitRate);
        if (success) {
            emit exportFinished();
        } else {
            emit exportError("导出失败");
        }
    } catch (const std::exception &e) {
        emit exportError(QString("导出异常: %1").arg(e.what()));
    }
}

bool ExportWorker::exportToDirectory(const QString &exportDir,
                                     const QString &imageDir,
                                     const QString &resultDir,
                                     int annotationType, int exportType,
                                     double trainSplitRate) {
    FileListModel fileListModel(this);
    DetectionAnnotationModel annotationModel(this);
    connect(&annotationModel, &DetectionAnnotationModel::exportProgress, this,
            &ExportWorker::exportProgress);
    // 数据集划分
    QVector<QPair<QString, QString>> dataSets;
    fileListModel.setFolderPath(imageDir);
    int totalImages = fileListModel.rowCount();
    for (int index = 0; index < totalImages; index++) {
        const QString annotationFilePath = fileListModel.getResultFilePath(index);
        const QString annotationFullPath =
            QDir(resultDir).absoluteFilePath(annotationFilePath);
        auto imageFullPath = fileListModel.getFullPath(index);
        dataSets.append({imageFullPath, annotationFullPath});
    }
    shuffleQVector(dataSets);
    return annotationModel.exportAnotation(exportDir, dataSets, exportType,
                                            trainSplitRate);
}
