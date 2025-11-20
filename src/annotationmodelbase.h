#pragma once
#include <QAbstractListModel>

class AnnotationModelBase : public QAbstractListModel
{
    Q_OBJECT
public:
    explicit AnnotationModelBase(QObject *parent = nullptr);

    Q_INVOKABLE virtual bool saveToFile(const QString& AnnotationFilePath) const = 0;

    Q_INVOKABLE virtual bool loadFromFile(const QString& AnnotationFilePath) = 0;

    Q_INVOKABLE virtual void setLabelID(int index, int labelID) = 0;


signals:
};

