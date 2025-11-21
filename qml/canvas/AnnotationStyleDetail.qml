import QtQuick
import HuskarUI.Basic
import QtQuick.Layouts
import EasyLabel

Item{
    id: annotationStyleDetail

    required property AnnotationConfig annotationConfig
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
            Layout.preferredHeight: 50
            min: 1
            max: 5
            value: 2
            stepSize: 1
            onCurrentValueChanged: {
                annotationStyleDetail.annotationConfig.currentLineWidth = currentValue
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
                text: colorSlider.currentColor.toString()
                presetColor:colorSlider.currentColor.toString()
            }
        }
        ColorSlider {
            id:colorSlider
            Layout.fillWidth: true
            Layout.preferredHeight: 30
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
            Layout.preferredHeight: 30
            value: 0.25
            min: 0.0
            max: 1.0
            stepSize: 0.01
            onCurrentValueChanged: {
                annotationStyleDetail.annotationConfig.currentFillOpacity = currentValue
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
                    annotationStyleDetail.annotationConfig.currentCornerRadius = value
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
                    annotationStyleDetail.annotationConfig.currentEdgeWidth = value
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
                    annotationStyleDetail.annotationConfig.currentEdgeHeight = value
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
                    color: switch2.colorHandle.toString()
                }
                checked: annotationStyleDetail.annotationConfig.showLabel
                checkedText: "是"
                uncheckedText: "否"
                onCheckedChanged: {
                    annotationStyleDetail.annotationConfig.showLabel = checked
                }
            }
        }

        RowLayout{
            visible: switch2.checked
            HusIconText{
                iconSource: HusIcon.FontSizeOutlined
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
                    annotationStyleDetail.annotationConfig.fontPointSize = value
                }
            }
        }

        RowLayout{
            HusIconText{
                iconSource: HusIcon.LineHeightOutlined
            }
            HusCopyableText{
                text:"中心指示器大小"
            }
            Item{
                Layout.fillWidth: true
            }
            HusInputNumber{
                Layout.preferredWidth: 80
                useWheel: true
                min: 1
                max: 20
                value: 4
                onValueChanged: {
                    annotationStyleDetail.annotationConfig.centerPointerSize = value
                }
            }
        }



        Item{
            Layout.fillHeight: true
        }
    }
}

