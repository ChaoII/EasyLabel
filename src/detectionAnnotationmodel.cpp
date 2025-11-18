#include "detectionAnnotationmodel.h"

#include <QFile>
#include <QIODevice>
#include <QJsonArray>
#include <QJsonObject>

DetectionAnnotationModel::DetectionAnnotationModel(QObject *parent)
    : QAbstractListModel{parent}{}

int DetectionAnnotationModel::rowCount(const QModelIndex &parent) const {
    return parent.isValid() ? 0 : items_.size();
}

QVariant DetectionAnnotationModel::data(const QModelIndex &index, int role) const {
    if (!index.isValid() || index.row() >= items_.size())
        return QVariant();

    const DetectionAnnotationItem &detectionAnnotationItem = items_.at(index.row());
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

bool DetectionAnnotationModel::setData(const QModelIndex &index, const QVariant &value, int role)
{
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
            item.x=value.toInt();
            changed = true;
        }
        break;
    case YRole:
        if(value.canConvert<int>()){
            item.y=value.toInt();
            changed = true;
        }
        break;
    case WidthRole:
        if(value.canConvert<int>()){
            item.width=value.toInt();
            changed = true;
        }
        break;
    case HeightRole:
        if(value.canConvert<int>()){
            item.height=value.toInt();
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
    roles[ZOrderRole] ="zOrder";
    roles[SelectedRole] ="selected";
    return roles;
}

void DetectionAnnotationModel::addItem(int lableID, int x,int y,int width,int height, int zOrder, bool selected)
{
    beginInsertRows(QModelIndex(), items_.size(), items_.size());
    items_.append({lableID, x, y, width, height, zOrder, selected});
    endInsertRows();
}


void DetectionAnnotationModel::updateItem(int index, int lableID, int x,int y,int width,int height, int zOrder, bool selected)
{
    if (index < 0 || index >= items_.size())
        return;
    items_[index] = {lableID, x, y, width, height, zOrder, selected};
    QModelIndex modelIndex = createIndex(index, 0);
    emit dataChanged(modelIndex, modelIndex, {LabelIDRole, XRole, YRole, WidthRole, HeightRole, ZOrderRole, SelectedRole});
}

void DetectionAnnotationModel::setSelected(int index, bool selected){
    if (index < 0 || index >= items_.size())
        return;
    items_[index].selected = selected;
    QModelIndex modelIndex = createIndex(index, 0);
    emit dataChanged(modelIndex, modelIndex, {SelectedRole});
}


void DetectionAnnotationModel::removeItem(int index)
{
    if (index < 0 || index >= items_.size())
        return;
    beginRemoveRows(QModelIndex(), index, index);
    items_.removeAt(index);
    endRemoveRows();
}

void DetectionAnnotationModel::clear()
{
    if (items_.isEmpty())
        return;
    beginRemoveRows(QModelIndex(), 0, items_.size() - 1);
    items_.clear();
    endRemoveRows();
}

QRect DetectionAnnotationModel::getRect(int index){
    if (index < 0 || index >= items_.size())
        return {};
    auto item = items_[index];
    return {item.x, item.y, item.width, item.height};
}

int DetectionAnnotationModel::getLabelID(int index){
    if (index < 0 || index >= items_.size())
        return -1;
    return items_[index].labelID;
}


void DetectionAnnotationModel::removeAllSelected(){
    for(int i=0; i< items_.size();i++){
        setSelected(i, false);
    }
}

void DetectionAnnotationModel::setSingleSelected(int index){
    if (index < 0 || index >= items_.size()) return;
    removeAllSelected();
    setSelected(index, true);
}

int DetectionAnnotationModel::getSelectedIndex(int x, int y){
    for(int i=0; i< items_.size(); i++){
        if(getRect(i).contains(x,y)) return i;
    }
    return -1;
}

QJsonArray DetectionAnnotationModel::toJsonArray() const
{
    QJsonArray jsonArray;
    for (const DetectionAnnotationItem& item : items_) {
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

bool DetectionAnnotationModel::saveToFile(const QString& annotationFilePath) const
{
    QFile file(annotationFilePath);
    if (!file.open(QIODevice::WriteOnly | QIODevice::Text)) {
        qWarning() << "无法打开文件进行写入:" << annotationFilePath;
        return false;
    }
    QJsonArray jsonArray = toJsonArray();
    QJsonObject obj;
    obj["type"] = "detection";
    obj["boxes"] = jsonArray;
    QJsonDocument doc(obj);
    qint64 bytesWritten = file.write(doc.toJson(QJsonDocument::Indented));
    file.close();
    return bytesWritten > 0;
}

bool DetectionAnnotationModel::loadFromFile(const QString& annotationFilePath)
{
    QFile file(annotationFilePath);
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        qWarning() << "无法打开文件进行读取:" << annotationFilePath;
        return false;
    }
    QByteArray jsonData = file.readAll();
    file.close();
    QJsonDocument doc = QJsonDocument::fromJson(jsonData);
    if (doc.isNull() || !doc.isObject()) {
        qWarning() << "无效的JSON文件或格式错误: "<<annotationFilePath;
        return false;
    }
    QJsonObject obj = doc.object();
    QString type = obj["type"].toString();
    QJsonArray jsonArray = doc["boxes"].toArray();
    // 清空现有数据并加载新数据
    beginResetModel();
    items_.clear();
    for (const QJsonValue& value : std::as_const(jsonArray)) {
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


