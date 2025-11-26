import QtQuick

Item {
    id: crosshairRoot

    property color crossColor: "#00ff00"
    property real lineWidth: 1
    property int centerPointerSize: 12
    property bool showCoordinates: true
    property bool showCenterPoint: true
    property point mousePosition: Qt.point(0, 0)
    property real scaleFactor: 1.0
    readonly property real _realLineWidth:lineWidth/scaleFactor
    readonly property int _realcenterPointerSize: centerPointerSize /scaleFactor


    // 水平线
    Rectangle {
        y: crosshairRoot.mousePosition.y- crosshairRoot._realLineWidth/2
        width: parent.width
        height: crosshairRoot._realLineWidth
        color: crosshairRoot.crossColor
        opacity: 0.7
    }

    // 垂直线
    Rectangle {
        x: crosshairRoot.mousePosition.x - crosshairRoot._realLineWidth/2
        width: crosshairRoot._realLineWidth
        height: parent.height
        color: crosshairRoot.crossColor
        opacity: 0.7
    }

    // 中心点指示器
    Rectangle {
        visible: crosshairRoot.showCenterPoint
        x: crosshairRoot.mousePosition.x - _realcenterPointerSize/2
        y: crosshairRoot.mousePosition.y - _realcenterPointerSize/2
        width: _realcenterPointerSize
        height: _realcenterPointerSize
        radius: _realcenterPointerSize/2
        color: crosshairRoot.crossColor
        border.color: "white"
        border.width: lineWidth
        opacity: 0.9
    }

    // 坐标显示
    Rectangle {
        visible: crosshairRoot.showCoordinates
        x: crosshairRoot.mousePosition.x + 15 / scaleFactor
        y: crosshairRoot.mousePosition.y + 15 / scaleFactor
        width: coordText.width + 10 /scaleFactor
        height: coordText.height + 6 / scaleFactor
        color: "#aa000000"
        radius: 3 / scaleFactor

        Text {
            id: coordText
            anchors.centerIn: parent
            text: {"X: " + crosshairRoot.mousePosition.x.toFixed(0) + "\n" +
                   "Y: " + crosshairRoot.mousePosition.y.toFixed(0)}
            color: "white"
            font.pixelSize: 12 / scaleFactor
        }
    }
}



