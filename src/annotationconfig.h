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
    Q_PROPERTY(int currentImageIndex READ currentImageIndex  WRITE setCurrentImageIndex NOTIFY currentImageIndexChanged FINAL)
    Q_PROPERTY(int currentLabelIndex READ currentLabelIndex  NOTIFY currentLabelIndexChanged FINAL)
    Q_PROPERTY(QString currentLabelColor READ currentLabelColor NOTIFY currentLabelColorChanged)
    Q_PROPERTY(QString currentLabel READ currentLabel NOTIFY currentLabelChanged)
    Q_PROPERTY(int currentLineWidth READ currentLineWidth  WRITE setCurrentLineWidth NOTIFY currentLineWidthChanged FINAL)
    Q_PROPERTY(double currentFillOpacity READ currentFillOpacity  WRITE setCurrentFillOpacity NOTIFY currentFillOpacityChanged FINAL)
    Q_PROPERTY(int currentCornerRadius READ currentCornerRadius  WRITE setCurrentCornerRadius NOTIFY currentCornerRadiusChanged FINAL)
    Q_PROPERTY(int currentEdgeWidth READ currentEdgeWidth  WRITE setCurrentEdgeWidth NOTIFY currentEdgeWidthChanged FINAL)
    Q_PROPERTY(int currentEdgeHeight READ currentEdgeHeight  WRITE setCurrentEdgeHeight NOTIFY currentEdgeHeightChanged FINAL)
    Q_PROPERTY(bool showLabel READ showLabel  WRITE setShowLabel NOTIFY showLabelChanged FINAL)
    Q_PROPERTY(int fontPointSize READ fontPointSize  WRITE setFontPointSize NOTIFY fontPointSizeChanged FINAL)
    Q_PROPERTY(int centerPointerSize READ centerPointerSize  WRITE setCenterPointerSize NOTIFY centerPointerSizeChanged FINAL)


public:

    static AnnotationConfig *instance();

    static AnnotationConfig *create(QQmlEngine *, QJSEngine *);

    QString imageDir();

    QString resultDir();


    // style
    int currentLineWidth();
    double currentFillOpacity();
    int currentCornerRadius();
    int currentEdgeWidth();
    int currentEdgeHeight();
    bool showLabel();
    int fontPointSize();
    int centerPointerSize();

    // label
    int currentImageIndex();
    int currentLabelIndex();
    QString currentLabelColor();
    QString currentLabel();
    LabelListModel* labelListModel();
    FileListModel* fileListModel();
    DetectionAnnotationModel* currentAnnotationModel();

    void setImageDir(const QString& imageDir);
    void setResultDir(const QString& resultDir);

    void setCurrentLineWidth(int lineWidth);
    void setCurrentFillOpacity(double fillOpacity);
    void setCurrentCornerRadius(int radius);
    void setCurrentEdgeWidth(int width);
    void setCurrentEdgeHeight(int height);
    void setShowLabel(bool showLabel);
    void setFontPointSize(int fontPointSize);
    void setCenterPointerSize(int pointerSize);

    void setCurrentImageIndex(int index);


    Q_INVOKABLE void setImageAndResultDir(const QString& imageDir,const QString& resultDir);
    Q_INVOKABLE bool loadLabelFile();
    Q_INVOKABLE bool saveLabelFile();
    Q_INVOKABLE void loadAnnotationFiles();
    Q_INVOKABLE bool saveAnnotationFile(int imageIndex);
    Q_INVOKABLE DetectionAnnotationModel* getAnnotationModel(int index);
    Q_INVOKABLE void setAnnotationModel(int index, DetectionAnnotationModel* annotationModel);


signals:
    void imageDirChanged();
    void resultDirChanged();
    // style
    void currentLineWidthChanged();
    void currentFillOpacityChanged();
    void currentCornerRadiusChanged();
    void currentEdgeWidthChanged();
    void currentEdgeHeightChanged();
    void showLabelChanged();
    void fontPointSizeChanged();
    void centerPointerSizeChanged();

    // label
    void currentImageIndexChanged(int preIndex, int nextIndex);
    void currentLabelIndexChanged();
    void currentLabelChanged();
    void currentLabelColorChanged();


private:
    AnnotationConfig(QObject* parent=nullptr);
    static AnnotationConfig* instance_;
    QString imageDir_;
    QString resultDir_;

    // style
    int currentLineWidth_ = 1;
    double currentFillOpacity_ = 1.0;
    int currentCornerRadius_ = 10;
    int currentEdgeWidth_ = 12;
    int currentEdgeHeight_ = 6;
    int fontPointSize_ = 16;
    int centerPointerSize_ = 12;
    bool showLabel_ = true;

    // label
    int currentLabelIndex_ = 0;
    int currentImageIndex_ = 0;
    bool isDirty_ = false;
    LabelListModel* labelListModel_;
    FileListModel* fileListModel_;
    QVector<DetectionAnnotationModel*> annotationModelList_;

};

