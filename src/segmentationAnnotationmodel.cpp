#include "segmentationAnnotationmodel.h"
#include "QmlUtilsCpp.h"
#include "annotationenums.h"
#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QIODevice>
#include <QJsonArray>
#include <QJsonObject>
#include <QMarginsF>
#include <QThread>
#include <QTransform>
#include <QtGlobal>

SegmentationAnnotationModel::SegmentationAnnotationModel(QObject *parent)
    : AnnotationModelBase{parent} {
    qRegisterMetaType<QVector<QPointF>>();
}

int SegmentationAnnotationModel::rowCount(const QModelIndex &parent) const {
    return parent.isValid() ? 0 : items_.size();
}

QVariant SegmentationAnnotationModel::data(const QModelIndex &index,
                                           int role) const {
    if (!index.isValid() || index.row() >= items_.size())
        return QVariant();

    const RotatedBoxAnnotationItem &detectionAnnotationItem =
        items_.at(index.row());
    switch (role) {
    case LabelIDRole:
        return detectionAnnotationItem.labelID;
    case PointsRole:
        return detectionAnnotationItem.points;
    case ZOrderRole:
        return detectionAnnotationItem.zOrder;
    case SelectedRole:
        return detectionAnnotationItem.selected;
    default:
        return QVariant();
    }
}

