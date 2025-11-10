import QtQuick
import HuskarUI.Basic

HusSlider {
    id: control
    value: 6

    // 颜色相关的自定义属性
    property color currentColor: getColor((currentValue-min)/(max-min))

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
                gradient:  Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop { position: 0.00; color: HusTheme.isDark? Qt.rgba(1.0, 1.0, 1.0, 0.0):Qt.rgba(0.0, 0.0, 0.0, 0.0) }
                    GradientStop { position: 1.00; color: HusTheme.isDark? Qt.rgba(1.0, 1.0, 1.0, 1.0):Qt.rgba(0.0, 0.0, 0.0, 1.0) }
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
                    return active ? Qt.lighter("gray", 1.5) : Qt.lighter("gray", 1.2)
                else
                    return active ? Qt.darker("gray", 1.3) : Qt.darker("gray", 1.1)
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

    function getColor(position) {
        position = Math.max(0, Math.min(1, position))
        // 从完全透明(alpha=0)到完全不透明(alpha=1)的线性插值
        return HusTheme.isDark? Qt.rgba(1.0, 1.0, 1.0, position):Qt.rgba(0.0, 0.0, 0.0, position)
    }
}
