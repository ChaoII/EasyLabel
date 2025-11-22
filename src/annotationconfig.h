#pragma once

#include "annotationmodelbase.h"
#include "filelistmodel.h"
#include "labellistmodel.h"
#include <QObject>
#include <QQmlEngine>

class AnnotationConfig : public QObject {
    Q_OBJECT
    QML_ELEMENT

    Q_PROPERTY(QString imageDir READ imageDir WRITE setImageDir NOTIFY
                   imageDirChanged FINAL)
    Q_PROPERTY(QString resultDir READ resultDir WRITE setResultDir NOTIFY
                   resultDirChanged FINAL)
    Q_PROPERTY(QString projectName READ projectName WRITE setProjectName NOTIFY
                   projectNameChanged FINAL)
    Q_PROPERTY(AnnotationType annotationType READ annotationType WRITE
                   setAnnotationType NOTIFY annotationTypeChanged FINAL)
    Q_PROPERTY(int totalImageNum READ totalImageNum WRITE setTotalImageNum NOTIFY
                   totalImageNumChanged FINAL)
    Q_PROPERTY(int annotatedImageNum READ annotatedImageNum WRITE
                   setAnnotatedImageNum NOTIFY annotatedImageNumChanged FINAL)

    Q_PROPERTY(LabelListModel *labelListModel READ labelListModel CONSTANT)
    Q_PROPERTY(FileListModel *fileListModel READ fileListModel CONSTANT)
    Q_PROPERTY(AnnotationModelBase *currentAnnotationModel READ
                   currentAnnotationModel NOTIFY currentAnnotationModelChanged)
    Q_PROPERTY(int currentImageIndex READ currentImageIndex WRITE
                   setCurrentImageIndex NOTIFY currentImageIndexChanged FINAL)
    Q_PROPERTY(int currentLabelIndex READ currentLabelIndex NOTIFY
                   currentLabelIndexChanged FINAL)
    Q_PROPERTY(QString currentLabelColor READ currentLabelColor NOTIFY
                   currentLabelColorChanged)
    Q_PROPERTY(QString currentLabel READ currentLabel NOTIFY currentLabelChanged)
    Q_PROPERTY(int currentLineWidth READ currentLineWidth WRITE
                   setCurrentLineWidth NOTIFY currentLineWidthChanged FINAL)
    Q_PROPERTY(double currentFillOpacity READ currentFillOpacity WRITE
                   setCurrentFillOpacity NOTIFY currentFillOpacityChanged FINAL)
    Q_PROPERTY(int currentCornerRadius READ currentCornerRadius WRITE
                   setCurrentCornerRadius NOTIFY currentCornerRadiusChanged FINAL)
    Q_PROPERTY(int currentEdgeWidth READ currentEdgeWidth WRITE
                   setCurrentEdgeWidth NOTIFY currentEdgeWidthChanged FINAL)
    Q_PROPERTY(int currentEdgeHeight READ currentEdgeHeight WRITE
                   setCurrentEdgeHeight NOTIFY currentEdgeHeightChanged FINAL)
    Q_PROPERTY(bool showLabel READ showLabel WRITE setShowLabel NOTIFY
                   showLabelChanged FINAL)
    Q_PROPERTY(int fontPointSize READ fontPointSize WRITE setFontPointSize NOTIFY
                   fontPointSizeChanged FINAL)
    Q_PROPERTY(int centerPointerSize READ centerPointerSize WRITE
                   setCenterPointerSize NOTIFY centerPointerSizeChanged FINAL)

public:
    enum AnnotationType { Detection = 0, RotatedBox = 1, Other = 2 };

    Q_ENUM(AnnotationType)
    explicit AnnotationConfig(QObject *parent = nullptr);
    [[nodiscard]] QString imageDir() const;
    [[nodiscard]] QString resultDir() const;
    [[nodiscard]] QString projectName() const;
    [[nodiscard]] AnnotationType annotationType() const;
    [[nodiscard]] int totalImageNum() const;
    [[nodiscard]] int annotatedImageNum() const;

    // style
    [[nodiscard]] int currentLineWidth() const;
    [[nodiscard]] double currentFillOpacity() const;
    [[nodiscard]] int currentCornerRadius() const;
    [[nodiscard]] int currentEdgeWidth() const;
    [[nodiscard]] int currentEdgeHeight() const;
    [[nodiscard]] bool showLabel() const;
    [[nodiscard]] int fontPointSize() const;
    [[nodiscard]] int centerPointerSize() const;

    // label
    [[nodiscard]] int currentImageIndex() const;
    int currentLabelIndex();
    [[nodiscard]] QString currentLabelColor() const;
    [[nodiscard]] QString currentLabel() const;
    [[nodiscard]] LabelListModel *labelListModel() const;
    [[nodiscard]] FileListModel *fileListModel() const;
    AnnotationModelBase *currentAnnotationModel();

    //
    void setImageDir(const QString &imageDir);
    void setResultDir(const QString &resultDir);
    void setProjectName(const QString &projectName);
    void setAnnotationType(const AnnotationType &type);
    void setTotalImageNum(int totalNum);
    void setAnnotatedImageNum(int annotatedNum);
    //
    void setCurrentLineWidth(int lineWidth);
    void setCurrentFillOpacity(double fillOpacity);
    void setCurrentCornerRadius(int radius);
    void setCurrentEdgeWidth(int width);
    void setCurrentEdgeHeight(int height);
    void setShowLabel(bool showLabel);
    void setFontPointSize(int fontPointSize);
    void setCenterPointerSize(int pointerSize);
    void setCurrentImageIndex(int index);

    Q_INVOKABLE QString getAnnotationTypeColor() const;
    Q_INVOKABLE QString getAnnotationTypeName() const;

    Q_INVOKABLE bool loadLabelFile() const;
    Q_INVOKABLE bool saveLabelFile() const;
    Q_INVOKABLE void loadAnnotationFiles();
    Q_INVOKABLE bool saveAnnotationFile(int imageIndex);
    Q_INVOKABLE AnnotationModelBase *getAnnotationModel(int index);
    Q_INVOKABLE void setAnnotationModel(int index,
                                        AnnotationModelBase *annotationModel);

signals:
    void imageDirChanged();
    void resultDirChanged();
    void projectNameChanged();
    void annotationTypeChanged();
    void totalImageNumChanged();
    void annotatedImageNumChanged();

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
    void currentAnnotationModelChanged();

private:
    QString imageDir_;
    QString resultDir_;
    int totalImageNum_{};
    int annotatedImageNum_{};
    QString projectName_;
    AnnotationType annotationType_ = AnnotationType::Detection;

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

    int currentLabelIndex_ = -1;
    int currentImageIndex_ = -1;
    bool isDirty_ = false;
    LabelListModel *labelListModel_;
    FileListModel *fileListModel_;
    QVector<AnnotationModelBase *> annotationModelList_;
};
