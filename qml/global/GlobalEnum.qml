pragma Singleton
import QtQuick
import EasyLabel
import HuskarUI.Basic

QtObject {

    enum DialogMode {
        Create = 0,
        Edit = 1
    }


    property var annotationIconTextMap:({
        [AnnotationConfig.Detection]: HusIcon.BorderOutlined,
        [AnnotationConfig.RotatedBox]: HusIcon.AppleOutlined,
        [AnnotationConfig.Segmentation]: HusIcon.AlertOutlined,
        [AnnotationConfig.Other]: HusIcon.AliwangwangOutlined
    })
}
