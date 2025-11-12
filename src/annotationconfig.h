#pragma once

#include <QObject>
#include <QQmlEngine>

class AnnotationConfig: public QObject
{
    Q_OBJECT
    QML_ELEMENT

    Q_PROPERTY(QString imageDir READ imageDir WRITE setImageDir NOTIFY imageDirChanged)
    Q_PROPERTY(QString resultDir READ resultDir WRITE setResultDir NOTIFY resultDirChanged)

public:
    AnnotationConfig(QObject* parent=nullptr);

    QString imageDir(){
        return imageDir_;
    }

    QString resultDir(){
        return resultDir_;
    }

    void setImageDir(const QString& imageDir){
        if(imageDir!=imageDir_){
            imageDir_ = imageDir;
            emit imageDirChanged();
        }
    }

    void setResultDir(const QString& resultDir){

        if(resultDir!=resultDir_){
            resultDir_ = resultDir;
            emit resultDirChanged();
        }
    }

    Q_INVOKABLE QVariantList loadLabelFile();

    Q_INVOKABLE QVariantList loadAnnotationFile();


signals:
    void imageDirChanged();
    void resultDirChanged();

private:
    QString imageDir_;
    QString resultDir_;

};

