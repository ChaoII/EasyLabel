import QtQuick

Item {

    id: cursorItem

    property color cursorColor: "#3498db"
    property color borderColor: Qt.darker(cursorColor, 1.3)
    property real borderWidth: 2
    property string label: ""
    property real labelRotation: 0

    // 当属性变化时重绘
    onCursorColorChanged: cursorCanvas.requestPaint()
    onBorderColorChanged: cursorCanvas.requestPaint()
    onBorderWidthChanged: cursorCanvas.requestPaint()
    onWidthChanged: cursorCanvas.requestPaint()
    onHeightChanged: cursorCanvas.requestPaint()

    // 使用Canvas绘制一体式形状
    Canvas {
        id: cursorCanvas
        anchors.fill: parent
        onPaint: {
            var context = getContext("2d")
            context.reset()
            // 清除画布
            context.clearRect(0, 0, width, height)
            // 计算内部偏移（考虑边框宽度）
            var halfBorder = borderWidth / 2
            var rectHeight = height * 0.6
            var triangleHeight = height * 0.4
            // 绘制填充部分（稍微缩小以避免边框重叠）
            context.beginPath()
            context.moveTo(halfBorder, halfBorder) // 左上角
            context.lineTo(width - halfBorder, halfBorder) // 右上角
            context.lineTo(width - halfBorder, rectHeight - halfBorder) // 右下角
            context.lineTo(width / 2, height - halfBorder) // 三角形底部中点
            context.lineTo(halfBorder, rectHeight - halfBorder) // 左下角
            context.closePath()
            // 填充颜色
            context.fillStyle = cursorItem.cursorColor
            context.fill()
            // 绘制边框
            context.strokeStyle = cursorItem.borderColor
            context.lineWidth = borderWidth
            context.lineJoin = "miter" // 尖角连接
            context.stroke()
        }
        // 文字标签
        Text {
            text: cursorItem.label
            color: "white"
            font.bold: true
            font.pixelSize: Math.min(12, cursorItem.width * 0.25)
            anchors.centerIn: parent
            anchors.verticalCenterOffset: -cursorItem.height * 0.1 // 向上偏移
            rotation: cursorItem.labelRotation
        }
    }
}
