#include "annotationconfig.h"
#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QJsonArray>
#include <QJsonObject>
#include <QJsonParseError>
#include <QJsonDocument>
#include <QSaveFile>
#include <QModelIndex>


AnnotationConfig* AnnotationConfig::instance_ = nullptr;

AnnotationConfig::AnnotationConfig(QObject* parent):QObject(parent),
    labelListModel_(new LabelListModel(this)),
    fileListModel_(new FileListModel(this)){}

AnnotationConfig* AnnotationConfig::instance(){
    if(!instance_){
        instance_ = new AnnotationConfig();
    }
    return instance_;
}

AnnotationConfig *AnnotationConfig::create(QQmlEngine *, QJSEngine *){
    return instance();
}

QString AnnotationConfig::imageDir(){
    return imageDir_;
}

QString AnnotationConfig::resultDir(){
    return resultDir_;
}

LabelListModel* AnnotationConfig::labelListModel(){
    return labelListModel_;
}

FileListModel* AnnotationConfig::fileListModel(){
    return fileListModel_;
}

DetectionAnnotationModel* AnnotationConfig::currentAnnotationModel(){
    if(currentIndex_ < 0 && currentIndex_ >= annotationModelList_.size())
    return annotationModelList_[currentIndex_];
}

int AnnotationConfig::currentIndex(){
    return currentIndex_;
}

void AnnotationConfig::setCurrentIndex(int index){
    if(currentIndex_ != index){
        currentIndex_ = index;
        emit currentIndexChanged(index);
    }
}


void AnnotationConfig::setImageDir(const QString& imageDir){
    if(imageDir != imageDir_){
        imageDir_ = imageDir;
        fileListModel_->setFolderPath(imageDir_);
        emit imageDirChanged();
    }
}

void AnnotationConfig::setResultDir(const QString& resultDir){
    if(resultDir != resultDir_){
        resultDir_ = resultDir;
        loadLabelFile();
        loadAnnotationFiles();
        emit resultDirChanged();
    }
}

void AnnotationConfig::setImageAndResultDir(const QString& imageDir, const QString& resultDir){
    setResultDir(resultDir);
    setImageDir(imageDir);
}

void AnnotationConfig::loadAnnotationFiles(){
    QDir dir(resultDir_);
    if(!dir.exists()){
        qDebug() << "目录不存在："<< dir;
        return;
    }
    for(int i=0; i < fileListModel_->rowCount(); i++){
        QString annotationBaseFileName = fileListModel_->getResultFilePath(i);
        QString AnnotationFilePath = QDir(resultDir_).absoluteFilePath(annotationBaseFileName);
        // 不存在就创建
        if(!QFile::exists(AnnotationFilePath)){
            QFile file(AnnotationFilePath);
            if(!file.open(QIODevice::WriteOnly | QIODevice::Text)){
                qWarning() << "无法打开文件:" << AnnotationFilePath << file.errorString();
                continue;
            }
            file.close();
            continue;
        }
        // 存在就解析
        DetectionAnnotationModel* annotationModel = new DetectionAnnotationModel(this);
        annotationModel->addItem(0,10,10,200,100);
        annotationModelList_.append(annotationModel);
    }
}


void AnnotationConfig::loadLabelFile(){
    QDir dir(resultDir_);
    if(!dir.exists()){
        qDebug() << "目录不存在："<< dir;
        return;
    }

    QString labelFilePath = dir.absoluteFilePath("label.json");

    if(!QFile::exists(labelFilePath)){
        qDebug() << "文件不存在："<<labelFilePath;
        return;
    }
    QFile file(labelFilePath);
    if(!file.open(QIODevice::ReadOnly | QIODevice::Text)){
        qWarning() << "无法打开文件:" << labelFilePath << file.errorString();
        return;
    }

    QByteArray jsonData = file.readAll();
    file.close();

    if (jsonData.isEmpty()) {
        qWarning() << "文件为空:" << labelFilePath;
        return;
    }

    QJsonParseError parseError;
    QJsonDocument doc = QJsonDocument::fromJson(jsonData, &parseError);
    if (parseError.error != QJsonParseError::NoError) {
        qWarning() << "JSON 解析错误 - 位置:" << parseError.offset
                   << "错误:" << parseError.errorString();
        return;
    }
    // 转换为 QVariantList
    if (doc.isArray()) {
        QVariantList list = doc.array().toVariantList();
        for(int i=0;i<list.count();i++){
            QVariantMap map = list[i].toMap();
            if(map.contains("label") && map.contains("labelColor")){
                labelListModel_->addItem(map.value("label").toString(), map.value("labelColor").toString());
            }
        }
        qDebug() << "成功解析数组格式 JSON，包含" << list.size() << "个元素";
    }else {
        qWarning() << "JSON 文档格式不支持";
        return;
    }
}


bool AnnotationConfig::saveLabelFile(){
    if (resultDir_.isEmpty()) {
        qWarning() << "结果目录未设置";
        return false;
    }

    QDir dir(resultDir_);
    if (!dir.exists() && !dir.mkpath(".")) {
        qWarning() << "无法创建目录:" << resultDir_;
        return false;
    }

    QString labelFilePath = dir.absoluteFilePath("label.json");
    QSaveFile file(labelFilePath);

    if (!file.open(QIODevice::WriteOnly | QIODevice::Text)) {
        qWarning() << "无法打开文件:" << labelFilePath << file.errorString();
        return false;
    }

    // 转换数据
    QJsonArray jsonArray;
    for(int i=0;i<labelListModel_->rowCount();i++){
        QString label = labelListModel_->getLabel(i);
        QString labelColor = labelListModel_->getLabelColor(i);
        QVariantMap map;
        map.insert("label",label);
        map.insert("labelColor",labelColor);
        jsonArray.append(QJsonObject::fromVariantMap(map));
    }

    // 写入文件
    QJsonDocument doc(jsonArray);
    file.write(doc.toJson(QJsonDocument::Indented));

    // 提交保存（原子操作）
    if (!file.commit()) {
        qWarning() << "保存文件失败:" << file.errorString();
        return false;
    }
    qDebug() << "成功保存" << jsonArray.size() << "个标签到:" << labelFilePath;
    return true;
}


DetectionAnnotationModel* AnnotationConfig::getAnnotationModel(int index){
    if(index<0 || index>annotationModelList_.size()) return nullptr;
    return annotationModelList_[index];
}

