#pragma once

#include <QQmlEngine>
#include <QAbstractListModel>

class AnnotationModelBase : public QAbstractListModel
{
    Q_OBJECT

public:
    explicit AnnotationModelBase(QObject *parent = nullptr);

    Q_INVOKABLE virtual bool saveToFile(const QString& AnnotationFilePath, int annotationType, const QSize& imageSize) const = 0;

    Q_INVOKABLE virtual bool loadFromFile(const QString& AnnotationFilePath) = 0;

    Q_INVOKABLE virtual void setLabelID(int index, int labelID) = 0;

    Q_INVOKABLE virtual int getImageWidth(){
        return imageWidth_;
    }

    Q_INVOKABLE virtual int getImageHeight(){
        return imageHeight_;
    }


signals:

protected:
    int annotationType_ = 0;
    int imageWidth_ = 0;
    int imageHeight_ = 0;
};

