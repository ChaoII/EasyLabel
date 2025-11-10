import QtQuick
import HuskarUI.Basic

HusSlider {
    id: control
    value: 6

    // 颜色相关的自定义属性
    property color currentColor: getRainbowColor((currentValue-min)/(max-min))

    bgDelegate: Item {
        HusRectangleInternal {
            id: trackBackground
            width: parent.width
            height: 4
            anchors.verticalCenter: parent.verticalCenter
            radius: control.radiusBg.all
            topLeftRadius: control.radiusBg.topLeft
            topRightRadius: control.radiusBg.topRight
            bottomLeftRadius: control.radiusBg.bottomLeft
            bottomRightRadius: control.radiusBg.bottomRight
            color: "transparent"  // 背景透明

            // 渐变色轨道
            Rectangle {
                width: parent.width
                height: parent.height
                radius: parent.radius
                gradient: Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop { position: 0.00; color: Qt.hsva(0.00, 1.0, 1.0, 1.0) } // 红
                    GradientStop { position: 0.20; color: Qt.hsva(0.16, 1.0, 1.0, 1.0) } // 橙
                    GradientStop { position: 0.40; color: Qt.hsva(0.33, 1.0, 1.0, 1.0) } // 黄
                    GradientStop { position: 0.60; color: Qt.hsva(0.50, 1.0, 1.0, 1.0) } // 绿
                    GradientStop { position: 0.80; color: Qt.hsva(0.66, 1.0, 1.0, 1.0) } // 青
                    GradientStop { position: 1.00; color: Qt.hsva(0.83, 1.0, 1.0, 1.0) } // 紫
                }
            }

            Behavior on color {
                enabled: control.animationEnabled;
                ColorAnimation { duration: HusTheme.Primary.durationFast }
            }
        }
    }

    handleDelegate: Cursor {
        id: __handleItem
        x: slider.leftPadding + visualPosition * slider.availableWidth - width / 2
        y: slider.topPadding + (slider.availableHeight - height) * 0.5
        implicitWidth: active ? 16 : 12
        implicitHeight: active ? 20 : 15

        // 手柄颜色显示当前选择的颜色
        cursorColor: control.currentColor
        borderColor: {
            if (control.enabled) {
                if (HusTheme.isDark)
                    return active ? Qt.lighter(control.currentColor, 1.5) : Qt.lighter(control.currentColor, 1.2)
                else
                    return active ? Qt.darker(control.currentColor, 1.3) : Qt.darker(control.currentColor, 1.1)
            } else {
                return HusTheme.HusSlider.colorHandleBorderDisabled
            }
        }
        borderWidth: active ? 3 : 2
        property bool down: pressed
        property bool active: __hoverHandler.hovered || down
        HoverHandler {
            id: __hoverHandler
            cursorShape: control.hoverCursorShape
        }
    }

    function getRainbowColor(position) {
        position = Math.max(0, Math.min(1, position))
        // 渐变色关键点对应的色相值
        var keyPoints = [
                    {pos: 0.00, hue: 0.00},   // 红
                    {pos: 0.20, hue: 0.16},   // 橙
                    {pos: 0.40, hue: 0.33},   // 黄
                    {pos: 0.60, hue: 0.50},   // 绿
                    {pos: 0.80, hue: 0.66},   // 青
                    {pos: 1.00, hue: 0.83}    // 紫
                ]

        // 找到对应的区间进行插值
        for (var i = 1; i < keyPoints.length; i++) {
            if (position <= keyPoints[i].pos) {
                var prev = keyPoints[i-1]
                var curr = keyPoints[i]
                var ratio = (position - prev.pos) / (curr.pos - prev.pos)
                return Qt.hsva(prev.hue + ratio * (curr.hue - prev.hue), 1.0, 1.0, 1.0)
            }
        }
        return Qt.hsva(0.83, 1.0, 1.0, 1.0)
    }
}
