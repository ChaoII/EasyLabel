#pragma once

#include <QObject>
#include <QQmlEngine>
#include "filelistmodel.h"
#include "labellistmodel.h"
#include "detectionAnnotationmodel.h"

class AnnotationConfig: public QObject
{
    Q_OBJECT
    QML_SINGLETON
    QML_ELEMENT

    Q_PROPERTY(QString imageDir READ imageDir WRITE setImageDir NOTIFY imageDirChanged FINAL)
    Q_PROPERTY(QString resultDir READ resultDir WRITE setResultDir NOTIFY resultDirChanged FINAL)
    Q_PROPERTY(LabelListModel* labelListModel READ labelListModel CONSTANT)
    Q_PROPERTY(FileListModel* fileListModel READ fileListModel CONSTANT)
    Q_PROPERTY(DetectionAnnotationModel* currentAnnotationModel READ currentAnnotationModel CONSTANT)
    Q_PROPERTY(int currentIndex READ currentIndex  WRITE setCurrentIndex NOTIFY currentIndexChanged FINAL)



public:

    static AnnotationConfig *instance();

    static AnnotationConfig *create(QQmlEngine *, QJSEngine *);

    QString imageDir();

    QString resultDir();

    LabelListModel* labelListModel();

    FileListModel* fileListModel();

    DetectionAnnotationModel* currentAnnotationModel();

    int currentIndex();

    void setImageDir(const QString& imageDir);

    void setResultDir(const QString& resultDir);

    void setCurrentIndex(int index);

    Q_INVOKABLE void setImageAndResultDir(const QString& imageDir,const QString& resultDir);

    Q_INVOKABLE bool loadLabelFile();

    Q_INVOKABLE bool saveLabelFile();

    Q_INVOKABLE void loadAnnotationFiles();

    Q_INVOKABLE DetectionAnnotationModel* getAnnotationModel(int index);

    Q_INVOKABLE void setAnnotationModel(int index, DetectionAnnotationModel* annotationModel);


signals:
    void imageDirChanged();

    void resultDirChanged();

    void labelListChanged();

    void currentIndexChanged(int index);

private:

    AnnotationConfig(QObject* parent=nullptr);

    int currentIndex_ = 0;
    bool isDirty_ = false;
    QString imageDir_;
    QString resultDir_;
    LabelListModel* labelListModel_;
    FileListModel* fileListModel_;
    QVector<DetectionAnnotationModel*> annotationModelList_;
    static AnnotationConfig* instance_;
};

