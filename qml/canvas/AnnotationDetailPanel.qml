import QtQuick
import QtQuick.Layouts
import HuskarUI.Basic
import EasyLabel

Item{
    id: splitRight

    HusCard{
        id: card
        anchors.fill: parent
        border.color:"transparent"
        bodyDelegate: bodyComponent
    }

    Component{
        id:bodyComponent
        HusCollapse {
            id: _menu
            initModel: [
                {key:"A", title: qsTr('样式'), value: 1 , contentDelegate: aaa },
                {key:"B", title: qsTr('煮都还实'), value: 2 , contentDelegate: bbb },
                {key:"C", title: qsTr('浓度高强'), value: 3 , contentDelegate: aaa }
            ]
            contentDelegate:Item{
                height:240
                Loader{
                    anchors.fill: parent
                    anchors.margins: 10
                    sourceComponent: model.contentDelegate
                }
            }
        }
    }

    Component{
        id:aaa
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
    }

    Component{
        id: bbb
        Item{
            implicitHeight: 200
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
                }
                LineWidthSlider {
                    id: control
                    Layout.fillWidth: true
                    snapMode: HusSlider.SnapAlways
                    height: 30
                    min: 1
                    max: 5
                    value: 2
                    stepSize: 1
                }
                Item{
                    Layout.fillHeight: true
                }
            }
        }
    }


}
