import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import HuskarUI.Basic



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
                delegate: HusCard {
                    width: 312
                    height: 200
                    bodyAvatarSize: 80
                    title: _title
                    bodyAvatarIcon:HusIcon.AccountBookFilled

                    extraDelegate: HusButton{
                        text:"删除"
                        type: HusButton.Type_Link
                    }
                    bodyDelegate: Item{
                        height: parent.height-actionDelegate.implictHeight


                        HusText{
                            text: _imagePath
                        }
                        HusText{
                            text: _resultPath
                        }

                    }
                    actionDelegate: Item {
                        height: 45
                        HusDivider {
                            width: parent.width
                            height: 1
                        }
                        RowLayout {
                            width: parent.width
                            height: parent.height

                            HusIconButton {
                                Layout.preferredWidth: parent.width / 3
                                Layout.fillHeight: true
                                type: HusButton.Type_Text
                                iconSource: HusIcon.SettingOutlined
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

                                HusIconText {
                                    anchors.centerIn: parent
                                    iconSource: HusIcon.EditOutlined
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

                                HusIconText {
                                    anchors.centerIn: parent
                                    iconSource: HusIcon.EllipsisOutlined
                                    iconSize: 16
                                }
                            }
                        }
                    }
                }
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
        }
        ListElement{
            _title:"我是猪"
            _imagePath:"/user/local/bin/images"
            _resultPath:"/user/local/bin/results"
            _type: "Detection"
        }
        ListElement{
            _title:"我是猪"
            _imagePath:"/user/local/bin/images"
            _resultPath:"/user/local/bin/results"
            _type: "Detection"
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




