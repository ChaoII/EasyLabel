import QtQuick
import QtQuick.Layouts
import HuskarUI.Basic
import QtQuick.Controls

Item{
    id:splitLeft
    Flickable {
        id: flickable
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: footer.top
        ScrollBar.vertical: HusScrollBar{policy: HusScrollBar.AsNeeded}
        ScrollBar.horizontal: HusScrollBar{policy: HusScrollBar.AsNeeded}
        clip: true

        // Flickable 的内容大小由图片缩放后的尺寸决定
        contentWidth: imageContainer.width * imageContainer.scale
        contentHeight: imageContainer.height * imageContainer.scale

        // 图片缩放范围（可以调整）
        property real minScale: 0.3
        property real maxScale: 3.0
        property real fitScale: 1.0
        contentX: (contentWidth - width) / 2
        contentY: (contentHeight - height) / 2
        /// 鼠标滚轮缩放 （桌面操作很方便）
        WheelHandler {
            id: wheelHandler
            target: flickable
            onWheel:(wheel)=> {
                        const zoomStep = 0.01
                        var newScale = imageContainer.scale + (wheel.angleDelta.y > 0 ? zoomStep : -zoomStep)
                        imageContainer.scale = Math.max(flickable.minScale, Math.min(newScale, flickable.maxScale))
                    }
        }

        // PinchArea 控制缩放（触摸屏）
        PinchArea {
            anchors.fill: parent
            pinch.target: imageContainer
            pinch.minimumScale: flickable.minScale
            pinch.maximumScale: flickable.maxScale
        }

        // 图片 ＋ 标注层
        Item {
            id: imageContainer
            implicitWidth: image.implicitWidth
            implicitHeight: image.implicitHeight
            transformOrigin: Item.Center
            scale: flickable.fitScale

            Image {
                id: image
                source: "qrc:/images/image.jpg"
                fillMode: Image.PreserveAspectFit
                anchors.fill: parent

            }

            // ================================
            // 标注层（绘制矩形标注）
            // ================================
            Item {
                id: annotationLayer
                anchors.fill: parent

                ListModel { id: annotationModel }

                // 鼠标绘制矩形标注
                MouseArea {
                    id: drawArea
                    anchors.fill: parent
                    property real startX
                    property real startY

                    onPressed:(mouse)=> {
                                  startX = mouse.x
                                  startY = mouse.y

                                  annotationModel.append({
                                                             "x": mouse.x,
                                                             "y": mouse.y,
                                                             "w": 0,
                                                             "h": 0
                                                         })
                              }

                    onPositionChanged:(mouse)=> {
                                          if (mouse.buttons & Qt.LeftButton) {
                                              let last = annotationModel.count - 1
                                              annotationModel.set(last, {
                                                                      "x": startX,
                                                                      "y": startY,
                                                                      "w": mouse.x - startX,
                                                                      "h": mouse.y - startY
                                                                  })
                                          }
                                      }
                }

                // 显示所有标注框
                Repeater {
                    model: annotationModel

                    Rectangle {
                        x: model.x
                        y: model.y
                        width: model.w
                        height: model.h
                        border.color: "red"
                        border.width: 2
                        color: "#00FF0000"
                    }
                }
            }
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
                    text:"x: "
                }
                HusText{
                    width:50
                    text: canvasX
                }
                HusText{
                    text:"y: "
                }
                HusText{
                    width:50
                    text: canvasY
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

    // Component.onCompleted: {
    //     repositionImage()
    // }
    // onWidthChanged: repositionImage()
    // onHeightChanged: repositionImage()

    function repositionImage() {
        if (image.implicitWidth <= 0 || image.implicitHeight <= 0)
            return

        let scaleX = flickable.width / image.implicitWidth
        let scaleY = flickable.height / image.implicitHeight

        flickable.fitScale = Math.min(scaleX, scaleY)   // ⭐ 自动按窗口缩放
        imageContainer.scale = flickable.fitScale       // 应用缩放
    }
}
