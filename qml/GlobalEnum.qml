pragma Singleton
import QtQuick

QtObject {

    enum DialogMode {
        Create = 0,
        Edit = 1
    }

    enum AnnotationType {
        Detection = 0,
        RotatedBox = 1,
        Other = 2
    }

    property var annotationTypeStringMap: ({
        [GlobalEnum.AnnotationType.Detection]: "Detection",
        [GlobalEnum.AnnotationType.RotatedBox]: "RotatedBox",
        [GlobalEnum.AnnotationType.Other]: "Other"
    })

}
