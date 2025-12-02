#pragma once

#include "annotationmodelbase.h"
#include <QColor>
#include <QQmlEngine>
#include <QRect>

class KeyPointAnnotationModel : public AnnotationModelBase {
    Q_OBJECT
    QML_ELEMENT

public:
    struct KeyPointAnnotationItem {
        int labelID;
        double x;
        double y;
        double width;
        double height;
        int type;
        int visibleStatus;
        int groupID;
        int zOrder;
        bool selected;
    };

    enum KeyPointAnnotationRole {
        LabelIDRole = Qt::UserRole + 1,
        XRole,
        YRole,
        WidthRole,
        HeightRole,
        TypeRole,
        VisibleStatusRole,
        GroupIDRole,
        ZOrderRole,
        SelectedRole
    };

    explicit KeyPointAnnotationModel(QObject *parent = nullptr);

    // QAbstractItemModel interface
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index,
                  int role = Qt::DisplayRole) const override;
    bool setData(const QModelIndex &index, const QVariant &value,
                 int role) override;
    QHash<int, QByteArray> roleNames() const override;

    QMap<int, QVector<KeyPointAnnotationItem>>
    groupByGroupID(const QVector<KeyPointAnnotationItem> &items);

    QVector<KeyPointAnnotationItem>
    reorderKeypoints(const QVector<KeyPointAnnotationItem> &keypoints,
                     int classId, const QVector<QString> &labels,
                     const QMap<int, QVector<QString>> &keypointNamesMap);

    QMap<int, QVector<QString>> parseKeypointNames(const QJsonArray &kptNamesArray);

    Q_INVOKABLE bool setProperty(int index, const QString &property,
                                 const QVariant &value);

    Q_INVOKABLE QVariant getProperty(int index, const QString &property);

    Q_INVOKABLE void addItem(int lableID, double x, double y, double width,
                             double height, int type, int visibleStatus,
                             int zOrder, bool selected);

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

    Q_INVOKABLE bool exportAnotation(
        const QString &exportDir, const QVector<QPair<QString, QString>> &dataSet,
        int exportType, double trainSplitRate, const QVector<QString> &labels,
        const QString &templateFile = "") override;

    Q_INVOKABLE bool
    exportYoloAnnotation(const QString &exportDir,
                         const QVector<QPair<QString, QString>> &dataSet,
                         double trainSplitRate, const QVector<QString> &labels,
                         const QString &templateFile);

signals:
    void exportProgress(double progress);

private:
    QString exportDir_;
    bool exportImage_ = false;
    int exportType_ = 0;
    double trainSplitRate_ = 0.8;
    QVector<KeyPointAnnotationItem> items_;
};
