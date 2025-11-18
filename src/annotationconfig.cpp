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
    fileListModel_(new FileListModel(this)){
    connect(labelListModel_, &LabelListModel::listModelDataChanged, [this]() {
        saveLabelFile();
        emit currentLabelIndexChanged();
        emit currentLabelChanged();
        emit currentLabelColorChanged();
    });
}

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
    if(currentImageIndex_ < 0 || currentImageIndex_ >= annotationModelList_.size())
        return new DetectionAnnotationModel();
    return annotationModelList_[currentImageIndex_];
}

int AnnotationConfig::currentLineWidth(){
    return currentLineWidth_;
}

double AnnotationConfig::currentFillOpacity(){
    return currentFillOpacity_;
}

int AnnotationConfig::currentCornerRadius(){
    return currentCornerRadius_;
}

int AnnotationConfig::currentEdgeWidth(){
    return currentEdgeWidth_;
}

int AnnotationConfig::currentEdgeHeight(){
    return currentEdgeHeight_;
}

int AnnotationConfig::currentImageIndex(){
    return currentImageIndex_;
}

int AnnotationConfig::currentLabelIndex(){
    return labelListModel_->getFirstSelected();
}

QString AnnotationConfig::currentLabelColor(){
    return labelListModel_->getLabelColor(currentLabelIndex_);
}

QString AnnotationConfig::currentLabel(){
    return labelListModel_->getLabel(currentLabelIndex_);
}

bool AnnotationConfig::showLabel(){
    return showLabel_;
}

int AnnotationConfig::fontPointSize(){
    return fontPointSize_;
}

void AnnotationConfig::setCurrentLineWidth(int lineWidth){
    if(currentLineWidth_ != lineWidth){
        currentLineWidth_ = lineWidth;
        emit currentLineWidthChanged();
    }
}

void AnnotationConfig::setCurrentFillOpacity(double fillOpacity){
    if(currentFillOpacity_ != fillOpacity){
        currentFillOpacity_ = fillOpacity;
        emit currentFillOpacityChanged();
    }
}


void AnnotationConfig::setCurrentCornerRadius(int radius){
    if(currentCornerRadius_ != radius){
        currentCornerRadius_ = radius;
        emit currentCornerRadiusChanged();
    }
}

void AnnotationConfig::setCurrentEdgeWidth(int width){
    if(currentEdgeWidth_ != width){
        currentEdgeWidth_ = width;
        emit currentEdgeWidthChanged();
    }
}

void AnnotationConfig::setCurrentEdgeHeight(int height){
    if(currentEdgeHeight_ != height){
        currentEdgeHeight_ = height;
        emit currentEdgeHeightChanged();
    }
}


void AnnotationConfig::setCurrentImageIndex(int index){
    if(currentImageIndex_ != index){
        currentImageIndex_ = index;
        emit currentImageIndexChanged();
    }
}


void AnnotationConfig::setShowLabel(bool showLabel){
    if(showLabel_ != showLabel){
        showLabel_ = showLabel;
        emit showLabelChanged();
    }
}

void AnnotationConfig::setFontPointSize(int fontPointSize){
    if(fontPointSize_ != fontPointSize){
        fontPointSize_ = fontPointSize;
        emit fontPointSizeChanged();
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
        // 如果存在那么加载annotation
        DetectionAnnotationModel * annotaiton = new DetectionAnnotationModel();
        annotaiton->addItem(0,10,10,200,200,-1,false);
        annotationModelList_.append(annotaiton);
    }
}


bool AnnotationConfig::loadLabelFile(){
    QDir dir(resultDir_);
    if(!dir.exists()){
        qDebug() << "目录不存在："<< dir;
        return false;
    }
    QString labelFilePath = dir.absoluteFilePath("label.json");
    if(!QFile::exists(labelFilePath)){
        qDebug() << "文件不存在："<<labelFilePath;
        return false;
    }
    return labelListModel_->loadFromFile(labelFilePath);
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
    return labelListModel_->saveToFile(labelFilePath);
}


DetectionAnnotationModel* AnnotationConfig::getAnnotationModel(int index){
    if(index<0 || index>annotationModelList_.size()) return nullptr;
    return annotationModelList_[index];
}

void AnnotationConfig::setAnnotationModel(int index, DetectionAnnotationModel* annotationModel){
    if(index<0 || index>annotationModelList_.size()) return;
    annotationModelList_[index] = annotationModel;
}
