#include "keyPointAnnotationmodel.h"
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

KeyPointAnnotationModel::KeyPointAnnotationModel(QObject *parent)
    : AnnotationModelBase{parent} {
    qRegisterMetaType<QVector<QPointF>>();
}

int KeyPointAnnotationModel::rowCount(const QModelIndex &parent) const {
    return parent.isValid() ? 0 : items_.size();
}

QVariant KeyPointAnnotationModel::data(const QModelIndex &index,
                                       int role) const {
    if (!index.isValid() || index.row() >= items_.size())
        return QVariant();

    const KeyPointAnnotationItem &item = items_.at(index.row());
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
    case TypeRole:
        return item.type;
    case VisibleStatusRole:
        return item.visibleStatus;
    case GroupIDRole:
        return item.groupID;
    case ZOrderRole:
        return item.zOrder;
    case SelectedRole:
        return item.selected;
    case DescriptionRole:
        return item.description;
    default:
        return QVariant();
    }
}

bool KeyPointAnnotationModel::setData(const QModelIndex &index,
                                      const QVariant &value, int role) {
    if (!index.isValid() || index.row() < 0 || index.row() >= items_.size())
        return false;
    KeyPointAnnotationItem &item = items_[index.row()];
    bool changed = false;
    switch (role) {
    case LabelIDRole:
        if (value.canConvert<int>()) {
            item.labelID = value.toInt();
            changed = true;
        }
        break;
    case XRole: {
        if (value.canConvert<double>()) {
            item.x = value.toDouble();
        }
        changed = true;
        break;
    }
    case YRole: {
        if (value.canConvert<double>()) {
            item.y = value.toDouble();
        }
        changed = true;
        break;
    }
    case WidthRole: {
        if (value.canConvert<double>()) {
            item.width = value.toDouble();
        }
        changed = true;
        break;
    }
    case HeightRole: {
        if (value.canConvert<double>()) {
            item.height = value.toDouble();
        }
        changed = true;
        break;
    }
    case TypeRole: {
        if (value.canConvert<int>()) {
            item.type = value.toInt();
        }
        changed = true;
        break;
    }
    case VisibleStatusRole: {
        if (value.canConvert<int>()) {
            item.visibleStatus = value.toInt();
        }
        changed = true;
        break;
    }
    case GroupIDRole: {
        if (value.canConvert<int>()) {
            item.groupID = value.toInt();
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

QHash<int, QByteArray> KeyPointAnnotationModel::roleNames() const {
    QHash<int, QByteArray> roles;
    roles[LabelIDRole] = "labelID";
    roles[XRole] = "boxX";
    roles[YRole] = "boxY";
    roles[WidthRole] = "boxWidth";
    roles[HeightRole] = "boxHeight";
    roles[TypeRole] = "type";
    roles[VisibleStatusRole] = "visibleStatus";
    roles[GroupIDRole] = "groupID";
    roles[ZOrderRole] = "zOrder";
    roles[SelectedRole] = "selected";
    roles[DescriptionRole] = "description";
    return roles;
}

bool KeyPointAnnotationModel::setProperty(int index, const QString &property,
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
    else if (property == "type")
        return setData(modelIndex, value, TypeRole);
    else if (property == "visibleStatus")
        return setData(modelIndex, value, VisibleStatusRole);
    else if (property == "groupID")
        return setData(modelIndex, value, GroupIDRole);
    else if (property == "zOrder")
        return setData(modelIndex, value, ZOrderRole);
    else if (property == "selected")
        return setData(modelIndex, value, SelectedRole);
    else if (property == "description")
        return setData(modelIndex, value, DescriptionRole);
    else
        return false;
}

QVariant KeyPointAnnotationModel::getProperty(int index,
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
    if (property == "type")
        return data(modelIndex, TypeRole);
    if (property == "visibleStatus")
        return data(modelIndex, VisibleStatusRole);
    if (property == "groupID")
        return data(modelIndex, GroupIDRole);
    if (property == "zOrder")
        return data(modelIndex, ZOrderRole);
    if (property == "selected")
        return data(modelIndex, SelectedRole);
    if (property == "description")
        return data(modelIndex, DescriptionRole);
    return QVariant();
}

QMap<int, QVector<KeyPointAnnotationModel::KeyPointAnnotationItem>>
KeyPointAnnotationModel::groupByGroupID(
    const QVector<KeyPointAnnotationItem> &items) {
    QMap<int, QVector<KeyPointAnnotationItem>> groups;
    for (const auto &item : items) {
        groups[item.groupID].append(item);
    }
    return groups;
}

QVector<KeyPointAnnotationModel::KeyPointAnnotationItem>
KeyPointAnnotationModel::reorderKeypoints(
    const QVector<KeyPointAnnotationItem> &keypoints, int classId,
    const QVector<QString> &labels,
    const QMap<int, QVector<QString>> &keypointNamesMap) {
    // 获取当前类别对应的关键点名称列表
    if (!keypointNamesMap.contains(classId)) {
        qWarning() << "未找到类别" << classId << "对应的关键点配置";
        return keypoints; // 返回原始顺序
    }

    QVector<QString> keypointNames = keypointNamesMap.value(classId);
    QVector<KeyPointAnnotationItem> orderedKeypoints(keypointNames.size());

    // 初始化默认值（不可见的关键点）
    for (int i = 0; i < keypointNames.size(); i++) {
        orderedKeypoints[i] =
            KeyPointAnnotationItem{-1, 0, 0, 0, 0, 1, 0, -1, -1, false, ""};
    }

    // 根据标签名称匹配关键点
    for (const auto &kp : keypoints) {
        auto kptLabelName = labels[kp.labelID];
        int index = keypointNames.indexOf(kptLabelName);
        if (index != -1) {
            orderedKeypoints[index] = kp;
            orderedKeypoints[index].visibleStatus = 2; // 标记为可见
        } else {
            qWarning() << "关键点" << kp.labelID << "不在标准关键点列表中";
        }
    }
    return orderedKeypoints;
}

QMap<int, QVector<QString>>
KeyPointAnnotationModel::parseKeypointNames(const QJsonArray &kptNamesArray) {
    QMap<int, QVector<QString>> keypointNamesMap;

    for (const QJsonValue &itemValue : kptNamesArray) {
        if (itemValue.isObject()) {
            QJsonObject itemObj = itemValue.toObject();

            // 遍历对象的所有键值对
            for (auto it = itemObj.begin(); it != itemObj.end(); ++it) {
                bool ok;
                int classId = it.key().toInt(&ok);

                if (ok && it.value().isArray()) {
                    QJsonArray keypointArray = it.value().toArray();
                    QVector<QString> keypointNames;

                    for (const QJsonValue &kpValue : keypointArray) {
                        if (kpValue.isString()) {
                            keypointNames.append(kpValue.toString());
                        }
                    }

                    if (!keypointNames.isEmpty()) {
                        keypointNamesMap.insert(classId, keypointNames);
                        qDebug() << "加载类别" << classId << "的关键点:" << keypointNames;
                    }
                }
            }
        }
    }

    return keypointNamesMap;
}

void KeyPointAnnotationModel::addItem(int lableID, double x, double y,
                                      double width, double height, int type,
                                      int visibleStatus, int groupID,
                                      int zOrder, bool selected) {
    beginInsertRows(QModelIndex(), items_.size(), items_.size());
    items_.append({lableID, x, y, width, height, type, visibleStatus, groupID,
                   zOrder, selected});
    endInsertRows();
}

void KeyPointAnnotationModel::setRect(int index, const QRectF &rect) {
    if (index < 0 || index >= items_.size())
        return;
    auto &item = items_[index];
    item.x = rect.x();
    item.y = rect.y();
    item.width = rect.width();
    item.height = rect.height();
    QModelIndex modelIndex = createIndex(index, 0);
    emit dataChanged(modelIndex, modelIndex,
                     {XRole, YRole, WidthRole, HeightRole});
}

void KeyPointAnnotationModel::moveShape(int index, const QPointF &dPoint) {
    if (index < 0 || index >= items_.size())
        return;
    auto &item = items_[index];
    item.x += dPoint.x();
    item.y += dPoint.y();
    QModelIndex modelIndex = createIndex(index, 0);
    emit dataChanged(modelIndex, modelIndex, {XRole, YRole});
}

void KeyPointAnnotationModel::setSelected(int index, bool selected) {
    if (index < 0 || index >= items_.size())
        return;
    items_[index].selected = selected;
    QModelIndex modelIndex = createIndex(index, 0);
    emit dataChanged(modelIndex, modelIndex, {SelectedRole});
}

void KeyPointAnnotationModel::removeItem(int index) {
    if (index < 0 || index >= items_.size())
        return;
    beginRemoveRows(QModelIndex(), index, index);
    items_.removeAt(index);
    endRemoveRows();
}

void KeyPointAnnotationModel::clear() {
    if (items_.isEmpty())
        return;
    beginRemoveRows(QModelIndex(), 0, items_.size() - 1);
    items_.clear();
    endRemoveRows();
}

int KeyPointAnnotationModel::getLabelID(int index) {
    if (index < 0 || index >= items_.size())
        return -1;
    return items_[index].labelID;
}

void KeyPointAnnotationModel::removeAllSelected() {
    for (int i = 0; i < items_.size(); i++) {
        setSelected(i, false);
    }
}

void KeyPointAnnotationModel::setSingleSelected(int index) {
    if (index < 0 || index >= items_.size())
        return;
    removeAllSelected();
    setSelected(index, true);
}

int KeyPointAnnotationModel::getSelectedIndex(int x, int y, int radius) {
    for (int i = 0; i < items_.size(); i++) {
        auto &item = items_[i];
        QRectF rect;
        if (item.type == 0) {
            rect = QRectF(item.x, item.y, item.width, item.height);
        } else {
            rect = QRectF(item.x - radius, item.y - radius, 2 * radius, 2 * radius);
        }
        if (rect.marginsAdded(QMarginsF(10,10,10,10)).contains(x, y)) {
            return i;
        }
    }
    return -1;
}

QJsonArray KeyPointAnnotationModel::toJsonArray() const {
    QJsonArray jsonArray;
    for (const auto &item : items_) {
        QJsonObject jsonObj;
        jsonObj["labelID"] = item.labelID;
        jsonObj["x"] = item.x;
        jsonObj["y"] = item.y;
        jsonObj["width"] = item.width;
        jsonObj["height"] = item.height;
        jsonObj["type"] = item.type;
        jsonObj["visibleStatus"] = item.visibleStatus;
        jsonObj["groupID"] = item.groupID;
        jsonObj["zOrder"] = item.zOrder;
        jsonArray.append(jsonObj);
    }
    return jsonArray;
}

bool KeyPointAnnotationModel::saveToFile(const QString &annotationFilePath,
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

bool KeyPointAnnotationModel::loadFromFile(const QString &annotationFilePath) {
    QFile file(annotationFilePath);
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        qWarning() << "无法打开文件进行读取:" << annotationFilePath;
        return false;
    }
    QByteArray jsonData = file.readAll();
    file.close();
    QJsonDocument doc = QJsonDocument::fromJson(jsonData);
    if (doc.isNull() || !doc.isObject()) {
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
            KeyPointAnnotationItem item;
            item.labelID = obj["labelID"].toInt();
            item.x = obj["x"].toDouble();
            item.y = obj["y"].toDouble();
            item.width = obj["width"].toDouble();
            item.height = obj["height"].toDouble();
            item.type = obj["type"].toInt();
            item.visibleStatus = obj["visibleStatus"].toBool();
            item.groupID = obj["groupID"].toInt();
            item.zOrder = obj["zOrder"].toInt();
            item.selected = false;
            items_.append(item);
        }
    }
    endResetModel();
    return !items_.isEmpty();
}

void KeyPointAnnotationModel::setLabelID(int index, int labelID) {
    if (index < 0 || index >= items_.size())
        return;
    items_[index].labelID = labelID;
    QModelIndex modelIndex = createIndex(index, 0);
    emit dataChanged(modelIndex, modelIndex, {LabelIDRole});
};

bool KeyPointAnnotationModel::exportAnotation(
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
    return exportYoloAnnotation(exportDir, dataSet, trainSplitRate, labels,
                                templateFile);
}

bool KeyPointAnnotationModel::exportYoloAnnotation(
    const QString &exportDir, const QVector<QPair<QString, QString>> &dataSet,
    double trainSplitRate, const QVector<QString> &labels,
    const QString &templateFile) {
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
    QFile file(templateFile);
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        qWarning() << "无法打开模板文件，关键单检测模型必须指定一个导出模板文件:"
                   << templateFile;
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
    auto jsonArray = obj["kpt_names"].toArray();
    auto keypointNamesMap = parseKeypointNames(jsonArray);

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
        auto groupedItems = groupByGroupID(items_);
        QTextStream out(&file);
        for (const auto &groupedItem : groupedItems.asKeyValueRange()) {
            auto groupID = groupedItem.first;
            auto items = groupedItem.second;
            // YOLO-pose：<class_id> <bbox_cx> <bbox_cy> <bbox_w> <bbox_h> <x0> <y0>
            // <v0> ... v:
            //  0: 关键点不可见
            //  1: 关键点可见但被遮挡
            //  2: 关键点可见且未被遮挡

            QVector<KeyPointAnnotationItem> bboxes;
            QVector<KeyPointAnnotationItem> keypoints;

            for (const auto &item : items) {
                if (item.type == 0) { // 边界框
                    bboxes.append(item);
                } else { // 关键点
                    keypoints.append(item);
                }
            }
            // 每个实例应该有一个边界框和多个关键点
            if (bboxes.isEmpty())
                continue;
            auto bbox = bboxes.first(); // 假设每个实例一个边界框
            // 按标准顺序重新排列关键点
            QVector<KeyPointAnnotationItem> orderedKeypoints =
                reorderKeypoints(keypoints, bbox.labelID, labels, keypointNamesMap);

            QString yoloAnnotationContent;

            // 处理边界框

            QRectF rect(bbox.x, bbox.y, bbox.width, bbox.height);
            auto bboxCenterX = rect.center().x() / imageWidth_;
            auto bboxCenterY = rect.center().y() / imageHeight_;
            auto bboxWidth = rect.width() / imageWidth_;
            auto bboxHeight = rect.height() / imageHeight_;

            yoloAnnotationContent += QString("%1 %2 %3 %4 %5")
                                         .arg(bbox.labelID)
                                         .arg(bboxCenterX, 0, 'f', 6)
                                         .arg(bboxCenterY, 0, 'f', 6)
                                         .arg(bboxWidth, 0, 'f', 6)
                                         .arg(bboxHeight, 0, 'f', 6);

            for (const auto &kp : orderedKeypoints) {
                auto pointX = kp.x / imageWidth_;
                auto pointY = kp.y / imageHeight_;
                int visible = kp.visibleStatus;

                yoloAnnotationContent += QString(" %1 %2 %3")
                                             .arg(pointX, 0, 'f', 6)
                                             .arg(pointY, 0, 'f', 6)
                                             .arg(visible);
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
