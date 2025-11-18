#pragma once

#include <QAbstractListModel>
#include <QColor>
#include <QTimer>
#include <QJsonArray>
#include <QJsonObject>

class LabelListModel : public QAbstractListModel
{
    Q_OBJECT

public:
    struct LabelItem {
        QString label;
        QString labelColor;
        bool selected;
    };

    enum ItemRoles {
        LabelRole = Qt::UserRole + 1,
        LabelColorRole,
        SelectedRole
    };

    explicit LabelListModel(QObject *parent = nullptr);

    // QAbstractItemModel interface
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    // 自定义方法
    Q_INVOKABLE void addItem(const QString &label, const QString &labelColor);
    Q_INVOKABLE void updateItem(int index, const QString &label, const QString &labelColor);
    Q_INVOKABLE void removeItem(int index);
    Q_INVOKABLE void clear();

    Q_INVOKABLE QString getLabel(int index) const;
    Q_INVOKABLE QString getLabelColor(int index) const;
    Q_INVOKABLE void setLabel(int index, const QString &label);
    Q_INVOKABLE void setLabelColor(int index, const QString &labelColor);
    Q_INVOKABLE void setSelected(int index, bool selected);
    Q_INVOKABLE void setSingleSelected(int index);
    Q_INVOKABLE int getFirstSelected();

    Q_INVOKABLE QJsonArray toJsonArray() const;
    Q_INVOKABLE QString toJsonString(bool compact) const;
    Q_INVOKABLE bool saveToFile(const QString& filePath) const;
    Q_INVOKABLE bool loadFromFile(const QString& filePath);
signals:
    void listModelDataChanged();
private:
    QVector<LabelItem> items_;
};
