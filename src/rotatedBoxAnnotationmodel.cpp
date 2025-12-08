#include "rotatedBoxAnnotationmodel.h"
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

RotatedBoxAnnotationModel::RotatedBoxAnnotationModel(QObject *parent)
    : AnnotationModelBase{parent} {}

int RotatedBoxAnnotationModel::rowCount(const QModelIndex &parent) const {
    return parent.isValid() ? 0 : items_.size();
}

QVariant RotatedBoxAnnotationModel::data(const QModelIndex &index,
                                         int role) const {
    if (!index.isValid() || index.row() >= items_.size())
        return QVariant();

    const RotatedBoxAnnotationItem &item = items_.at(index.row());
    switch (role) {
    case LabelIDRole:
        return item.labelID;
    case XRole:
        return item.x;
    case YRole:
        return item.y;
    case WidthRole:
        return item.width;
    case HeightRole:
        return item.height;
    case ZOrderRole:
        return item.zOrder;
    case RotationRole:
        return item.rotation;
    case SelectedRole:
        return item.selected;
    case GroupIDRole:
        return item.groupID;
    case DescriptionRole:
        return item.description;
    default:
        return QVariant();
    }
}

bool RotatedBoxAnnotationModel::setData(const QModelIndex &index,
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

    case ZOrderRole:
        if (value.canConvert<int>()) {
            item.zOrder = value.toInt();
            changed = true;
        }
        break;
    case RotationRole:
        if (value.canConvert<double>()) {
            item.rotation = value.toDouble();
            changed = true;
        }
        break;
    case SelectedRole:
        if (value.canConvert<bool>()) {
            item.selected = value.toBool();
            changed = true;
        }
        break;
    case GroupIDRole:
        if (value.canConvert<int>()) {
            item.groupID = value.toInt();
            changed = true;
        }
        break;
    case DescriptionRole:
        if (value.canConvert<QString>()) {
            item.description = value.toString();
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

QHash<int, QByteArray> RotatedBoxAnnotationModel::roleNames() const {
    QHash<int, QByteArray> roles;
    roles[LabelIDRole] = "labelID";
    roles[XRole] = "boxX";
    roles[YRole] = "boxY";
    roles[WidthRole] = "boxWidth";
    roles[HeightRole] = "boxHeight";
    roles[ZOrderRole] = "zOrder";
    roles[RotationRole] = "boxRotation";
    roles[SelectedRole] = "selected";
    roles[GroupIDRole] = "groupID";
    roles[DescriptionRole] = "description";
    return roles;
}

bool RotatedBoxAnnotationModel::setProperty(int index, const QString &property,
                                            const QVariant &value) {
    if (index < 0 || index >= items_.size())
        return false;

    QModelIndex modelIndex = createIndex(index, 0);

    if (property == "labelID")
        return setData(modelIndex, value, LabelIDRole);
    else if (property == "boxX")
        return setData(modelIndex, value, XRole);
    else if (property == "boxY")
        return setData(modelIndex, value, YRole);
    else if (property == "boxWidth")
        return setData(modelIndex, value, WidthRole);
    else if (property == "boxHeight")
        return setData(modelIndex, value, HeightRole);
    else if (property == "zOrder")
        return setData(modelIndex, value, ZOrderRole);
    else if (property == "boxRotation")
        return setData(modelIndex, value, RotationRole);
    else if (property == "selected")
        return setData(modelIndex, value, SelectedRole);
    else if (property == "groupID")
        return setData(modelIndex, value, GroupIDRole);
    else if (property == "description")
        return setData(modelIndex, value, DescriptionRole);
    else
        return false;
}

QVariant RotatedBoxAnnotationModel::getProperty(int index,
                                                const QString &property) {
    if (index < 0 || index >= items_.size())
        return "";
    QModelIndex modelIndex = createIndex(index, 0);
    if (property == "labelID")
        return data(modelIndex, LabelIDRole);
    if (property == "boxX")
        return data(modelIndex, XRole);
    if (property == "boxY")
        return data(modelIndex, YRole);
    if (property == "boxWidth")
        return data(modelIndex, WidthRole);
    if (property == "boxHeight")
        return data(modelIndex, HeightRole);
    if (property == "zOrder")
        return data(modelIndex, ZOrderRole);
    if (property == "boxRotation")
        return data(modelIndex, RotationRole);
    if (property == "selected")
        return data(modelIndex, SelectedRole);
    if (property == "groupID")
        return data(modelIndex, GroupIDRole);
    if (property == "description")
        return data(modelIndex, DescriptionRole);
    return QVariant();
}

void RotatedBoxAnnotationModel::addItem(int lableID, int x, int y, int width,
                                        int height, int zOrder, double rotation,
                                        bool selected) {
    beginInsertRows(QModelIndex(), items_.size(), items_.size());
    items_.append({lableID, x, y, width, height, zOrder, rotation, selected});
    endInsertRows();
}

void RotatedBoxAnnotationModel::updateItem(int index, int lableID, int x, int y,
                                           int width, int height, int zOrder,
                                           double rotation, bool selected) {
    if (index < 0 || index >= items_.size())
        return;
    items_[index] = {lableID, x,        y,        width, height,
                     zOrder,  rotation, selected, 0,     ""};
    QModelIndex modelIndex = createIndex(index, 0);
    emit dataChanged(modelIndex, modelIndex,
                     {LabelIDRole, XRole, YRole, WidthRole, HeightRole,
                                              ZOrderRole, RotationRole, SelectedRole});
}

void RotatedBoxAnnotationModel::setSelected(int index, bool selected) {
    if (index < 0 || index >= items_.size())
        return;
    items_[index].selected = selected;
    QModelIndex modelIndex = createIndex(index, 0);
    emit dataChanged(modelIndex, modelIndex, {SelectedRole});
}

void RotatedBoxAnnotationModel::removeItem(int index) {
    if (index < 0 || index >= items_.size())
        return;
    beginRemoveRows(QModelIndex(), index, index);
    items_.removeAt(index);
    endRemoveRows();
}

void RotatedBoxAnnotationModel::clear() {
    if (items_.isEmpty())
        return;
    beginRemoveRows(QModelIndex(), 0, items_.size() - 1);
    items_.clear();
    endRemoveRows();
}

QRectF RotatedBoxAnnotationModel::getBoundingBox(const QRectF &rect,
                                                 double angle) {
    QPointF origin = rect.topLeft();

    QTransform transform;
    transform.translate(origin.x(), origin.y());
    transform.rotate(angle);
    transform.translate(-origin.x(), -origin.y());

    // 矩形的四个角
    QPointF p1 = transform.map(rect.topLeft());
    QPointF p2 = transform.map(rect.topRight());
    QPointF p3 = transform.map(rect.bottomLeft());
    QPointF p4 = transform.map(rect.bottomRight());

    qreal minX = std::min({p1.x(), p2.x(), p3.x(), p4.x()});
    qreal minY = std::min({p1.y(), p2.y(), p3.y(), p4.y()});
    qreal maxX = std::max({p1.x(), p2.x(), p3.x(), p4.x()});
    qreal maxY = std::max({p1.y(), p2.y(), p3.y(), p4.y()});

    return QRectF(QPointF(minX, minY), QPointF(maxX, maxY));
}

QRectF RotatedBoxAnnotationModel::getBoundingBox(int index) {
    if (index < 0 || index >= items_.size())
        return {};
    auto item = items_[index];
    QRectF rect(item.x, item.y, item.width, item.height);
    double angle = item.rotation;
    return getBoundingBox(rect, angle);
}

QVector<QPointF> RotatedBoxAnnotationModel::rotatedRectCorners(int index) {
    if (index < 0 || index >= items_.size())
        return {};
    auto item = items_[index];
    QRectF rect(item.x, item.y, item.width, item.height);
    double angle = item.rotation;
    QPointF origin = rect.topLeft();

    QTransform transform;
    transform.translate(origin.x(), origin.y());
    transform.rotate(angle);
    transform.translate(-origin.x(), -origin.y());

    return {transform.map(rect.topLeft()), transform.map(rect.topRight()),
            transform.map(rect.bottomRight()), transform.map(rect.bottomLeft())};
}

QRect RotatedBoxAnnotationModel::getRect(int index) {
    if (index < 0 || index >= items_.size())
        return {};
    auto item = items_[index];
    return {item.x, item.y, item.width, item.height};
}

double RotatedBoxAnnotationModel::getRotation(int index) {
    if (index < 0 || index >= items_.size())
        return 0.0;
    auto item = items_[index];
    return item.rotation;
}

int RotatedBoxAnnotationModel::getLabelID(int index) {
    if (index < 0 || index >= items_.size())
        return -1;
    return items_[index].labelID;
}

void RotatedBoxAnnotationModel::removeAllSelected() {
    for (int i = 0; i < items_.size(); i++) {
        setSelected(i, false);
    }
}

void RotatedBoxAnnotationModel::setSingleSelected(int index) {
    if (index < 0 || index >= items_.size())
        return;
    removeAllSelected();
    setSelected(index, true);
}

int RotatedBoxAnnotationModel::getSelectedIndex(int x, int y) {
    for (int i = 0; i < items_.size(); i++) {
        auto &item = items_[i];
        QRectF rect(item.x, item.y, item.width, item.height);
        double rotation = item.rotation;
        if (QmlUtilsCpp::pointInRotatedRect(
                QPointF(x, y), rect.marginsAdded(QMarginsF(10, 10, 10, 10)),
                rotation))
            return i;
    }
    return -1;
}

QJsonArray RotatedBoxAnnotationModel::toJsonArray() const {
    QJsonArray jsonArray;
    for (const auto &item : items_) {
        QJsonObject jsonObj;
        jsonObj["labelID"] = item.labelID;
        jsonObj["x"] = item.x;
        jsonObj["y"] = item.y;
        jsonObj["width"] = item.width;
        jsonObj["height"] = item.height;
        jsonObj["zOrder"] = item.zOrder;
        jsonObj["rotation"] = item.rotation;
        jsonObj["groupID"] = item.groupID;
        jsonObj["description"] = item.description;
        jsonArray.append(jsonObj);
    }
    return jsonArray;
}

bool RotatedBoxAnnotationModel::saveToFile(const QString &annotationFilePath,
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

bool RotatedBoxAnnotationModel::loadFromFile(
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
            item.x = obj["x"].toInt();
            item.y = obj["y"].toInt();
            item.width = obj["width"].toInt();
            item.height = obj["height"].toInt();
            item.zOrder = obj["zOrder"].toInt();
            item.rotation = obj["rotation"].toDouble();
            item.groupID = obj["groupID"].toInt();
            item.description = obj["description"].toString();
            item.selected = false;
            items_.append(item);
        }
    }
    endResetModel();
    return !items_.isEmpty();
}

void RotatedBoxAnnotationModel::setLabelID(int index, int labelID) {
    if (index < 0 || index >= items_.size())
        return;
    items_[index].labelID = labelID;
    QModelIndex modelIndex = createIndex(index, 0);
    emit dataChanged(modelIndex, modelIndex, {LabelIDRole});
};

bool RotatedBoxAnnotationModel::exportAnotation(
    const QString &exportDir, const QVector<QPair<QString, QString>> &dataSet,
    int exportType, double trainSplitRate, const QVector<QString> &labels,
    const QString &templateFile) {

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

bool RotatedBoxAnnotationModel::exportYoloAnnotation(
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
            QRectF rect(item.x, item.y, item.width, item.height);
            double rotation = item.rotation;
            auto points = QmlUtilsCpp::rotatedRectCorners(rect, rotation);
            double x1 = points[0].x() / imageWidth_;
            double y1 = points[0].y() / imageHeight_;
            double x2 = points[1].x() / imageWidth_;
            double y2 = points[1].y() / imageHeight_;
            double x3 = points[2].x() / imageWidth_;
            double y3 = points[2].y() / imageHeight_;
            double x4 = points[3].x() / imageWidth_;
            double y4 = points[3].y() / imageHeight_;
            // YOLO格式：<class_id> <x1> <y1> <x2> <y2> <x3> <y3> <x4> <y4>
            QString yoloAnnotationContent = QString("%1 %2 %3 %4 %5 %6 %7 %8 %9")
                                                .arg(item.labelID)
                                                .arg(x1, 0, 'f', 6)
                                                .arg(y1, 0, 'f', 6)
                                                .arg(x2, 0, 'f', 6)
                                                .arg(y2, 0, 'f', 6)
                                                .arg(x3, 0, 'f', 6)
                                                .arg(y3, 0, 'f', 6)
                                                .arg(x4, 0, 'f', 6)
                                                .arg(y4, 0, 'f', 6);
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
