import QtQuick
import HuskarUI.Basic
import QtQuick.Controls
import QtQuick.Layouts
import EasyLabel

PopupStandardWindow{
    id: popup
    title:"新建项目"
    contentDelegate: Item{
        anchors.fill: parent
        HusMenu {
            id: menu
            Layout.fillHeight: true
            showEdge:true
            defaultMenuWidth: 200
            height: parent.height
            initModel: [
                {
                    label: qsTr('目标检测'),
                },
                {
                    label: qsTr('旋转框检测'),
                }
            ]
        }

        Loader{
            id: detailLoader
            anchors.left: menu.right
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            sourceComponent: detectionDetail
        }

    }

    Component{
        id: detectionDetail

        ScrollView{
            id: scrollView
            property int labelWidth: 120
            anchors.fill: parent
            contentWidth: width
            contentHeight: columnLayout.implicitHeight
            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
            ScrollBar.vertical: HusScrollBar { policy:ScrollBar.AsNeeded}
            ColumnLayout{
                id: columnLayout
                // 填充的是contentHeight和 contentWidth
                anchors.fill: parent
                anchors.leftMargin: 40
                anchors.rightMargin: 40
                spacing: 20
                RowLayout{
                    id: layoutName
                    HusText{
                        Layout.preferredWidth: labelWidth
                        text:"项目名称："
                    }
                    HusInput{
                        Layout.fillWidth: true
                        placeholderText: "请输入项目名称"
                        Component.onCompleted: {
                            console.log(width)
                        }
                    }
                }

                RowLayout{
                    id: layoutImage
                    HusText{
                        Layout.preferredWidth: labelWidth
                        text:"选择图片文件夹："
                    }
                    DirSelectInput{
                        Layout.fillWidth: true
                    }
                }

                RowLayout{
                    id: layoutResult
                    HusText{
                        Layout.preferredWidth: labelWidth
                        text:"选择结果文件夹："
                    }
                    DirSelectInput{
                        Layout.fillWidth: true
                    }
                }

                RowLayout{
                    id: layoutOutOfTarget
                    height: layoutName.height
                    HusText{
                        Layout.preferredWidth: labelWidth
                        text:"目标外标注："
                    }
                    HusSwitch{

                    }
                }
                RowLayout{
                    height: layoutName.height
                    HusText{
                        Layout.preferredWidth: labelWidth
                        text:"显示标注顺序"
                    }
                    HusSwitch{

                    }
                }
            }
        }
    }
}

