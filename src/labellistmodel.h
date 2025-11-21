#pragma once

#include <QAbstractListModel>
#include <QColor>
#include <QQmlEngine>
#include <QTimer>
#include <QJsonArray>
#include <QJsonObject>

class LabelListModel : public QAbstractListModel {
    Q_OBJECT
    QML_ELEMENT

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

    explicit LabelListModel(QObject* parent = nullptr);

    // QAbstractItemModel interface
    [[nodiscard]] int rowCount(const QModelIndex& parent) const override;
    [[nodiscard]] QVariant data(const QModelIndex& index, int role) const override;
    [[nodiscard]] QHash<int, QByteArray> roleNames() const override;

    // 自定义方法
    Q_INVOKABLE void addItem(const QString& label, const QString& labelColor);
    Q_INVOKABLE void updateItem(int index, const QString& label, const QString& labelColor);
    Q_INVOKABLE void removeItem(int index);
    Q_INVOKABLE void clear();

    Q_INVOKABLE [[nodiscard]] QString getLabel(int index) const;
    Q_INVOKABLE [[nodiscard]] QString getLabelColor(int index) const;
    Q_INVOKABLE void setLabel(int index, const QString& label);
    Q_INVOKABLE void setLabelColor(int index, const QString& labelColor);
    Q_INVOKABLE void setSelected(int index, bool selected);
    Q_INVOKABLE void setSingleSelected(int index);
    Q_INVOKABLE int getFirstSelected();

    Q_INVOKABLE [[nodiscard]] QJsonArray toJsonArray() const;
    Q_INVOKABLE [[nodiscard]] QString toJsonString(bool compact) const;
    Q_INVOKABLE [[nodiscard]] bool saveToFile(const QString& filePath) const;
    Q_INVOKABLE bool loadFromFile(const QString& filePath);
signals:
    void listModelDataChanged();

private:
    QVector<LabelItem> items_;
};