bool SegmentationAnnotationModel::setData(const QModelIndex &index,
                                          const QVariant &value, int role) {
    if (!index.isValid() || index.row() < 0 || index.row() >= items_.size())
        return false;
    RotatedBoxAnnotationItem &item = items_[index.row()];
    bool changed = false;
    switch (role) {
    case LabelIDRole:
        if (value.canConvert<int>()) {
            item.labelID = value.toInt();
            changed = true;
        }
        break;
    case PointsRole: {
        if (value.canConvert<QVariantList>()) {
            QVariantList list = value.toList();
            item.points = list;
        }
        changed = true;
        break;
    }

    case ZOrderRole:
        if (value.canConvert<int>()) {
            item.zOrder = value.toInt();
            changed = true;
        }
        break;
    case SelectedRole:
        if (value.canConvert<bool>()) {
            item.selected = value.toBool();
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

QHash<int, QByteArray> SegmentationAnnotationModel::roleNames() const {
    QHash<int, QByteArray> roles;
    roles[LabelIDRole] = "labelID";
    roles[PointsRole] = "points";
    roles[ZOrderRole] = "zOrder";
    roles[SelectedRole] = "selected";
    return roles;
}

bool SegmentationAnnotationModel::setProperty(int index,
                                              const QString &property,
                                              const QVariant &value) {
    if (index < 0 || index >= items_.size())
        return false;

    QModelIndex modelIndex = createIndex(index, 0);

    if (property == "labelID")
        return setData(modelIndex, value, LabelIDRole);
    else if (property == "points")
        return setData(modelIndex, value, PointsRole);
    else if (property == "zOrder")
        return setData(modelIndex, value, ZOrderRole);
    else if (property == "selected")
        return setData(modelIndex, value, SelectedRole);
    else
        return false;
}

QVariant SegmentationAnnotationModel::getProperty(int index,
                                                  const QString &property) {
    if (index < 0 || index >= items_.size())
        return "";
    QModelIndex modelIndex = createIndex(index, 0);
    if (property == "labelID")
        return data(modelIndex, LabelIDRole);
    if (property == "points")
        return data(modelIndex, PointsRole);
    if (property == "zOrder")
        return data(modelIndex, ZOrderRole);
    if (property == "selected")
        return data(modelIndex, SelectedRole);
    return "";
}

void SegmentationAnnotationModel::addItem(int lableID,
                                          const QVariantList &points,
                                          int zOrder, bool selected) {
    beginInsertRows(QModelIndex(), items_.size(), items_.size());
    items_.append({lableID, points, zOrder, selected});
    endInsertRows();
}

int SegmentationAnnotationModel::getPointSize(int index) {
    if (index < 0 || index >= items_.size())
        return 0;
    return items_[index].points.size();
}

QVariantList SegmentationAnnotationModel::getPoints(int index){
    if (index < 0 || index >= items_.size())
        return {};
    return items_[index].points;
}

void SegmentationAnnotationModel::appendPoint(int index, const QPointF &point) {
    if (index < 0 || index >= items_.size())
        return;
    QModelIndex modelIndex = createIndex(index, 0);
    items_[index].points.push_back(QVariant::fromValue(point));
    emit dataChanged(modelIndex, modelIndex, {PointsRole});
}
void SegmentationAnnotationModel::updatePoint(int index, int pointIndex, const QPointF& point){
    if (index < 0 || index >= items_.size())
        return;
    if (items_.empty())
        return;

    int pointSize = items_[index].points.size();
    if(pointIndex<0 || pointIndex>=pointSize) return;
    items_[index].points[pointIndex] = point;
    QModelIndex modelIndex = createIndex(index, 0);
    emit dataChanged(modelIndex, modelIndex, {PointsRole});
}

void SegmentationAnnotationModel::updateLastPoint(int index,
                                                  const QPointF &point) {
    if (index < 0 || index >= items_.size())
        return;
    if (items_.empty())
        return;
    items_[index].points.last() = point;
    QModelIndex modelIndex = createIndex(index, 0);
    emit dataChanged(modelIndex, modelIndex, {PointsRole});
}

void SegmentationAnnotationModel::moveShape(int index, const QPointF &dPoint) {
    if (index < 0 || index >= items_.size())
        return;
    auto &item = items_[index];
    for (int i = 0; i < item.points.size(); i++) {
        auto value = item.points[i];
        auto point = value.toPointF();
        item.points[i] = QVariant::fromValue(point + dPoint);
    }
    QModelIndex modelIndex = createIndex(index, 0);
    emit dataChanged(modelIndex, modelIndex, {PointsRole});
}

void SegmentationAnnotationModel::popFrontPoint(int index) {
    if (index < 0 || index >= items_.size())
        return;
    items_[index].points.pop_front();
    QModelIndex modelIndex = createIndex(index, 0);
    emit dataChanged(modelIndex, modelIndex, {PointsRole});
}

void SegmentationAnnotationModel::popBackPoint(int index) {
    if (index < 0 || index >= items_.size())
        return;
    items_[index].points.pop_back();
    QModelIndex modelIndex = createIndex(index, 0);
    emit dataChanged(modelIndex, modelIndex, {PointsRole});
}

void SegmentationAnnotationModel::setSelected(int index, bool selected) {
    if (index < 0 || index >= items_.size())
        return;
    items_[index].selected = selected;
    QModelIndex modelIndex = createIndex(index, 0);
    emit dataChanged(modelIndex, modelIndex, {SelectedRole});
}

void SegmentationAnnotationModel::removeItem(int index) {
    if (index < 0 || index >= items_.size())
        return;
    beginRemoveRows(QModelIndex(), index, index);
    items_.removeAt(index);
    endRemoveRows();
}

void SegmentationAnnotationModel::clear() {
    if (items_.isEmpty())
        return;
    beginRemoveRows(QModelIndex(), 0, items_.size() - 1);
    items_.clear();
    endRemoveRows();
}

int SegmentationAnnotationModel::getLabelID(int index) {
    if (index < 0 || index >= items_.size())
        return -1;
    return items_[index].labelID;
}

void SegmentationAnnotationModel::removeAllSelected() {
    for (int i = 0; i < items_.size(); i++) {
        setSelected(i, false);
    }
}

void SegmentationAnnotationModel::setSingleSelected(int index) {
    if (index < 0 || index >= items_.size())
        return;
    removeAllSelected();
    setSelected(index, true);
}

int SegmentationAnnotationModel::getSelectedIndex(int x, int y) {
    for (int i = 0; i < items_.size(); i++) {
        auto &item = items_[i];
        QVector<QPointF> polygon;
        for (auto &variant : item.points) {
            polygon.append(variant.toPointF());
        }
        if (QmlUtilsCpp::isPointInPolygon(QPointF(x, y), polygon))
            return i;
    }
    return -1;
}

QJsonArray SegmentationAnnotationModel::toJsonArray() const {
    QJsonArray jsonArray;
    for (const auto &item : items_) {
        QJsonObject jsonObj;
        jsonObj["labelID"] = item.labelID;
        // 手动转换 points
        QJsonArray pointsArray;
        for (const auto &value : item.points) {
            QJsonObject pointObj;
            auto point = value.toPointF();
            pointObj["x"] = point.x();
            pointObj["y"] = point.y();
            pointsArray.append(pointObj);
        }
        jsonObj["points"] = pointsArray;
        jsonObj["zOrder"] = item.zOrder;
        jsonArray.append(jsonObj);
    }
    return jsonArray;
}

bool SegmentationAnnotationModel::saveToFile(const QString &annotationFilePath,
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

bool SegmentationAnnotationModel::loadFromFile(
    const QString &annotationFilePath) {
    QFile file(annotationFilePath);
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        qWarning() << "无法打开文件进行读取:" << annotationFilePath;
        return false;
    }
    QByteArray jsonData = file.readAll();
    file.close();
    QJsonDocument doc = QJsonDocument::fromJson(jsonData);
    if (doc.isNull() || !doc.isObject()) {
        // qWarning() << "无效的JSON文件或格式错误: " << annotationFilePath;
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
            RotatedBoxAnnotationItem item;
            item.labelID = obj["labelID"].toInt();
            QJsonArray pointsArray = obj["points"].toArray();
            for (const QJsonValue &pointValue : std::as_const(pointsArray)) {
                if (pointValue.isObject()) {
                    QJsonObject pointObj = pointValue.toObject();
                    if (pointObj.contains("x") && pointObj.contains("y")) {
                        double x = pointObj["x"].toDouble();
                        double y = pointObj["y"].toDouble();
                        item.points.append(QPointF(x, y));
                    }
                }
            }
            item.zOrder = obj["zOrder"].toInt();
            item.selected = false;
            items_.append(item);
        }
    }
    endResetModel();
    return !items_.isEmpty();
}

void SegmentationAnnotationModel::setLabelID(int index, int labelID) {
    if (index < 0 || index >= items_.size())
        return;
    items_[index].labelID = labelID;
    QModelIndex modelIndex = createIndex(index, 0);
    emit dataChanged(modelIndex, modelIndex, {LabelIDRole});
};

bool SegmentationAnnotationModel::exportAnotation(
    const QString &exportDir, const QVector<QPair<QString, QString>> &dataSet,
    int exportType, double trainSplitRate, const QVector<QString> &labels) {

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
    return exportYoloAnnotation(exportDir, dataSet, trainSplitRate, labels);
}

bool SegmentationAnnotationModel::exportYoloAnnotation(
    const QString &exportDir, const QVector<QPair<QString, QString>> &dataSet,
    double trainSplitRate, const QVector<QString> &labels) {
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
        QString yoloAnnotationFilePath =
            QDir(labelDir).filePath(yoloAnnotationFileName);
        QString newImageFilePath = QDir(imageDir).filePath(imageFileName);

        QFile file(yoloAnnotationFilePath);
        if (!file.open(QIODevice::WriteOnly | QIODevice::Text)) {
            qWarning() << "无法创建输出文件:" << yoloAnnotationFilePath;
            continue;
        }
        QTextStream out(&file);
        for (auto &item : items_) {
            auto points = item.points;
            QPolygonF polygon;
            for (auto &variant : item.points) {
                polygon.append(variant.toPointF());
            }
            QRectF rect = polygon.boundingRect();
            auto bboxCenterX = rect.center().x() / imageWidth_;
            auto bboxCenterY = rect.center().y() / imageHeight_;
            auto bboxWidth = rect.width() / imageWidth_;
            auto bboxHeight = rect.height() / imageHeight_;
            // YOLO实例分割格式：<class_id> <bbox_cx> <bbox_cy> <bbox_w> <bbox_h>
            // <polygon_points...>
            QString yoloAnnotationContent = QString("%1 %2 %3 %4 %5")
                                                .arg(item.labelID)
                                                .arg(bboxCenterX, 0, 'f', 6)
                                                .arg(bboxCenterY, 0, 'f', 6)
                                                .arg(bboxWidth, 0, 'f', 6)
                                                .arg(bboxHeight, 0, 'f', 6);

            for (const auto &value : std::as_const(item.points)) {
                auto point = value.toPointF();
                double x = point.x() / imageWidth_;
                double y = point.y() / imageHeight_;
                yoloAnnotationContent +=
                    QString(" %1 %2").arg(x, 0, 'f', 6).arg(y, 0, 'f', 6);
            }
            out << yoloAnnotationContent << "\n";
        }
        file.close();
        qDebug() << "YOLO格式文件已保存:" << yoloAnnotationFilePath;
        // 复制图像文件
        if (!QFile::copy(imagePath, newImageFilePath)) {
            qWarning() << "复制图像文件失败:" << imagePath << "->"
                       << newImageFilePath;
        }
        double progress = static_cast<double>(i + 1) / dataSetCount * 100.0;
        emit exportProgress(progress);
        QThread::msleep(1);
    }
    QString yamlConfigFilePath = dir.absoluteFilePath("data.yaml");
    DatasetConfig config;
    config.path = dir.absolutePath();
    config.testPath = "";
    config.trainPath = "images/train";
    config.valPath = "images/val";

    for (int i = 0; i < labels.size(); i++) {
        config.classes.insert(i, labels[i]);
    }
    if (!generateYamlConfig(yamlConfigFilePath, config)) {
        qDebug() << "YOLO 配置文件导出失败" << yamlConfigFilePath;
    }
    qDebug() << "YOLO格式导出完成，总计处理" << dataSetCount << "个文件";
    return true;
}
