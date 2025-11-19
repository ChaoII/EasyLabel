#pragma once

#include <QRect>
#include <QColor>
#include "annotationmodelbase.h"

class DetectionAnnotationModel : public AnnotationModelBase
{
    Q_OBJECT

public:

    struct DetectionAnnotationItem {
        int labelID;
        int x;
        int y;
        int width;
        int height;
        int zOrder;
        bool selected;
    };


    enum DetectionAnnotationRoles {
        LabelIDRole= Qt::UserRole + 1,
        XRole,
        YRole,
        WidthRole,
        HeightRole,
        ZOrderRole,
        SelectedRole
    };

    explicit DetectionAnnotationModel(QObject *parent = nullptr);

    // QAbstractItemModel interface
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    bool setData(const QModelIndex &index, const QVariant &value, int role) override;
    QHash<int, QByteArray> roleNames() const override;

    Q_INVOKABLE void addItem(int lableID, int x,int y,int width,int height,int zOrder, bool selected);

    Q_INVOKABLE void updateItem(int index, int lableID, int x,int y,int width,int height, int zOrder, bool selected);

    Q_INVOKABLE void setSelected(int index, bool selected);

    Q_INVOKABLE void removeItem(int index);

    Q_INVOKABLE void clear();

    Q_INVOKABLE QRect getRect(int index);

    Q_INVOKABLE int getLabelID(int index);

    Q_INVOKABLE void removeAllSelected();

    Q_INVOKABLE void setSingleSelected(int index);

    Q_INVOKABLE int getSelectedIndex(int x, int y);

    Q_INVOKABLE QJsonArray toJsonArray() const;

    Q_INVOKABLE bool saveToFile(const QString& AnnotationFilePath) const override;

    Q_INVOKABLE bool loadFromFile(const QString& AnnotationFilePath);

private:

    QVector<DetectionAnnotationItem> items_;
};

