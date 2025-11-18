import QtQuick
import HuskarUI.Basic
import QtQuick.Layouts
import EasyLabel

Item{
    height: parent.height
    width: parent.width
    ColumnLayout{
        anchors.fill: parent
        RowLayout{
            HusIconText{
                iconSource: HusIcon.BorderOuterOutlined
            }
            HusCopyableText{
                text:"边框粗细"
            }
            Item{
                Layout.fillWidth: true
            }
            HusTag{
                text:lineWidthSlider.currentValue
            }
        }
        LineWidthSlider {
            id: lineWidthSlider
            Layout.fillWidth: true
            snapMode: HusSlider.SnapAlways
            height: 50
            min: 1
            max: 5
            value: 2
            stepSize: 1
            onCurrentValueChanged: {
                AnnotationConfig.currentLineWidth = currentValue
            }
        }
        RowLayout{
            HusIconText{
                iconSource: HusIcon.FormatPainterOutlined
            }
            HusCopyableText{
                text:"边框颜色"
            }
            Item{
                Layout.fillWidth: true
            }
            HusTag{
                text:colorSlider.currentColor
                presetColor:colorSlider.currentColor
            }
        }
        ColorSlider {
            id:colorSlider
            Layout.fillWidth: true
            height: 30
            value: 3
            min:1
            max:100
        }
        RowLayout{
            HusIconText{
                iconSource: HusIcon.IcoMoonDelicious
            }
            HusCopyableText{
                text:"填充透明度"
            }
            Item{
                Layout.fillWidth: true
            }
            HusTag{
                text:opacitySlider.currentValue.toFixed(2)
            }
        }

        OpacitySlider {
            id: opacitySlider
            Layout.fillWidth: true
            height: 30
            value: 0.25
            min: 0.0
            max: 1.0
            stepSize: 0.01
            onCurrentValueChanged: {
                AnnotationConfig.currentFillOpacity = currentValue
            }
        }

        RowLayout{
            HusIconText{
                iconSource: HusIcon.AimOutlined
            }
            HusCopyableText{
                text:"角控制点直径"
            }
            Item{
                Layout.fillWidth: true
            }
            HusInputNumber{
                Layout.preferredWidth: 80
                useWheel: true
                min: 5
                max: 40
                value: 10
                onValueChanged: {
                    AnnotationConfig.currentCornerRadius = value
                }
            }
        }

        RowLayout{
            HusIconText{
                iconSource: HusIcon.ColumnWidthOutlined
            }
            HusCopyableText{
                text:"边控制点宽"
            }
            Item{
                Layout.fillWidth: true
            }
            HusInputNumber{
                Layout.preferredWidth: 80
                useWheel: true
                min: 5
                max: 40
                value: 12
                onValueChanged: {
                    AnnotationConfig.currentEdgeWidth = value
                }
            }
        }

        RowLayout{
            HusIconText{
                iconSource: HusIcon.ColumnHeightOutlined
            }
            HusCopyableText{
                text:"边控制点高"
            }
            Item{
                Layout.fillWidth: true
            }
            HusInputNumber{
                Layout.preferredWidth: 80
                useWheel: true
                min: 5
                max: 40
                value: 6
                onValueChanged: {
                    AnnotationConfig.currentEdgeHeight = value
                }
            }
        }

        RowLayout{
            HusIconText{
                iconSource: HusIcon.FundViewOutlined
            }
            HusCopyableText{
                text:"显示标签"
            }
            Item{
                Layout.fillWidth: true
            }

            HusSwitch {
                id: switch2
                radiusBg.all: 2
                animationEnabled: false
                handleDelegate: Rectangle {
                    radius: 2
                    color: switch2.colorHandle
                }
                checked: AnnotationConfig.showLabel
                checkedText: "是"
                uncheckedText: "否"
                onCheckedChanged: {
                    AnnotationConfig.showLabel = checked
                }
            }
        }

        RowLayout{
            visible: switch2.checked
            HusIconText{
                iconSource: HusIcon.LineHeightOutlined
            }
            HusCopyableText{
                text:"标签字体大小"
            }
            Item{
                Layout.fillWidth: true
            }
            HusInputNumber{
                Layout.preferredWidth: 80
                useWheel: true
                min: 12
                max: 60
                value: 16
                onValueChanged: {
                    AnnotationConfig.fontPointSize = value
                }
            }
        }

        Item{
            Layout.fillHeight: true
        }
    }
}

