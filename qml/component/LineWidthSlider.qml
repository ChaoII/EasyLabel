import QtQuick
import HuskarUI.Basic

HusSlider {
    id:control
    value:6
    bgDelegate:Item {
        HusRectangleInternal {
            width: parent.width
            height: 4
            anchors.verticalCenter: parent.verticalCenter
            radius: control.radiusBg.all
            topLeftRadius: control.radiusBg.topLeft
            topRightRadius: control.radiusBg.topRight
            bottomLeftRadius: control.radiusBg.bottomLeft
            bottomRightRadius: control.radiusBg.bottomRight
            color: control.colorBg

            Behavior on color { enabled: control.animationEnabled; ColorAnimation { duration: HusTheme.Primary.durationFast } }
            Repeater{
                model:control.max
                Item{
                    readonly property real tickSpacing: parent.width / (control.max - 1)
                    anchors.fill: parent
                    Rectangle{
                        x: tickSpacing * index - width/2
                        y: parent.y
                        width: index + 1
                        height: 12
                        color: control.colorBg
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    HusText{
                        x:tickSpacing * index - width/2
                        y: parent.y + 10
                        text: index+1
                        color: HusTheme.HusInput.colorTextDisabled
                    }
                }
            }

            // tracker
            Rectangle {
                x:  0
                y: 0
                width:  slider.visualPosition * parent.width
                height:  parent.height;
                color: colorTrack
                radius: parent.radius
                Behavior on color { enabled: control.animationEnabled; ColorAnimation { duration: HusTheme.Primary.durationFast } }
            }
        }
    }


    handleDelegate: Cursor {
        id: __handleItem
        x: slider.leftPadding + visualPosition * (slider.availableWidth) -width/2
        y: slider.topPadding + (slider.availableHeight - height) * 0.5 - 2
        implicitWidth: active ? 16 : 12
        implicitHeight: active ? 20 : 15
        cursorColor: control.colorHandle
        borderColor: {
            if (control.enabled) {
                if (HusTheme.isDark)
                    return active ? HusTheme.HusSlider.colorHandleBorderHoverDark : HusTheme.HusSlider.colorHandleBorderDark;
                else
                    return active ? HusTheme.HusSlider.colorHandleBorderHover : HusTheme.HusSlider.colorHandleBorder;
            } else {
                return HusTheme.HusSlider.colorHandleBorderDisabled;
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

}
