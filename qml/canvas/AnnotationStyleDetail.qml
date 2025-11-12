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
            value: 1.00
            min:0.0
            max:1.0
            stepSize: 0.01
        }
        Item{
            Layout.fillHeight: true
        }
    }
}

