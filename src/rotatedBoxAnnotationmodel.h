#pragma once

#include "annotationmodelbase.h"
#include <QColor>
#include <QQmlEngine>
#include <QRect>

class RotationBoxAnnotationModel : public AnnotationModelBase {
    Q_OBJECT
    QML_ELEMENT

public:
    struct RotatedBoxAnnotationItem {
        int labelID;
        QVariantList points;
        int zOrder;
        bool selected;
    };

    enum RotatedBoxAnnotationRoles {
        LabelIDRole = Qt::UserRole + 1,
        PointsRole,
        ZOrderRole,
        SelectedRole
    };

    explicit RotationBoxAnnotationModel(QObject *parent = nullptr);

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

    Q_INVOKABLE void addItem(int lableID, const QVariantList& points,
                             int zOrder,  bool selected);

    Q_INVOKABLE int getPointSize(int index);

    Q_INVOKABLE QVariantList getPoints(int index);

    Q_INVOKABLE void appendPoint(int index, const QPointF& point);

    Q_INVOKABLE void updatePoint(int index, int pointIndex, const QPointF& point);

    Q_INVOKABLE void updateLastPoint(int index, const QPointF& point);

    Q_INVOKABLE void moveShape(int index, const QPointF& dPoint);

    Q_INVOKABLE void popFrontPoint(int index);

    Q_INVOKABLE void popBackPoint(int index);

    Q_INVOKABLE void setSelected(int index, bool selected);

    Q_INVOKABLE void removeItem(int index);

    Q_INVOKABLE void clear();


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
                    int exportType, double trainSplitRate, const QVector<QString>& labels) override;

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
