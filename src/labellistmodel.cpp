#include "labellistmodel.h"
#include <QIODevice>
#include <QFile>

LabelListModel::LabelListModel(QObject *parent)
    : QAbstractListModel(parent)
{
    connect(this, &QAbstractItemModel::dataChanged, this, &LabelListModel::listModelDataChanged);
    connect(this, &QAbstractItemModel::rowsInserted, this, &LabelListModel::listModelDataChanged);
    connect(this, &QAbstractItemModel::rowsRemoved, this, &LabelListModel::listModelDataChanged);
    connect(this, &QAbstractItemModel::modelReset, this, &LabelListModel::listModelDataChanged);
}

int LabelListModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid())
        return 0;
    return items_.size();
}

QVariant LabelListModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() >= items_.size())
        return QVariant();

    const LabelItem &item = items_.at(index.row());
    switch (role) {
    case LabelRole:
        return item.label;
    case LabelColorRole:
        return item.labelColor;
    default:
        return QVariant();
    }
}

QHash<int, QByteArray> LabelListModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[LabelRole] = "label";
    roles[LabelColorRole] = "labelColor";
    return roles;
}

void LabelListModel::addItem(const QString &label, const QString &labelColor)
{
    beginInsertRows(QModelIndex(), items_.size(), items_.size());
    items_.append({label, labelColor});
    endInsertRows();
}

void LabelListModel::updateItem(int index, const QString &label, const QString &labelColor)
{
    if (index < 0 || index >= items_.size())
        return;

    items_[index] = {label, labelColor};
    QModelIndex modelIndex = createIndex(index, 0);
    emit dataChanged(modelIndex, modelIndex, {LabelRole, LabelColorRole});
}

void LabelListModel::removeItem(int index)
{
    if (index < 0 || index >= items_.size())
        return;

    beginRemoveRows(QModelIndex(), index, index);
    items_.removeAt(index);
    endRemoveRows();
}

void LabelListModel::clear()
{
    if (items_.isEmpty())
        return;

    beginRemoveRows(QModelIndex(), 0, items_.size() - 1);
    items_.clear();
    endRemoveRows();
}

QString LabelListModel::getLabel(int index) const
{
    if (index >= 0 && index < items_.size())
        return items_.at(index).label;
    return QString();
}

QString LabelListModel::getLabelColor(int index) const
{
    if (index >= 0 && index < items_.size())
        return items_.at(index).labelColor;
    return QString();
}

void LabelListModel::setLabel(int index, const QString &label)
{
    if (index < 0 || index >= items_.size() || items_.at(index).label == label)
        return;
    items_[index].label = label;
    QModelIndex modelIndex = createIndex(index, 0);
    emit dataChanged(modelIndex, modelIndex, {LabelRole});
}

void LabelListModel::setLabelColor(int index, const QString &labelColor)
{
    if (index < 0 || index >= items_.size() || items_.at(index).labelColor == labelColor)
        return;

    items_[index].labelColor = labelColor;
    QModelIndex modelIndex = createIndex(index, 0);
    emit dataChanged(modelIndex, modelIndex, {LabelColorRole});
}


QJsonArray LabelListModel::toJsonArray() const
{
    QJsonArray jsonArray;
    for (const LabelItem& item : items_) {
        QJsonObject jsonObj;
        jsonObj["label"] = item.label;
        jsonObj["labelColor"] = item.labelColor;
        jsonArray.append(jsonObj);
    }
    return jsonArray;
}

QString LabelListModel::toJsonString(bool compact) const
{
    QJsonArray jsonArray = toJsonArray();
    QJsonDocument doc(jsonArray);

    if (compact) {
        return doc.toJson(QJsonDocument::Compact);
    } else {
        return doc.toJson(QJsonDocument::Indented);
    }
}

bool LabelListModel::saveToFile(const QString& filePath) const
{
    QFile file(filePath);
    if (!file.open(QIODevice::WriteOnly | QIODevice::Text)) {
        qWarning() << "无法打开文件进行写入:" << filePath;
        return false;
    }
    QJsonArray jsonArray = toJsonArray();
    QJsonDocument doc(jsonArray);
    qint64 bytesWritten = file.write(doc.toJson(QJsonDocument::Indented));
    file.close();
    return bytesWritten > 0;
}

bool LabelListModel::loadFromFile(const QString& filePath)
{
    QFile file(filePath);
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        qWarning() << "无法打开文件进行读取:" << filePath;
        return false;
    }

    QByteArray jsonData = file.readAll();
    file.close();
    QJsonDocument doc = QJsonDocument::fromJson(jsonData);
    if (doc.isNull() || !doc.isArray()) {
        qWarning() << "无效的JSON文件或格式错误";
        return false;
    }
    QJsonArray jsonArray = doc.array();
    // 清空现有数据并加载新数据
    beginResetModel();
    items_.clear();
    for (const QJsonValue& value : std::as_const(jsonArray)) {
        if (value.isObject()) {
            QJsonObject obj = value.toObject();
            LabelItem item;
            item.label = obj["label"].toString();
            item.labelColor = obj["labelColor"].toString();
            items_.append(item);
        }
    }
    endResetModel();
    return true;
}
