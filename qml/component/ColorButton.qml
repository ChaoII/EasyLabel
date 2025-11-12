import QtQuick
import QtQuick.Templates as T
import HuskarUI.Basic

T.Button {
    id: control
    property bool animationEnabled: HusTheme.animationEnabled
    property bool effectEnabled: true
    property int hoverCursorShape: Qt.PointingHandCursor
    property color currentColor:"transparent"
    property color colorBg: {
        if (enabled) {
            return control.down ? Qt.darker(currentColor, 1.5):
                                  control.hovered ? Qt.lighter(currentColor,1.5) : currentColor;
        } else {
            return HusThemeFunctions.alpha(currentColor, 0.15)
        }
    }
    property color colorBorder: {
        if (enabled){
            return currentColor
        } else {
            return control.down ? HusThemeFunctions.alpha(currentColor, 0.75) :
                                  control.hovered ? HusThemeFunctions.alpha(currentColor, 0.50) :
                                                    currentColor;
        }
    }
    property HusRadius radiusBg: HusRadius { all: 0 }

    objectName: '__HusButton__'
    implicitWidth: implicitContentWidth + leftPadding + rightPadding
    implicitHeight: implicitContentHeight + topPadding + bottomPadding

    background: Item {
        HusRectangleInternal {
            id: __effect
            width: __bg.width
            height: __bg.height
            radius: __bg.radius
            topLeftRadius: __bg.topLeftRadius
            topRightRadius: __bg.topRightRadius
            bottomLeftRadius: __bg.bottomLeftRadius
            bottomRightRadius: __bg.bottomRightRadius
            anchors.centerIn: parent
            visible: control.effectEnabled
            color: 'transparent'
            border.width: 0
            border.color: colorBorder

            ParallelAnimation {
                id: __animation
                onFinished: __effect.border.width = 0;
                NumberAnimation {
                    target: __effect; property: 'width'; from: __bg.width + 3; to: __bg.width + 8;
                    duration: HusTheme.Primary.durationFast
                    easing.type: Easing.OutQuart
                }
                NumberAnimation {
                    target: __effect; property: 'height'; from: __bg.height + 3; to: __bg.height + 8;
                    duration: HusTheme.Primary.durationFast
                    easing.type: Easing.OutQuart
                }
                NumberAnimation {
                    target: __effect; property: 'opacity'; from: 0.2; to: 0;
                    duration: HusTheme.Primary.durationSlow
                }
            }

            Connections {
                target: control
                function onReleased() {
                    if (control.animationEnabled && control.effectEnabled) {
                        __effect.border.width = 8;
                        __animation.restart();
                    }
                }
            }
        }
        HusRectangleInternal {
            id: __bg
            width: parent.width
            height: parent.height
            anchors.centerIn: parent
            radius: control.radiusBg.all
            topLeftRadius:  control.radiusBg.topLeft
            topRightRadius:  control.radiusBg.topRight
            bottomLeftRadius:  control.radiusBg.bottomLeft
            bottomRightRadius:  control.radiusBg.bottomRight
            color: colorBg
            border.width:  1
            border.color: control.enabled ? control.colorBorder : 'transparent'
            Behavior on color { enabled: control.animationEnabled; ColorAnimation { duration: HusTheme.Primary.durationMid } }
            Behavior on border.color { enabled: control.animationEnabled; ColorAnimation { duration: HusTheme.Primary.durationMid } }
        }
    }

    HoverHandler {
        cursorShape: control.hoverCursorShape
    }
    Accessible.role: Accessible.Button
    Accessible.name: control.text
    Accessible.onPressAction: control.clicked();
}
