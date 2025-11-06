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
        ScrollBar.vertical: HusScrollBar{ policy: HusScrollBar.AsNeeded }
        ScrollBar.horizontal: HusScrollBar{ policy: HusScrollBar.AsNeeded }
        clip: true

        // Flickable 的内容大小由图片缩放后的尺寸决定
        contentWidth: imageContainer.width * imageContainer.scale
        contentHeight: imageContainer.height * imageContainer.scale

        // 图片缩放范围（可以调整）
        property real minScale: 0.3
        property real maxScale: 3.0
        property alias fitScale: imageContainer.scale

        onContentXChanged: {
            console.log(contentX)
            console.log(contentY)
        }


        // 鼠标滚轮缩放 - 修正为以鼠标为中心
        WheelHandler {
            id: wheelHandler
            onWheel: function(wheel) {
                const zoomStep = 0.1
                var oldScale = imageContainer.scale
                var newScale = imageContainer.scale + (wheel.angleDelta.y > 0 ? zoomStep : -zoomStep)
                newScale = Math.max(flickable.minScale, Math.min(newScale, flickable.maxScale))

                if (oldScale !== newScale) {
                    // 计算鼠标在图片上的相对位置（0-1之间的比例）
                    var mouseXInImage = (flickable.contentX + wheel.x) / (imageContainer.width * oldScale)
                    var mouseYInImage = (flickable.contentY + wheel.y) / (imageContainer.height * oldScale)
                    // 应用新的缩放比例
                    imageContainer.scale = newScale
                    // 调整内容位置，使鼠标位置保持在同一图片点上
                    flickable.contentX = mouseXInImage * imageContainer.width * newScale - wheel.x
                    flickable.contentY = mouseYInImage * imageContainer.height * newScale - wheel.y
                }
            }
        }

        // PinchArea 控制缩放（触摸屏）
        PinchArea {
            anchors.fill: parent
            pinch.target: imageContainer
            pinch.minimumScale: flickable.minScale
            pinch.maximumScale: flickable.maxScale
            onPinchStarted: {
                // 记录捏合开始时的状态
                pinch.previousScale = imageContainer.scale
            }
            onPinchUpdated: {
                // 计算捏合中心在图片上的相对位置
                var centerXInImage = (flickable.contentX + pinch.center.x) / (imageContainer.width * pinch.previousScale)
                var centerYInImage = (flickable.contentY + pinch.center.y) / (imageContainer.height * pinch.previousScale)
                // 应用新的缩放比例
                imageContainer.scale = Math.max(flickable.minScale, Math.min(pinch.previousScale * pinch.scale, flickable.maxScale))
                // 调整内容位置
                flickable.contentX = centerXInImage * imageContainer.width * imageContainer.scale - pinch.center.x
                flickable.contentY = centerYInImage * imageContainer.height * imageContainer.scale - pinch.center.y
            }
            onPinchFinished: {
                flickable.returnToBounds()
            }
        }

        // 图片 ＋ 标注层
        Item {
            id: imageContainer
            width: image.sourceSize.width
            height: image.sourceSize.height
            transformOrigin: Item.TopLeft

            // 初始缩放比例设置为适合窗口
            scale: Math.min(flickable.width/width, flickable.height/height)

            Image {
                id: image
                // source: "qrc:/images/image.jpg"
                source: "file:///C:/Users/aichao/Desktop/ccc.jpg"
                anchors.fill: parent
            }

            DetectionLabelLayer{
                id: drawerLayer
                anchors.fill: parent
                drawStatus: splitLeft.drawStatus
            }

            // 组件完成时居中图片
            Component.onCompleted: {
                // 延迟执行以确保布局完成
                Qt.callLater(function() {
                    flickable.contentX = (imageContainer.width * imageContainer.scale - flickable.width) / 2
                    flickable.contentY = (imageContainer.height * imageContainer.scale - flickable.height) / 2
                })
            }
        }

        // 当Flickable大小改变时重新居中
        onWidthChanged: Qt.callLater(centerImage)
        onHeightChanged: Qt.callLater(centerImage)

        function centerImage() {
            flickable.contentX = (imageContainer.width * imageContainer.scale - flickable.width) / 2
            flickable.contentY = (imageContainer.height * imageContainer.scale - flickable.height) / 2
        }

        // 适合窗口大小的函数
        function fitToWindow() {
            imageContainer.scale = Math.min(flickable.width/imageContainer.width, flickable.height/imageContainer.height)
            centerImage()
        }
    }

    Item{
        id :footer
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height:30
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
                HusText{
                    text:"缩放: "
                }
                HusText{
                    width:60
                    text: Math.round(imageContainer.scale * 100) + "%"
                }

                HusButton{
                    id: btnFit
                    text: "适合窗口"
                    onClicked: {
                        flickable.fitToWindow()
                    }
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
                HusText{
                    Layout.preferredWidth: 300
                    horizontalAlignment: HusText.AlignRight
                    elide: HusText.ElideRight
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
        Qt.callLater(flickable.centerImage)
    }
}
