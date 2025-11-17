#include "detectionAnnotationmodel.h"

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
    for(int i=0;i<items_.size();i++){
        if(getRect(i).contains(x,y)) return i;
    }
    return -1;
}


