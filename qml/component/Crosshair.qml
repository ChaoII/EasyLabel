import QtQuick

Item {
    id: crosshairRoot

    property color color: "#00ff00"
    property real lineWidth: 1
    property int centerPointerSize: 12
    property bool showCoordinates: true
    property bool showCenterPoint: true
    property point mousePosition: Qt.point(0, 0)

    // 水平线
    Rectangle {
        y: crosshairRoot.mousePosition.y- crosshairRoot.lineWidth/2
        width: parent.width
        height: crosshairRoot.lineWidth
        color: crosshairRoot.color
        opacity: 0.7
    }

    // 垂直线
    Rectangle {
        x: crosshairRoot.mousePosition.x - crosshairRoot.lineWidth/2
        width: crosshairRoot.lineWidth
        height: parent.height
        color: crosshairRoot.color
        opacity: 0.7
    }

    // 中心点指示器
    Rectangle {
        visible: crosshairRoot.showCenterPoint
        x: crosshairRoot.mousePosition.x - centerPointerSize/2
        y: crosshairRoot.mousePosition.y - centerPointerSize/2
        width: centerPointerSize
        height: centerPointerSize
        radius: centerPointerSize/2
        color: crosshairRoot.color
        border.color: "white"
        border.width: lineWidth
        opacity: 0.9
    }

    // 坐标显示
    Rectangle {
        visible: crosshairRoot.showCoordinates
        x: crosshairRoot.mousePosition.x + 15
        y: crosshairRoot.mousePosition.y + 15
        width: coordText.width + 10
        height: coordText.height + 6
        color: "#aa000000"
        radius: 3

        Text {
            id: coordText
            anchors.centerIn: parent
            text: {"X:" + crosshairRoot.mousePosition.x.toFixed(0) + "\n" +
                   "Y:" + crosshairRoot.mousePosition.y.toFixed(0)}
            color: "white"
            font.pixelSize: 12
        }
    }
}



