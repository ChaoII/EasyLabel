import QtQuick
import QtQuick.Layouts
import HuskarUI.Basic
import QtQuick.Controls
import EasyLabel

Item{
    id: centralAnnotationView
    required property AnnotationConfig annotationConfig
    property int drawStatus: CanvasEnums.OptionStatus.Select
    readonly property int currentImageIndex: annotationConfig.currentImageIndex
    property int labelNum: drawerLayer.item && drawerLayer.item.listModel ?
                               drawerLayer.item.listModel.rowCount() : 0

    Flickable {
        id: flickable
        visible: centralAnnotationView.annotationConfig.fileListModel.rowCount() > 0
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: footer.top
        anchors.bottomMargin: 4
        ScrollBar.vertical: HusScrollBar{policy: HusScrollBar.AsNeeded}
        ScrollBar.horizontal:  HusScrollBar{policy: HusScrollBar.AsNeeded}
        clip: true

        // Flickable 的内容大小由图片缩放后的尺寸决定
        contentWidth: Math.max(imageContainer.width * imageContainer.scale, width)
        contentHeight: Math.max(imageContainer.height * imageContainer.scale, height)

        // 图片缩放范围
        property real minScale: 0.3
        property real maxScale: 3.0
        property alias fitScale: imageContainer.scale
        property real zoomFactor: 1.1

        // 鼠标滚轮缩放
        WheelHandler {
            id: wheelHandler
            onWheel: function(wheel) {
                var _zoomFactor = flickable.zoomFactor
                if (wheel.angleDelta.y < 0)
                    _zoomFactor = 1 / flickable.zoomFactor
                flickable.zoom(_zoomFactor)
            }
        }
        // 图片以实际图像的尺寸大小为准 ＋ 标注层
        Item {
            id: imageContainer
            width: image.sourceSize.width
            height: image.sourceSize.height
            transformOrigin: Item.Center
            anchors.centerIn: parent
            property string imageSource : centralAnnotationView.annotationConfig.fileListModel.getFullPath(centralAnnotationView.currentImageIndex)
            // 初始缩放比例设置为适合窗口
            scale: 1.0

            Image {
                id: image
                source: imageContainer.imageSource ? "file:///" + imageContainer.imageSource: ""
                anchors.fill: parent
            }
            Component.onCompleted: {
                if(imageContainer.width <= 0 ||imageContainer.height <= 0 ){
                    imageContainer.scale = 1.0
                }
            }

            Loader{
                id: drawerLayer
                anchors.fill: parent
                sourceComponent: {
                    switch (annotationConfig.annotationType){
                    case  AnnotationConfig.Detection:
                        return detectionLabelLayerComponent
                    case AnnotationConfig.RotatedBox:
                        return rotatedBoxLabelLayerComponent
                    case AnnotationConfig.Segmentation:
                        return segmentationLabelLayerComponent
                    case AnnotationConfig.KeyPoint:
                        return keyPointLabelLayerComponent
                    default:
                        return detectionLabelLayerComponent
                    }
                }
                onLoaded: {
                    // 创建动态绑定
                    item.annotationConfig = Qt.binding(
                                ()=> {
                                    return centralAnnotationView.annotationConfig
                                })
                    item.drawStatus = Qt.binding(
                                () =>{
                                    return centralAnnotationView.drawStatus
                                })
                    item.scaleFactor = Qt.binding(
                                () =>{
                                    return imageContainer.scale
                                })
                }
                Connections{
                    ignoreUnknownSignals: true
                    enabled: drawerLayer.status === Loader.Ready
                    target: drawerLayer.item.listModel
                    function onDataChanged(){
                        centralAnnotationView.labelNum = drawerLayer.item.listModel.rowCount()
                    }
                }
            }
        }


        // 放大
        function zoomIn(){
            zoom(flickable.zoomFactor)
        }
        function zoomOut(){
            zoom(1/flickable.zoomFactor)
        }

        function zoom(zoomFactor){
            var oldScale = imageContainer.scale
            var newScale = imageContainer.scale * zoomFactor
            newScale = Math.max(flickable.minScale, Math.min(newScale, flickable.maxScale))
            if (oldScale !== newScale) {

                // 缩放中心固定为 Flickable 中心
                var centerX = flickable.width / 2
                var centerY = flickable.height / 2

                // 缩放前中心对应的内容坐标
                var contentPosX = flickable.contentX + centerX
                var contentPosY = flickable.contentY + centerY

                // 应用缩放
                imageContainer.scale = newScale

                // 缩放后内容保持中心不变
                var newContentX = contentPosX * (newScale / oldScale) - centerX
                var newContentY = contentPosY * (newScale / oldScale) - centerY

                // 关键：限制在有效范围内（防止跑到四个角）
                flickable.contentX = Math.max(0, Math.min(newContentX, flickable.contentWidth  - flickable.width))
                flickable.contentY = Math.max(0, Math.min(newContentY, flickable.contentHeight - flickable.height))
            }
        }

        // 适合窗口大小的函数
        function fitToWindow() {
            if(flickable.width<=0
                    || flickable.height<=0
                    || imageContainer.width<=0
                    || imageContainer.height<=0 ) return
            imageContainer.scale = Math.min(flickable.width / imageContainer.width,
                                            flickable.height / imageContainer.height)
        }
        onWidthChanged: {
            flickable.fitToWindow()
        }
        onHeightChanged: {
            flickable.fitToWindow()
        }
    }

    Item{
        id: footer
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: 40
        Connections{
            target: centralAnnotationView.annotationConfig
            function onCurrentImageIndexChanged(pre, next){
                if(centralAnnotationView.annotationConfig.saveAnnotationFile(pre)){
                    QmlGlobalHelper.message.success("标注保存成功")
                }
                flickable.fitToWindow()
            }
        }

        HusCard{
            anchors.fill: parent
            bodyDelegate: null
            titleDelegate: null
            radius: 0
            border.color:"transparent"
            RowLayout{
                anchors.fill: parent
                anchors.leftMargin: 10
                anchors.rightMargin: 10

                HusIconButton{
                    Layout.preferredWidth: 30
                    Layout.preferredHeight: 30
                    iconSize: 20
                    iconSource: HusIcon.LineOutlined
                    radiusBg.all: 0
                    onClicked:{
                        flickable.zoomOut()
                    }
                }

                HusText{
                    text:"缩放: "
                }

                HusText{
                    Layout.preferredWidth:60
                    text: Math.round(imageContainer.scale * 100) + "%"
                }
                HusIconButton{
                    Layout.preferredWidth: 30
                    Layout.preferredHeight: 30
                    iconSize: 20
                    iconSource: HusIcon.PlusOutlined
                    radiusBg.all: 0
                    onClicked:{
                        flickable.zoomIn()
                    }
                }

                HusIconButton{
                    id: btnFit
                    Layout.preferredWidth: 30
                    Layout.preferredHeight: 30
                    iconSize: 20
                    radiusBg.all: 0
                    iconSource:HusIcon.ExpandOutlined
                    onClicked: {
                        flickable.fitToWindow()
                    }
                }

                HusDivider{
                    Layout.preferredHeight:30
                    orientation: Qt.Vertical
                }

                HusText{
                    text:"标签数："+ centralAnnotationView.labelNum
                }

                HusDivider{
                    Layout.preferredHeight:30
                    orientation: Qt.Vertical
                }

                HusIconButton{
                    enabled: centralAnnotationView.annotationConfig.currentImageIndex > 0
                    Layout.preferredWidth: 30
                    Layout.preferredHeight: 30
                    iconSize: 20
                    iconSource: HusIcon.LeftOutlined
                    radiusBg.all: 0
                    onClicked: {
                        centralAnnotationView.annotationConfig.currentImageIndex -= 1
                    }
                }

                HusInput{
                    id: inputControl
                    Layout.minimumWidth: 30
                    Layout.maximumWidth: 60
                    text: centralAnnotationView.annotationConfig.currentImageIndex + 1
                    background: HusRectangle {
                        anchors.bottom: parent.bottom
                        height: 1
                        color: inputControl.colorBg
                        border.color: inputControl.colorBorder
                    }
                    validator: IntValidator {
                        id: indexValidator
                        bottom: 1
                        top: Math.max(1, centralAnnotationView.annotationConfig.fileListModel.rowCount())
                    }
                    Keys.onPressed: function(event)  {
                        if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                            if(parseInt(text) === 0) return
                            centralAnnotationView.annotationConfig.currentImageIndex = parseInt(text) - 1
                        }
                    }

                    onFocusChanged: {
                        if(!focus){
                            if(text === "" || parseInt(text) === 0) return
                            centralAnnotationView.annotationConfig.currentImageIndex = parseInt(text) - 1
                        }
                    }
                }

                HusText{
                    text: "/"
                }

                HusText{
                    text: centralAnnotationView.annotationConfig.fileListModel.rowCount()
                }

                HusIconButton{
                    enabled: centralAnnotationView.annotationConfig.currentImageIndex < centralAnnotationView.annotationConfig.fileListModel.rowCount() -1
                    Layout.preferredWidth: 30
                    Layout.preferredHeight: 30
                    iconSize: 20
                    iconSource: HusIcon.RightOutlined
                    radiusBg.all: 0
                    onClicked: {
                        centralAnnotationView.annotationConfig.currentImageIndex += 1
                    }
                }

                HusDivider{
                    Layout.preferredHeight: 30
                    orientation: Qt.Vertical
                }

                ButtonGroup {
                    id: radioGroup
                    buttons:[btnSelect, btnRectangle,btnRotatedBox,btnPolygon,btnPoint]
                }

                HusIconButton{
                    id: btnSelect
                    Layout.preferredWidth: 30
                    Layout.preferredHeight: 30
                    iconSize: 20
                    iconFontFamily: "remixicon"
                    iconSource: RemixIcon.CursorFill
                    radiusBg.all: 0
                    checkable: true
                    onClicked: {
                        centralAnnotationView.drawStatus = CanvasEnums.Select
                        flickable.interactive = true
                    }
                }

                HusIconButton{
                    id:btnRectangle
                    visible: annotationConfig.annotationType === AnnotationConfig.Detection||
                             annotationConfig.annotationType === AnnotationConfig.KeyPoint
                    Layout.preferredWidth: 30
                    Layout.preferredHeight: 30
                    iconSize: 20
                    iconFontFamily: "remixicon"
                    iconSource: RemixIcon.CheckboxBlank2Line
                    radiusBg.all: 0
                    checkable: true
                    onClicked: {
                        centralAnnotationView.drawStatus = CanvasEnums.OptionStatus.Rectangle
                        flickable.interactive = false
                    }
                }

                HusIconButton{
                    id:btnRotatedBox
                    visible: annotationConfig.annotationType === AnnotationConfig.RotatedBox
                    Layout.preferredWidth: 30
                    Layout.preferredHeight: 30
                    iconSize: 20
                    iconFontFamily: "remixicon"
                    iconSource: RemixIcon.PokerDiamondsLine
                    radiusBg.all: 0
                    checkable: true
                    onClicked: {
                        centralAnnotationView.drawStatus = CanvasEnums.OptionStatus.RotationBox
                        flickable.interactive = false
                    }
                }
                HusIconButton{
                    id:btnPolygon
                    visible: annotationConfig.annotationType === AnnotationConfig.Segmentation
                    Layout.preferredWidth: 30
                    Layout.preferredHeight: 30
                    iconSize: 20
                    iconFontFamily: "remixicon"
                    iconSource: RemixIcon.PentagonLine
                    radiusBg.all: 0
                    checkable: true
                    onClicked: {
                        centralAnnotationView.drawStatus = CanvasEnums.OptionStatus.Polygon
                        flickable.interactive = false
                    }
                }


                HusIconButton{
                    id:btnPoint
                    visible: annotationConfig.annotationType === AnnotationConfig.KeyPoint
                    Layout.preferredWidth: 30
                    Layout.preferredHeight: 30
                    iconSize: 8
                    iconFontFamily: "remixicon"
                    iconSource: RemixIcon.CheckboxBlankCircle2Fill
                    radiusBg.all: 0
                    checkable: true
                    onClicked: {
                        centralAnnotationView.drawStatus = CanvasEnums.OptionStatus.Point
                        flickable.interactive = false
                    }
                }


                HusIconButton{
                    id: btnSave
                    Layout.preferredWidth: 30
                    Layout.preferredHeight: 30
                    iconSize: 20
                    iconSource: HusIcon.SaveOutlined
                    radiusBg.all: 0
                    onClicked: {
                        centralAnnotationView.annotationConfig.saveAnnotationFile(centralAnnotationView.annotationConfig.currentImageIndex)
                    }
                }

                HusDivider{
                    Layout.preferredHeight: 30
                    orientation: Qt.Vertical
                }
                Item{
                    Layout.fillWidth: true
                }
                HusTag{
                    text: centralAnnotationView.annotationConfig.fileListModel.getFullPath(centralAnnotationView.currentImageIndex)
                }
            }
        }
    }
    Component{
        id:detectionLabelLayerComponent
        DetectionLabelLayer{
        }
    }

    Component{
        id:rotatedBoxLabelLayerComponent
        RotatedBoxLabelLayer{
        }
    }

    Component{
        id:segmentationLabelLayerComponent
        SegmentationLabelLayer{
        }
    }


    Component{
        id:keyPointLabelLayerComponent
        KeyPointLabelLayer{
        }
    }



    onDrawStatusChanged: {
        if(drawStatus===CanvasEnums.OptionStatus.Drawing){
            flickable.interactive = false
        }else{
            flickable.interactive = false  // 修正：这里应该是true
        }
    }

    // 初始化完成后居中图片
    Component.onCompleted: {
        // Qt.callLater(flickable.centerImage)
    }
}
