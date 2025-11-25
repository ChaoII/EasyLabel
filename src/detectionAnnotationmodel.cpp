#include "detectionAnnotationmodel.h"

#include <QThread>
#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QIODevice>
#include <QJsonArray>
#include <QJsonObject>

DetectionAnnotationModel::DetectionAnnotationModel(QObject *parent)
    : AnnotationModelBase{parent} {}

int DetectionAnnotationModel::rowCount(const QModelIndex &parent) const {
    return parent.isValid() ? 0 : items_.size();
}

QVariant DetectionAnnotationModel::data(const QModelIndex &index,
                                        int role) const {
    if (!index.isValid() || index.row() >= items_.size())
        return QVariant();

    const DetectionAnnotationItem &detectionAnnotationItem =
        items_.at(index.row());
    switch (role) {
    case LabelIDRole:
        return detectionAnnotationItem.labelID;
    case XRole:
        return detectionAnnotationItem.x;
    case YRole:
        return detectionAnnotationItem.y;
    case WidthRole:
        return detectionAnnotationItem.width;
    case HeightRole:
        return detectionAnnotationItem.height;
    case ZOrderRole:
        return detectionAnnotationItem.zOrder;
    case SelectedRole:
        return detectionAnnotationItem.selected;
    default:
        return QVariant();
    }
}

bool DetectionAnnotationModel::setData(const QModelIndex &index,
                                       const QVariant &value, int role) {
    if (!index.isValid() || index.row() < 0 || index.row() >= items_.size())
        return false;

    DetectionAnnotationItem item = items_.at(index.row());
    bool changed = false;

    switch (role) {
    case LabelIDRole:
        if (value.canConvert<int>()) {
            item.labelID = value.toInt();
            changed = true;
        }
        break;
    case XRole:
        if (value.canConvert<int>()) {
            item.x = value.toInt();
            changed = true;
        }
        break;
    case YRole:
        if (value.canConvert<int>()) {
            item.y = value.toInt();
            changed = true;
        }
        break;
    case WidthRole:
        if (value.canConvert<int>()) {
            item.width = value.toInt();
            changed = true;
        }
        break;
    case HeightRole:
        if (value.canConvert<int>()) {
            item.height = value.toInt();
            changed = true;
        }
        break;
    default:
        return false;
    }
    if (changed) {
        emit dataChanged(index, index, {role});
        return true;
    }
    return false;
}

QHash<int, QByteArray> DetectionAnnotationModel::roleNames() const {
    QHash<int, QByteArray> roles;
    roles[LabelIDRole] = "labelID";
    roles[XRole] = "boxX";
    roles[YRole] = "boxY";
    roles[WidthRole] = "boxWidth";
    roles[HeightRole] = "boxHeight";
    roles[ZOrderRole] = "zOrder";
    roles[SelectedRole] = "selected";
    return roles;
}

void DetectionAnnotationModel::addItem(int lableID, int x, int y, int width,
                                       int height, int zOrder, bool selected) {
    beginInsertRows(QModelIndex(), items_.size(), items_.size());
    items_.append({lableID, x, y, width, height, zOrder, selected});
    endInsertRows();
}

void DetectionAnnotationModel::updateItem(int index, int lableID, int x, int y,
                                          int width, int height, int zOrder,
                                          bool selected) {
    if (index < 0 || index >= items_.size())
        return;
    items_[index] = {lableID, x, y, width, height, zOrder, selected};
    QModelIndex modelIndex = createIndex(index, 0);
    emit dataChanged(modelIndex, modelIndex,
                     {LabelIDRole, XRole, YRole, WidthRole, HeightRole,
                      ZOrderRole, SelectedRole});
}

void DetectionAnnotationModel::setSelected(int index, bool selected) {
    if (index < 0 || index >= items_.size())
        return;
    items_[index].selected = selected;
    QModelIndex modelIndex = createIndex(index, 0);
    emit dataChanged(modelIndex, modelIndex, {SelectedRole});
}

void DetectionAnnotationModel::removeItem(int index) {
    if (index < 0 || index >= items_.size())
        return;
    beginRemoveRows(QModelIndex(), index, index);
    items_.removeAt(index);
    endRemoveRows();
}

void DetectionAnnotationModel::clear() {
    if (items_.isEmpty())
        return;
    beginRemoveRows(QModelIndex(), 0, items_.size() - 1);
    items_.clear();
    endRemoveRows();
}

