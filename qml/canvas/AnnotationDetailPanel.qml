import QtQuick
import QtQuick.Layouts
import HuskarUI.Basic
import Qt.labs.folderlistmodel
import EasyLabel

Item{
    id: splitRight

    HusCard{
        id: card
        anchors.fill: parent
        border.color:"transparent"
        titleDelegate: Item{
            height:40
            HusIconText{
                iconSize: 40
                iconSource :HusIcon.BorderOutlined
                horizontalAlignment: HusText.AlignHCenter
            }
        }
        bodyDelegate: bodyComponent
    }

    Component{
        id:bodyComponent
        HusCollapse {
            id: _menu
            accordion: true
            defaultActiveKey: ["A"]
            initModel: [
                {key:"A", title: qsTr('样式'), value: 1 , contentDelegate: aaa },
                {key:"B", title: qsTr('标签'), value: 2 , contentDelegate: bbb },
                {key:"C", title: qsTr('标注列表'), value: 3 , contentDelegate: aaa },
                {key:"D", title: qsTr('文件列表'), value: 4 , contentDelegate: ddd }
            ]
            contentDelegate:Item{
                height:splitRight.height - 40 * _menu.count -40
                Loader{
                    anchors.fill: parent
                    anchors.margins: 10
                    sourceComponent: model.contentDelegate
                }
            }
            Component.onCompleted: {

                console.log(_menu.titleDelegate.height)
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

    Component{
        id: ddd
        Item{
            implicitHeight: 200
            width: parent.width
            property string currentFolder: Qt.resolvedUrl(".").toString().replace("file:///", "")

            FolderListModel {
                id: folderModel
                folder: "file:///" + currentFolder
                showDirs: true
                showFiles: true
                showDotAndDotDot: false
                nameFilters: ["*"]  // 所有文件
            }

            ListView {
                anchors.fill: parent
                model: folderModel
                delegate: Rectangle {
                    width: ListView.view.width
                    height: 30
                    color: index % 2 === 0 ? "#f0f0f0" : "#ffffff"
                    border.color: "#dddddd"

                    HusText {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: 10
                        text: fileName + (fileIsDir ? "/" : "")
                        color: fileIsDir ? "blue" : "black"
                    }

                    HusText {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.right: parent.right
                        anchors.rightMargin: 10
                        text: fileIsDir ? "文件夹" : "文件"
                        color: "gray"
                        font.pixelSize: 12
                    }
                }
            }
        }
    }


}
