import QtQuick
import QtQuick.Layouts
import HuskarUI.Basic
import Qt.labs.folderlistmodel
import QtQuick.Dialogs
import EasyLabel

Item{
    id: splitRight

    HusCard{
        id: card
        anchors.fill: parent
        border.color:"transparent"
        titleDelegate: Item{
            width:parent.width
            height: 40
            ColumnLayout{
                anchors.fill: parent
                anchors.margins: 10
                RowLayout{
                    HusIconText{
                        id: logo
                        font.bold: true
                        iconSize:16
                        iconSource :HusIcon.BorderOutlined
                    }
                    HusText{
                        font.bold: true
                        font.pixelSize: 16
                        text:"对象检测"
                    }
                }
            }
        }
        bodyDelegate: bodyComponent
    }



    Component{
        id:bodyComponent
        HusCollapse {
            id: _menu
            accordion: true
            radiusBg.all: 0
            defaultActiveKey: ["A"]
            initModel: [
                {key:"A", title: qsTr('样式'), value: 1 , contentDelegate: aaa },
                {key:"B", title: qsTr('标签'), value: 2 , contentDelegate: bbb },
                {key:"C", title: qsTr('标注列表'), value: 3 , contentDelegate: ccc },
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
            ColorDialog {
                id: colorDialog
                onAccepted: {
                    // 更新数据模型
                    dataModel.setProperty(currentEditingIndex,"labelColor",selectedColor.toString())
                }
            }

            implicitHeight: 200
            width: parent.width
            property ListModel dataModel:ListModel
            {
                ListElement{label:"mouse";labelColor:"#ff0000"}
                ListElement{label:"train";labelColor:"#ffff00"}
                ListElement{label:"airplane";labelColor:"#0003ff"}
                ListElement{label:"truck"; labelColor:"#00ff00"}
                ListElement{label:"car";labelColor:"#ff00ff"}
                ListElement{label:"motorcircle";labelColor:"#ff00cc"}
            }
            property int currentEditingIndex:-1
            ListView{
                id:listView
                anchors.fill: parent
                focus: true
                highlightMoveDuration: 0 // 取消高亮移动动画
                keyNavigationEnabled: true // 启用键盘导航
                model: dataModel
                delegate: Item {
                    width: listView.width
                    height: 30
                    required property string label
                    required property color labelColor
                    required property int index

                    property bool isCurrent: listView.currentIndex === index
                    property bool isHovered: itemMouseArea.containsMouse || colorButton.hovered

                    HusRectangle {
                        color: {
                            if (isCurrent) return HusThemeFunctions.alpha(HusTheme.Primary.colorPrimaryBgActive, 0.45)
                            else if (isHovered) return HusThemeFunctions.alpha(HusTheme.Primary.colorPrimaryBgActive, 0.25)
                            else return "transparent"
                        }
                        anchors.fill: parent

                        MouseArea {
                            id: itemMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: listView.currentIndex = index
                        }
                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 10
                            anchors.rightMargin: 10
                            ColorButton {
                                id: colorButton
                                width: 24
                                height: 24
                                currentColor: labelColor
                                onClicked:{
                                    listView.currentIndex = index
                                    currentEditingIndex = index
                                    colorDialog.selectedColor = labelColor
                                    colorDialog.open()
                                }
                            }
                            HusText {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                text: label
                                verticalAlignment: HusText.AlignVCenter
                            }
                        }
                    }
                }
            }
        }
    }


    Component{
        id: ccc
        Item{
            implicitHeight: 200
            width: parent.width
            property ListModel dataModel:ListModel
            {
                ListElement{labelX:10;   labelY:30;   labelWidth:100;  labelHeight:100; label:"mouse"}
                ListElement{labelX:110;  labelY:130;  labelWidth:100;  labelHeight:100; label:"mouse"}
                ListElement{labelX:20;   labelY:230;  labelWidth:100;  labelHeight:100; label:"mouse"}
                ListElement{labelX:310;  labelY:330;  labelWidth:100;  labelHeight:100; label:"mouse"}
                ListElement{labelX:410;  labelY:30;   labelWidth:100;  labelHeight:100; label:"truck"}
                ListElement{labelX:510;  labelY:30;   labelWidth:100;  labelHeight:100; label:"truck"}

            }
            property int currentEditingIndex:-1
            ListView{
                id:listView
                anchors.fill: parent
                focus: true
                highlightMoveDuration: 0 // 取消高亮移动动画
                keyNavigationEnabled: true // 启用键盘导航
                model: dataModel
                delegate: Item {
                    width: listView.width
                    height: 30
                    required property int labelX
                    required property int labelY
                    required property int labelWidth
                    required property int labelHeight
                    required property string label
                    required property int index
                    property color labelColor:"#FFFF00"

                    property bool isCurrent: listView.currentIndex === index
                    property bool isHovered: itemMouseArea.containsMouse ||btnDelete.hovered || btnEdit.hovered

                    HusRectangle {
                        color: {
                            if (isCurrent) return HusThemeFunctions.alpha(HusTheme.Primary.colorPrimaryBgActive, 0.45)
                            else if (isHovered) return HusThemeFunctions.alpha(HusTheme.Primary.colorPrimaryBgActive, 0.25)
                            else return "transparent"
                        }
                        anchors.fill: parent

                        MouseArea {
                            id: itemMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: listView.currentIndex = index
                        }
                        RowLayout{
                            anchors.fill: parent
                            anchors.leftMargin: 10
                            anchors.rightMargin: 10
                            HusRectangle {
                                id: colorButton
                                width: 24
                                height: 24
                                color: labelColor
                            }
                            HusText {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                text: label
                                verticalAlignment: HusText.AlignVCenter
                            }
                            Item{
                                Layout.fillWidth: true
                            }
                            HusIconButton {
                                id:btnEdit
                                Layout.preferredWidth:  24
                                Layout.preferredHeight:  24
                                type: HusButton.Type_Link
                                iconSource: HusIcon.EditOutlined
                                onClicked: {

                                    listView.currentIndex = index
                                }
                            }
                            HusIconButton {
                                id:btnDelete
                                Layout.preferredWidth:  24
                                Layout.preferredHeight:  24
                                type: HusButton.Type_Link
                                iconSource: HusIcon.DeleteOutlined
                                onClicked: {

                                    listView.currentIndex = index
                                }
                            }
                        }
                    }
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
