import QtQuick
import QtQuick.Layouts
import HuskarUI.Basic
import QtQuick.Controls
import EasyLabel

Item{
    id:splitLeft
    property int drawStatus: CanvasEnums.OptionStatus.Select

    Flickable {
        id: flickable
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
            // 初始缩放比例设置为适合窗口
            scale: Math.min(flickable.width/width, flickable.height/height)
            Image {
                id: image
                source: "qrc:/images/image.jpg"
                anchors.fill: parent
            }
            DetectionLabelLayer{
                id: drawerLayer
                anchors.fill: parent
                drawStatus: splitLeft.drawStatus
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
            imageContainer.scale = Math.min(flickable.width / imageContainer.width,
                                            flickable.height / imageContainer.height)
        }
    }

    Item{
        id :footer
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height:40
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
                }

                HusText{
                    text:"缩放: "
                }

                HusText{
                    width:60
                    text: Math.round(imageContainer.scale * 100) + "%"
                }
                HusIconButton{
                    Layout.preferredWidth: 30
                    Layout.preferredHeight: 30
                    iconSize: 20
                    iconSource: HusIcon.PlusOutlined
                    radiusBg.all: 0
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
                    height: 30
                    orientation: Qt.Vertical
                }

                HusText{
                    text:"标签数：123"
                }

                HusDivider{
                    height: 30
                    orientation: Qt.Vertical
                }


                HusIconButton{
                    Layout.preferredWidth: 30
                    Layout.preferredHeight: 30
                    iconSize: 20
                    iconSource: HusIcon.LeftOutlined
                    radiusBg.all: 0
                }

                HusInput{
                    Layout.minimumWidth: 30
                    Layout.maximumWidth: 60
                    text: ""
                    background: HusRectangle {
                        anchors.bottom: parent.bottom
                        height: 1
                        color: parent.colorBg
                        border.color: parent.colorBorder
                    }
                }

                HusText{
                    text: "/"
                }

                HusText{
                    text: "456"
                }

                HusIconButton{
                    Layout.preferredWidth: 30
                    Layout.preferredHeight: 30
                    iconSize: 20
                    iconSource: HusIcon.RightOutlined
                    radiusBg.all: 0
                }

                HusButton{
                    id:btnSelect
                    text: "选择"
                    onClicked:{
                        drawStatus = CanvasEnums.OptionStatus.Select
                    }
                }

                HusButton{
                    id:btnDrawing
                    text:"绘制"
                    onClicked:{
                        drawStatus = CanvasEnums.OptionStatus.Drawing
                    }
                }

                Item{
                    Layout.fillWidth: true
                }
                HusTag{
                    text:"C:/User/aichao/Picture/1287.png"
                }
            }
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
