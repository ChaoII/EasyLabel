#pragma once


#include <QObject>
#include <QQmlEngine>

class AnnotationEnums : public QObject {
    Q_OBJECT
    QML_ELEMENT
public:
    enum AnnotationType { Detection = 0, RotatedBox = 1, Other = 2 };
    enum ExportAnnotationType { YOLO = 0, COCO, VOC };
    Q_ENUM(AnnotationType)
    Q_ENUM(ExportAnnotationType)

};
