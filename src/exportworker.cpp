#include "ExportWorker.h"
#include "DetectionAnnotationModel.h"
#include "filelistmodel.h"
#include "labellistmodel.h"
#include "rotatedBoxAnnotationmodel.h"
#include "segmentationAnnotationmodel.h"
#include "keyPointAnnotationmodel.h"
#include <QDebug>
#include <QDir>

ExportWorker::ExportWorker(QObject *parent) : QObject(parent) {}

void ExportWorker::startExport(const QString &exportDir,
                               const QString &imageDir,
                               const QString &resultDir, int annotationType,
                               int exportType, double trainSplitRate,
                               const QString& templateFile) {
    try {
        bool success =
            exportToDirectory(exportDir, imageDir, resultDir, annotationType,
                                         exportType, trainSplitRate,templateFile);
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
                                     double trainSplitRate,
                                     const QString &templateFile) {

    FileListModel fileListModel(this);
    LabelListModel LabelListModel(this);
    // todo deal memory
    std::unique_ptr<AnnotationModelBase> annotationModel = nullptr;
    if (annotationType == 0) {
        annotationModel = std::make_unique<DetectionAnnotationModel>(this);
    } else if (annotationType == 1) {
        annotationModel = std::make_unique<RotatedBoxAnnotationModel>(this);
    } else if (annotationType == 2) {
        annotationModel = std::make_unique<SegmentationAnnotationModel>(this);
    } else if (annotationType == 3) {
        annotationModel = std::make_unique<KeyPointAnnotationModel>(this);
    } else {
        qFatal() << "unsupported annotationType " << annotationType;
        return false;
    }
    connect(annotationModel.get(), &AnnotationModelBase::exportProgress, this,
            &ExportWorker::exportProgress);
    // 数据集划分
    QVector<QPair<QString, QString>> dataSets;
    fileListModel.setFolderPath(imageDir);
    LabelListModel.loadFromFile(QDir(resultDir).absoluteFilePath("label.json"));
    auto labels = LabelListModel.toLabelList();
    int totalImages = fileListModel.rowCount();
    for (int index = 0; index < totalImages; index++) {
        const QString annotationFilePath = fileListModel.getResultFilePath(index);
        const QString annotationFullPath =
            QDir(resultDir).absoluteFilePath(annotationFilePath);
        auto imageFullPath = fileListModel.getFullPath(index);
        dataSets.append({imageFullPath, annotationFullPath});
    }
    shuffleQVector(dataSets);
    return annotationModel->exportAnotation(exportDir, dataSets, exportType,
                                            trainSplitRate, labels);
}