QRect DetectionAnnotationModel::getRect(int index) {
    if (index < 0 || index >= items_.size())
        return {};
    auto item = items_[index];
    return {item.x, item.y, item.width, item.height};
}

int DetectionAnnotationModel::getLabelID(int index) {
    if (index < 0 || index >= items_.size())
        return -1;
    return items_[index].labelID;
}

void DetectionAnnotationModel::removeAllSelected() {
    for (int i = 0; i < items_.size(); i++) {
        setSelected(i, false);
    }
}

void DetectionAnnotationModel::setSingleSelected(int index) {
    if (index < 0 || index >= items_.size())
        return;
    removeAllSelected();
    setSelected(index, true);
}

int DetectionAnnotationModel::getSelectedIndex(int x, int y) {
    for (int i = 0; i < items_.size(); i++) {
        if (getRect(i).contains(x, y))
            return i;
    }
    return -1;
}

QJsonArray DetectionAnnotationModel::toJsonArray() const {
    QJsonArray jsonArray;
    for (const DetectionAnnotationItem &item : items_) {
        QJsonObject jsonObj;
        jsonObj["labelID"] = item.labelID;
        jsonObj["x"] = item.x;
        jsonObj["y"] = item.y;
        jsonObj["width"] = item.width;
        jsonObj["height"] = item.height;
        jsonObj["zOrder"] = item.zOrder;
        jsonArray.append(jsonObj);
    }
    return jsonArray;
}

bool DetectionAnnotationModel::saveToFile(const QString &annotationFilePath,
                                          int annotationType,
                                          const QSize &imageSize) const {
    QFile file(annotationFilePath);
    if (!file.open(QIODevice::WriteOnly | QIODevice::Text)) {
        qWarning() << "无法打开文件进行写入:" << annotationFilePath;
        return false;
    }
    QJsonArray jsonArray = toJsonArray();
    QJsonObject obj;
    obj["type"] = annotationType;
    obj["width"] = imageSize.width();
    obj["height"] = imageSize.height();
    obj["boxes"] = jsonArray;
    QJsonDocument doc(obj);
    qint64 bytesWritten = file.write(doc.toJson(QJsonDocument::Indented));
    file.close();
    return bytesWritten > 0;
}

bool DetectionAnnotationModel::loadFromFile(const QString &annotationFilePath) {
    QFile file(annotationFilePath);
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        qWarning() << "无法打开文件进行读取:" << annotationFilePath;
        return false;
    }
    QByteArray jsonData = file.readAll();
    file.close();
    QJsonDocument doc = QJsonDocument::fromJson(jsonData);
    if (doc.isNull() || !doc.isObject()) {
        qWarning() << "无效的JSON文件或格式错误: " << annotationFilePath;
        return false;
    }
    QJsonObject obj = doc.object();
    AnnotationModelBase::annotationType_ =
        static_cast<AnnotationEnums::AnnotationType>(obj["type"].toInt());
    AnnotationModelBase::imageWidth_ = obj["width"].toInt();
    AnnotationModelBase::imageHeight_ = obj["height"].toInt();
    QJsonArray jsonArray = doc["boxes"].toArray();
    // 清空现有数据并加载新数据
    beginResetModel();
    items_.clear();
    for (const QJsonValue &value : std::as_const(jsonArray)) {
        if (value.isObject()) {
            QJsonObject obj = value.toObject();
            DetectionAnnotationItem item;
            item.labelID = obj["labelID"].toInt();
            item.x = obj["x"].toInt();
            item.y = obj["y"].toInt();
            item.width = obj["width"].toInt();
            item.height = obj["height"].toInt();
            item.zOrder = obj["zOrder"].toInt();
            item.selected = false;
            items_.append(item);
        }
    }
    endResetModel();
    return !items_.isEmpty();
}

void DetectionAnnotationModel::setLabelID(int index, int labelID) {
    if (index < 0 || index >= items_.size())
        return;
    items_[index].labelID = labelID;
    QModelIndex modelIndex = createIndex(index, 0);
    emit dataChanged(modelIndex, modelIndex, {LabelIDRole});
};

