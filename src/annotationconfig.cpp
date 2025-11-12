#include "annotationconfig.h"
#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QJsonArray>
#include <QJsonObject>
#include <QJsonParseError>
#include <QJsonDocument>

AnnotationConfig::AnnotationConfig(QObject* parent):QObject(parent) {}


QVariantList AnnotationConfig::loadLabelFile(){
    QDir dir(resultDir_);
    QVariantList list;
    if(!dir.exists()){
        qDebug() << "目录不存在："<< dir;
        return list;
    }

    qDebug()<<"==="<<resultDir_;
    qDebug()<<"+++"<<dir;

    QString labelFilePath = dir.absoluteFilePath("label.json");

    if(!QFile::exists(labelFilePath)){
        qDebug() << "文件不存在："<<labelFilePath;
        return list;
    }
    QFile file(labelFilePath);
    if(!file.open(QIODevice::ReadOnly | QIODevice::Text)){
        qWarning() << "无法打开文件:" << labelFilePath << file.errorString();
        return list;
    }

    QByteArray jsonData = file.readAll();
    file.close();

    if (jsonData.isEmpty()) {
        qWarning() << "文件为空:" << labelFilePath;
        return list;
    }

    QJsonParseError parseError;
    QJsonDocument doc = QJsonDocument::fromJson(jsonData, &parseError);
    if (parseError.error != QJsonParseError::NoError) {
        qWarning() << "JSON 解析错误 - 位置:" << parseError.offset
                   << "错误:" << parseError.errorString();
        return list;
    }

    // 转换为 QVariantList
    if (doc.isArray()) {
        list = doc.array().toVariantList();
        qDebug() << "成功解析数组格式 JSON，包含" << list.size() << "个元素";
    }else {
        qWarning() << "JSON 文档格式不支持";
        return list;
    }

    if (!list.isEmpty()) {
        qDebug() << "第一个标签项:" << list.first();
    }
    return list;
}

QVariantList AnnotationConfig::loadAnnotationFile(){
    QVariantList list;
    return list;
}
