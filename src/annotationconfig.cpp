#include "annotationconfig.h"
#include "detectionAnnotationmodel.h"
#include <QDir>
#include <QFile>
#include <QSaveFile>
#include <QModelIndex>


AnnotationConfig::AnnotationConfig(QObject* parent): QObject(parent),
    labelListModel_(new LabelListModel(this)),
    fileListModel_(new FileListModel(this)) {
    connect(labelListModel_, &LabelListModel::listModelDataChanged, this, [this]() {
        if (!saveLabelFile()) {
            qDebug() << "Failed to save label file.";
        }
        emit currentLabelIndexChanged();
        emit currentLabelChanged();
        emit currentLabelColorChanged();
    });
}

QString AnnotationConfig::imageDir() const {
    return imageDir_;
}

QString AnnotationConfig::resultDir() const {
    return resultDir_;
}

QString AnnotationConfig::projectName() const {
    return projectName_;
}

AnnotationConfig::AnnotationType AnnotationConfig::annotationType() const {
    return annotationType_;
}

int AnnotationConfig::totalImageNum() const {
    return totalImageNum_;
}

int AnnotationConfig::annotatedImageNum() const {
    return annotatedImageNum_;
}


LabelListModel* AnnotationConfig::labelListModel() const {
    return labelListModel_;
}

FileListModel* AnnotationConfig::fileListModel() const {
    return fileListModel_;
}

AnnotationModelBase* AnnotationConfig::currentAnnotationModel() {
    if (currentImageIndex_ < 0 || currentImageIndex_ >= annotationModelList_.size())
        return new DetectionAnnotationModel();
    return annotationModelList_[currentImageIndex_];
}

int AnnotationConfig::currentLineWidth() const {
    return currentLineWidth_;
}

double AnnotationConfig::currentFillOpacity() const {
    return currentFillOpacity_;
}

int AnnotationConfig::currentCornerRadius() const {
    return currentCornerRadius_;
}

int AnnotationConfig::currentEdgeWidth() const {
    return currentEdgeWidth_;
}

int AnnotationConfig::currentEdgeHeight() const {
    return currentEdgeHeight_;
}

int AnnotationConfig::currentImageIndex() const {
    return currentImageIndex_;
}

int AnnotationConfig::currentLabelIndex() {
    currentLabelIndex_ = labelListModel_->getFirstSelected();
    return currentLabelIndex_;
}

QString AnnotationConfig::currentLabelColor() const {
    return labelListModel_->getLabelColor(currentLabelIndex_);
}

QString AnnotationConfig::currentLabel() const {
    return labelListModel_->getLabel(currentLabelIndex_);
}

bool AnnotationConfig::showLabel() const {
    return showLabel_;
}

int AnnotationConfig::fontPointSize() const {
    return fontPointSize_;
}

int AnnotationConfig::centerPointerSize() const {
    return centerPointerSize_;
}

void AnnotationConfig::setCurrentLineWidth(int lineWidth) {
    if (currentLineWidth_ != lineWidth) {
        currentLineWidth_ = lineWidth;
        emit currentLineWidthChanged();
    }
}

void AnnotationConfig::setCurrentFillOpacity(double fillOpacity) {
    if (currentFillOpacity_ != fillOpacity) {
        currentFillOpacity_ = fillOpacity;
        emit currentFillOpacityChanged();
    }
}


void AnnotationConfig::setCurrentCornerRadius(int radius) {
    if (currentCornerRadius_ != radius) {
        currentCornerRadius_ = radius;
        emit currentCornerRadiusChanged();
    }
}

void AnnotationConfig::setCurrentEdgeWidth(int width) {
    if (currentEdgeWidth_ != width) {
        currentEdgeWidth_ = width;
        emit currentEdgeWidthChanged();
    }
}

void AnnotationConfig::setCurrentEdgeHeight(int height) {
    if (currentEdgeHeight_ != height) {
        currentEdgeHeight_ = height;
        emit currentEdgeHeightChanged();
    }
}


void AnnotationConfig::setCurrentImageIndex(int index) {
    if (currentImageIndex_ != index) {
        int prewIndex = currentImageIndex_;
        currentImageIndex_ = index;
        qDebug() << "index:"<<index;
        emit currentAnnotationModelChanged();
        emit currentImageIndexChanged(prewIndex, index);
    }
}

void AnnotationConfig::setShowLabel(bool showLabel) {
    if (showLabel_ != showLabel) {
        showLabel_ = showLabel;
        emit showLabelChanged();
    }
}

void AnnotationConfig::setFontPointSize(int fontPointSize) {
    if (fontPointSize_ != fontPointSize) {
        fontPointSize_ = fontPointSize;
        emit fontPointSizeChanged();
    }
}

void AnnotationConfig::setCenterPointerSize(int pointerSize) {
    if (centerPointerSize_ != pointerSize) {
        centerPointerSize_ = pointerSize;
        emit centerPointerSizeChanged();
    }
}


void AnnotationConfig::setImageDir(const QString& imageDir) {
    if (imageDir != imageDir_) {
        setCurrentImageIndex(-1);
        imageDir_ = imageDir;
        fileListModel_->setFolderPath(imageDir_);
        setTotalImageNum(fileListModel_->rowCount());
        if (fileListModel_->rowCount() > 0) {
            setCurrentImageIndex(0);
        }
        emit imageDirChanged();
    }
}

