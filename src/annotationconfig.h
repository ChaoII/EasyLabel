#pragma once

#include <QObject>
#include <QQmlEngine>
#include "labellistmodel.h"

class AnnotationConfig: public QObject
{
    Q_OBJECT
    QML_SINGLETON
    QML_ELEMENT

    Q_PROPERTY(QString imageDir READ imageDir WRITE setImageDir NOTIFY imageDirChanged FINAL)
    Q_PROPERTY(QString resultDir READ resultDir WRITE setResultDir NOTIFY resultDirChanged FINAL)
    Q_PROPERTY(LabelListModel* labelListModel READ labelListModel CONSTANT)


public:

    static AnnotationConfig *instance();

    static AnnotationConfig *create(QQmlEngine *, QJSEngine *);

    QString imageDir();

    QString resultDir();

    LabelListModel* labelListModel();

    void setImageDir(const QString& imageDir);

    void setResultDir(const QString& resultDir);




    Q_INVOKABLE void setImageAndResultDir(const QString& imageDir,const QString& resultDir);

    Q_INVOKABLE void loadLabelFile();

    Q_INVOKABLE bool saveLabelFile();

    Q_INVOKABLE QVariantList loadAnnotationFile();

    Q_INVOKABLE QString getLabelColor(const QString& label);

signals:
    void imageDirChanged();

    void resultDirChanged();

    void labelListChanged();

private:

    AnnotationConfig(QObject* parent=nullptr);

    void updateLabelProperty(int index, const QString& key, const QVariant& value);

    bool isDirty_ = false;
    QString imageDir_;
    QString resultDir_;
    LabelListModel* labelListModel_;
    static AnnotationConfig* instance_;
};

