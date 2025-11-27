#include "annotationmodelbase.h"
#include <QDir>
AnnotationModelBase::AnnotationModelBase(QObject *parent)
    : QAbstractListModel{parent}
{}

bool AnnotationModelBase::generateYamlConfig(const QString& filename, const DatasetConfig& config) {
    QFile file(filename);
    if (!file.open(QIODevice::WriteOnly | QIODevice::Text)) {
        return false;
    }

    QTextStream out(&file);

    out << "path: " << config.path << " # dataset root dir\n";
    out << "train: " << config.trainPath << " # train images (relative to 'path')\n";
    out << "val: " << config.valPath << " # val images (relative to 'path')\n";
    out << "test: " << config.testPath << " # test images (optional)\n";
    out << "\n";
    out << "# Classes\n";
    out << "names:\n";

    // 按顺序写入类别
    QList<int> keys = config.classes.keys();
    std::sort(keys.begin(), keys.end());

    for (int key : keys) {
        out << "  " << key << ": " << config.classes[key] << "\n";
    }

    file.close();
    return true;
}