void AnnotationConfig::setResultDir(const QString& resultDir) {
    if (resultDir != resultDir_) {
        resultDir_ = resultDir;
        if (!loadLabelFile()) {
            qDebug() << "Failed to load label file.";
        }
        loadAnnotationFiles();
        emit resultDirChanged();
    }
}

void AnnotationConfig::setProjectName(const QString& projectName) {
    if (projectName_ != projectName) {
        projectName_ = projectName;
        emit projectNameChanged();
    }
}

void AnnotationConfig::setAnnotationType(const AnnotationType& annotationType) {
    if (annotationType_ != annotationType) {
        annotationType_ = annotationType;
        emit annotationTypeChanged();
    }
}

void AnnotationConfig::setTotalImageNum(int totalNum) {
    if (totalImageNum_ != totalNum) {
        totalImageNum_ = totalNum;
        emit totalImageNumChanged();
    }
}

void AnnotationConfig::setAnnotatedImageNum(int annotatedNum) {
    if (annotatedImageNum_ != annotatedNum) {
        annotatedImageNum_ = annotatedNum;
        emit annotatedImageNumChanged();
    }
}


QString AnnotationConfig::getAnnotationTypeColor() const {
    static QVector<QString> palettes = {
        "#F5222D", //red
        "#FA541C", //volcano
        "#FA8C16", //orange
        "#FAAD14", //gold
        "#FADB14", //yellow
        "#A0D911", //lime
        "#52C41A", //green
        "#13C2C2", //cyan
        "#1677FF", //blue
        "#2F54EB", //geekblue
        "#722ED1", //purple
        "#EB2F96", //magenta
        "#666666", //Grey
    };
    const int index = annotationType_;
    if (index < 0) {
        return "black";
    }
    return palettes[index % palettes.size()];
}


QString AnnotationConfig::getAnnotationTypeName() const {
    const QMetaObject* metaObject = &AnnotationConfig::staticMetaObject;
    const int enumIndex = metaObject->indexOfEnumerator("AnnotationType");
    const QMetaEnum metaEnum = metaObject->enumerator(enumIndex);
    return {metaEnum.valueToKey(annotationType_)};
}


void AnnotationConfig::loadAnnotationFiles() {
    const QDir dir(resultDir_);
    if (!dir.exists()) {
        qDebug() << "目录不存在：" << dir;
        return;
    }
    annotationModelList_.clear();
    for (int i = 0; i < fileListModel_->rowCount(); i++) {
        QString annotationBaseFileName = fileListModel_->getResultFilePath(i);
        QString AnnotationFilePath = QDir(resultDir_).absoluteFilePath(annotationBaseFileName);
        // 不存在就创建
        if (!QFile::exists(AnnotationFilePath)) {
            QFile file(AnnotationFilePath);
            if (!file.open(QIODevice::WriteOnly | QIODevice::Text)) {
                qWarning() << "无法打开文件:" << AnnotationFilePath << file.errorString();
                continue;
            }
            file.close();
            continue;
        }
        // 如果存在那么加载annotation
        AnnotationModelBase* annotation = new DetectionAnnotationModel();
        if (annotation->loadFromFile(AnnotationFilePath)) {
            fileListModel_->setAnnotated(i, true);
        }
        annotationModelList_.append(annotation);
    }
    setAnnotatedImageNum(fileListModel_->getAnnotatedNum());
}


bool AnnotationConfig::loadLabelFile() const {
    const QDir dir(resultDir_);
    if (!dir.exists()) {
        qDebug() << "目录不存在：" << dir;
        return false;
    }
    QString labelFilePath = dir.absoluteFilePath("label.json");
    if (!QFile::exists(labelFilePath)) {
        qDebug() << "文件不存在：" << labelFilePath;
        return false;
    }
    if(! labelListModel_->loadFromFile(labelFilePath)){

    }
}


bool AnnotationConfig::saveLabelFile() const {
    if (resultDir_.isEmpty()) {
        qWarning() << "结果目录未设置";
        return false;
    }

    QDir dir(resultDir_);
    if (!dir.exists() && !dir.mkpath(".")) {
        qWarning() << "无法创建目录:" << resultDir_;
        return false;
    }

    const QString labelFilePath = dir.absoluteFilePath("label.json");
    QSaveFile file(labelFilePath);

    if (!file.open(QIODevice::WriteOnly | QIODevice::Text)) {
        qWarning() << "无法打开文件:" << labelFilePath << file.errorString();
        return false;
    }
    return labelListModel_->saveToFile(labelFilePath);
}

bool AnnotationConfig::saveAnnotationFile(const int imageIndex) {
    if (imageIndex < 0 || imageIndex >= annotationModelList_.size()) return false;
    const QString annotationBaseFileName = fileListModel_->getResultFilePath(imageIndex);
    const QString AnnotationFilePath = QDir(resultDir_).absoluteFilePath(annotationBaseFileName);
    if (!annotationModelList_[imageIndex]->saveToFile(AnnotationFilePath)) return false;
    fileListModel_->setAnnotated(imageIndex, true);
    setAnnotatedImageNum(fileListModel_->getAnnotatedNum());
    return true;
}

AnnotationModelBase* AnnotationConfig::getAnnotationModel(const int index) {
    if (index < 0 || index >= annotationModelList_.size()) return nullptr;
    return annotationModelList_[index];
}

void AnnotationConfig::setAnnotationModel(int index, AnnotationModelBase* annotationModel) {
    if (index < 0 || index > annotationModelList_.size()) return;
    annotationModelList_[index] = annotationModel;
}
