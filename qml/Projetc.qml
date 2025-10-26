import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import HuskarUI.Basic

// var typeColorConfig={
//     detection:"red",
// }

Item {



    anchors.margins: 10
    anchors.fill: parent
    RowLayout{
        id: layoutBtn
        anchors.top : parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        HusButton{
            id: btnCreateProject
            type: HusButton.Type_Primary
            text: "创建项目"
            onClicked: {
                popup.open()
            }
        }
        Item{
            Layout.fillWidth: true
        }
        HusRadioBlock {
            initCheckedIndex: 0
            model: [
                { label: 'Apple', value: 'Apple' },
                { label: 'Pear', value: 'Pear' },
                { label: 'Orange', value: 'Orange' },
            ]
        }
    }
    ScrollView   {
        id: scrollView
        anchors.top: layoutBtn.bottom
        anchors.bottom: pagination.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.topMargin: 10
        anchors.bottomMargin: 10
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
        ScrollBar.vertical: HusScrollBar { policy:ScrollBar.AsNeeded}
        Flow{
            width: scrollView.width
            spacing: 10
            Repeater {
                model: listModel
                delegate: cardDetegate
            }
        }
    }

    HusPagination{
        id: pagination
        anchors.bottom: parent.bottom

        currentPageIndex: 0
        total: 50
        pageSizeModel: [
            { label: qsTr('10条每页'), value: 10 },
            { label: qsTr('20条每页'), value: 20 },
            { label: qsTr('30条每页'), value: 30 },
            { label: qsTr('40条每页'), value: 40 }
        ]
    }
    enum AnnotationType {
        Detection = 0
    }







    ListModel{

        id:listModel
        ListElement{
            _title:"我是猪"
            _imagePath:"/user/local/bin/images"
            _resultPath:"/user/local/bin/results"
            _type: "Detection"
            _createTime:"2025-10-26 12:08:23"
        }
        ListElement{
            _title:"我是猪"
            _imagePath:"/user/local/bin/images"
            _resultPath:"/user/local/bin/results"
            _type: "Detection"
            _createTime:"2025-10-26 12:08:23"
        }
        ListElement{
            _title:"我是猪"
            _imagePath:"/user/local/bin/images"
            _resultPath:"/user/local/bin/results/user/local/bin/results"
            _type: "Detection"
            _createTime:"2025-10-26 12:08:23"
        }
        ListElement{
            _title:"我是猪"
            _imagePath:"/user/local/bin/images"
            _resultPath:"/user/local/bin/results"
            _type: "Detection"
            _createTime:"2025-10-26 12:08:23"
        }
    }

    Component{
        id:cardDetegate




        HusCard{
            id:_card
            required property string _title
            required property string _imagePath
            required property string _resultPath
            required property string _type
            required property string _createTime
            property int fontSize: 12
            readonly property var typeColorConfig:{
                "Detection":"red",
            }
            width: 312
            height: 200
            titleDelegate: null

            Item{
                id:itemTitle

                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: 10
                height:20

                HusText{
                    height: parent.height
                    anchors.left: parent.left
                    verticalAlignment: HusText.AlignVCenter
                    text: _title
                }
            }

            HusDivider {
                id:dividerTop
                anchors.top: itemTitle.bottom
                anchors.margins: 10
                width: parent.width
                height: 1
            }

            Item{
                id: itemBody
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: dividerTop.bottom
                anchors.bottom: dividerBottom.top
                anchors.margins: 10
                HusIconText{
                    id: avator
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    iconSize: 40
                    iconSource: HusIcon.BorderOutlined
                }
                ColumnLayout{
                    anchors.left: avator.right
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.right: parent.right
                    anchors.leftMargin: 10
                    anchors.rightMargin: 10
                    HusTag{
                        id: textType
                        text: _type
                        presetColor: _card.typeColorConfig[_type]
                    }
                    RowLayout{
                        height: 20
                        HusText {
                            Layout.fillWidth: true
                            font.pixelSize: fontSize
                            text:"图片路径："+ _imagePath
                            elide: Text.ElideRight
                            color: HusTheme.Primary.colorPrimaryTextDisabled
                        }
                        HusIconButton{
                            Layout.preferredHeight: parent.height
                            Layout.preferredWidth: 20
                            // iconSpacing: 0
                            padding: 0
                            type: HusButton.Type_Link
                            iconSource: HusIcon.FolderOpenOutlined
                        }
                    }

                    id: itemResultPath
                    RowLayout{
                        height: 20
                        HusText{
                            Layout.fillWidth: true
                            font.pixelSize: fontSize
                            text:"结果路径："+ _resultPath
                            elide: Text.ElideRight
                            color: HusTheme.Primary.colorPrimaryTextDisabled
                        }
                        HusIconButton{
                            Layout.preferredHeight: parent.height
                            Layout.preferredWidth: 20
                            padding: 0
                            type: HusButton.Type_Link
                            iconSource: HusIcon.FolderOpenOutlined
                        }
                    }
                    HusText{
                        font.pixelSize: fontSize
                        text:"创建时间："+ _createTime
                        verticalAlignment: Text.AlignVCenter
                        color: HusTheme.Primary.colorPrimaryTextDisabled
                    }

                }
            }





            HusDivider {
                id:dividerBottom
                anchors.bottom:layoutAction.top
                width: parent.width
                height: 1
            }

            RowLayout {
                id: layoutAction
                anchors.bottom: parent.bottom
                height:40
                width: parent.width

                HusIconButton {
                    Layout.preferredWidth: parent.width / 3
                    Layout.fillHeight: true
                    type: HusButton.Type_Link
                    iconSource: HusIcon.EditOutlined
                    iconSize: 16

                }

                Item {
                    Layout.preferredWidth: parent.width / 3
                    Layout.fillHeight: true

                    HusDivider {
                        width: 1
                        height: parent.height * 0.5
                        anchors.verticalCenter: parent.verticalCenter
                        orientation: Qt.Vertical
                    }

                    HusIconButton {
                        anchors.centerIn: parent
                        type: HusButton.Type_Link
                        iconSource: HusIcon.ExportOutlined
                        iconSize: 16
                    }
                }

                Item {
                    Layout.preferredWidth: parent.width / 3
                    Layout.fillHeight: true

                    HusDivider {
                        width: 1
                        height: parent.height * 0.5
                        anchors.verticalCenter: parent.verticalCenter
                        orientation: Qt.Vertical
                    }

                    HusIconButton {
                        anchors.centerIn: parent
                        type: HusButton.Type_Link
                        iconSource: HusIcon.DeleteOutlined
                        iconSize: 16
                    }
                }
            }


        }

    }


    NewProjectPopup{
        id:popup
        x: (parent.width - width) * 0.5
        y: (parent.height - height) * 0.5
        width: 800
        height: 600
    }
}




