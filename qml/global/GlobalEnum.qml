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
        [AnnotationConfig.Detection]: RemixIcon.CheckboxBlank2Line,
        [AnnotationConfig.RotatedBox]: RemixIcon.DirectionLine,
        [AnnotationConfig.Segmentation]: RemixIcon.Artboard2Fill,
        [AnnotationConfig.KeyPoint]: RemixIcon.Dice4Line,
        [AnnotationConfig.Other]: HusIcon.AliwangwangOutlined
    })
}