bool DetectionAnnotationModel::exportAnotation(
    const QString &exportDir, const QVector<QPair<QString, QString>> &dataSet,
    int exportType, double trainSplitRate) {

    // 验证参数
    if (exportDir.isEmpty()) {
        qWarning() << "导出目录为空";
        return false;
    }

    // 创建导出目录
    QDir dir(exportDir);
    if (dir.exists()) {
        qWarning() << "目录已存在,即将删除：" << exportDir;
        if (!dir.removeRecursively()) {
            qWarning() << "无法删除目录:" << exportDir;
            return false;
        }
        qDebug() << "目录已删除:" << exportDir;
    }

    // 创建新目录
    if (!dir.mkpath(".")) {
        qWarning() << "无法创建目录:" << exportDir;
        return false;
    }
    qDebug() << "目录创建成功:" << exportDir;
    return exportYoloAnnotation(exportDir, dataSet, trainSplitRate);
}

bool DetectionAnnotationModel::exportYoloAnnotation(
    const QString &exportDir, const QVector<QPair<QString, QString>> &dataSet,
    double trainSplitRate) {
    QDir dir(exportDir);
    QString trainImageDir = dir.filePath("images/train");
    QString valImageDir = dir.filePath("images/val");
    QString trainLabelDir = dir.filePath("labels/train");
    QString valLabelDir = dir.filePath("labels/val");
    // 创建新目录
    if (!QDir(trainImageDir).mkpath(".")) {
        qWarning() << "无法创建目录:" << trainImageDir;
        return false;
    }
    if (!QDir(valImageDir).mkpath(".")) {
        qWarning() << "无法创建目录:" << valImageDir;
        return false;
    }
    if (!QDir(trainLabelDir).mkpath(".")) {
        qWarning() << "无法创建目录:" << trainLabelDir;
        return false;
    }
    if (!QDir(valLabelDir).mkpath(".")) {
        qWarning() << "无法创建目录:" << valLabelDir;
        return false;
    }

    const int dataSetCount = dataSet.size();
    const int trainCount = dataSetCount * trainSplitRate;

    for (int i = 0; i < dataSetCount; i++) {
        auto [imagePath, annotationPath] = dataSet[i];
        loadFromFile(annotationPath);
        QString yoloAnnotationFileName =
            QFileInfo(annotationPath).baseName() + ".txt";
        QString imageFileName = QFileInfo(imagePath).fileName();
        bool isTrainSet = i < trainCount;
        QString labelDir = isTrainSet ? trainLabelDir : valLabelDir;
        QString imageDir = isTrainSet ? trainImageDir : valImageDir;
        QString yoloAnnotationFilePath = QDir(labelDir).filePath(yoloAnnotationFileName);
        QString newImageFilePath = QDir(imageDir).filePath(imageFileName);

        QFile file(yoloAnnotationFilePath);
        if (!file.open(QIODevice::WriteOnly | QIODevice::Text)) {
            qWarning() << "无法创建输出文件:" << yoloAnnotationFilePath;
            continue;
        }
        QTextStream out(&file);
        for (auto &item : items_) {
            double centerX = (item.x + item.width / 2.0) / imageWidth_;
            double centerY = (item.y + item.height / 2.0) / imageHeight_;
            double normWidth = static_cast<double>(item.width) / imageWidth_;
            double normHeight = static_cast<double>(item.height) / imageHeight_;
            // YOLO格式：<class_id> <center_x> <center_y> <width> <height>
            QString yoloAnnotationContent = QString("%1 %2 %3 %4 %5")
                                                .arg(item.labelID)
                                                .arg(centerX, 0, 'f', 6)
                                                .arg(centerY, 0, 'f', 6)
                                                .arg(normWidth, 0, 'f', 6)
                                                .arg(normHeight, 0, 'f', 6);
            out << yoloAnnotationContent<<"\n";
        }
        file.close();
        qDebug() << "YOLO格式文件已保存:" << yoloAnnotationFilePath;
        // 复制图像文件
        if (!QFile::copy(imagePath, newImageFilePath)) {
            qWarning() << "复制图像文件失败:" << imagePath << "->" << newImageFilePath;
        }
        double progress = static_cast<double>(i + 1) / dataSetCount * 100.0;
        emit exportProgress(progress);
        QThread::msleep(1);
    }
    qDebug() << "YOLO格式导出完成，总计处理" << dataSetCount << "个文件";
    return true;
}
