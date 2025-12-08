#pragma once

#include "annotationmodelbase.h"
#include <QColor>
#include <QQmlEngine>
#include <QRect>

class RotatedBoxAnnotationModel : public AnnotationModelBase {
    Q_OBJECT
    QML_ELEMENT

public:
    struct RotatedBoxAnnotationItem {
        int labelID;
        int x;
        int y;
        int width;
        int height;
        int zOrder;
        double rotation;
        bool selected;
        int groupID;
        QString description;
    };

    enum RotatedBoxAnnotationRoles {
        LabelIDRole = Qt::UserRole + 1,
        XRole,
        YRole,
        WidthRole,
        HeightRole,
        ZOrderRole,
        RotationRole,
        SelectedRole,
        GroupIDRole,
        DescriptionRole
    };

    explicit RotatedBoxAnnotationModel(QObject *parent = nullptr);

    // QAbstractItemModel interface
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index,
                  int role = Qt::DisplayRole) const override;
    bool setData(const QModelIndex &index, const QVariant &value,
                 int role) override;
    QHash<int, QByteArray> roleNames() const override;

    Q_INVOKABLE bool setProperty(int index, const QString &property,
                                 const QVariant &value);


    Q_INVOKABLE QVariant getProperty(int index, const QString &property);

    Q_INVOKABLE void addItem(int lableID, int x, int y, int width, int height,
                             int zOrder, double rotation, bool selected);

    Q_INVOKABLE void updateItem(int index, int lableID, int x, int y, int width,
                                int height, int zOrder, double rotation,
                                bool selected);

    Q_INVOKABLE void setSelected(int index, bool selected);

    Q_INVOKABLE void removeItem(int index);

    Q_INVOKABLE void clear();

    Q_INVOKABLE QRectF getBoundingBox(int index);

    Q_INVOKABLE QRectF getBoundingBox(const QRectF& rect,double angle);

    Q_INVOKABLE QVector<QPointF> rotatedRectCorners(int index);

    Q_INVOKABLE QRect getRect(int index);

    Q_INVOKABLE double getRotation(int index);

    Q_INVOKABLE int getLabelID(int index);

    Q_INVOKABLE void removeAllSelected();

    Q_INVOKABLE void setSingleSelected(int index);

    Q_INVOKABLE int getSelectedIndex(int x, int y);

    Q_INVOKABLE QJsonArray toJsonArray() const;

    Q_INVOKABLE bool saveToFile(const QString &AnnotationFilePath,
                                int annotationType,
                                const QSize &imageSize) const override;

    Q_INVOKABLE bool loadFromFile(const QString &AnnotationFilePath) override;

    Q_INVOKABLE void setLabelID(int index, int labelID) override;

    Q_INVOKABLE bool
    exportAnotation(const QString &exportDir,
                    const QVector<QPair<QString, QString>> &dataSet,
                    int exportType, double trainSplitRate,const QVector<QString>& labels, const QString &templateFile="") override;

    Q_INVOKABLE bool
    exportYoloAnnotation(const QString &exportDir,
                         const QVector<QPair<QString, QString>> &dataSet,
                         double trainSplitRate, const QVector<QString>& labels);

signals:
    void exportProgress(double progress);

private:
    QString exportDir_;
    bool exportImage_ = false;
    int exportType_ = 0;
    double trainSplitRate_ = 0.8;
    QVector<RotatedBoxAnnotationItem> items_;
};
