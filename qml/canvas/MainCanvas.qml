import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import HuskarUI.Basic
import EasyLabel


Item {
    id:root
    property alias projectName: textProjectName.text
    property int canvasX: 0
    property int canvasY: 0

    Item{
        id: header
        height:30
        anchors.top : parent.top
        anchors.left: parent.left
        anchors.right: parent.right

        HusCard{
            anchors.fill: parent
            bodyDelegate: null
            titleDelegate: null
            radius: 0
            border.color:"transparent"
        }

        // 返回按钮
        HusIconButton{
            id: btnBack
            anchors.left: parent.left
            type: HusButton.Type_Link
            iconSource: HusIcon.LeftOutlined
            onClicked: {
                QmlGlobalHelper.mainStackView.pop()
            }
        }
        HusText{
            anchors.left: btnBack.right
            anchors.leftMargin: 10
            anchors.verticalCenter: btnBack.verticalCenter
            id:textProjectName
        }

    }

    SplitView{
        id: splitView
        anchors.top: header.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.topMargin: 4
        handle: HusRectangle{
            implicitWidth: 4
            color:"transparent"
        }

        Item{
            id:splitLeft
            SplitView.fillWidth: true
            SplitView.fillHeight: true
            Item{
                id: graphicesView
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: footer.top
                anchors.bottomMargin: 4

                HusCard{
                    anchors.fill: parent
                    bodyDelegate: null
                    titleDelegate: null
                    radius: 0
                    border.color:"transparent"

                    MouseArea{
                        anchors.fill: parent
                        hoverEnabled: true
                        onPositionChanged:  {
                            console.log("asdasdasd")
                            canvasX = mouseX
                            canvasY = mouseY
                        }
                    }
                }
            }

            Item{
                id :footer
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                height:30
                HusCard{
                    anchors.fill: parent
                    bodyDelegate: null
                    titleDelegate: null
                    radius: 0
                    border.color:"transparent"
                    RowLayout{
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        anchors.rightMargin: 10
                        HusText{
                            text:"x: "
                        }
                        HusText{
                            width:50
                            text: canvasX
                        }
                        HusText{
                            text:"y: "
                        }
                        HusText{
                            width:50
                            text: canvasY
                        }
                        Item{
                            Layout.fillWidth: true
                        }
                        HusText{
                            Layout.preferredWidth: 300
                            horizontalAlignment: HusText.AlignRight
                            elide: HusText.ElideRight
                            text:"C:/User/aichao/Picture/1287.png"
                        }
                    }
                }
            }
        }
        Item{
            id: splitRight
            SplitView.fillHeight: true
            SplitView.preferredWidth: 280
            SplitView.maximumWidth: 400
            HusCard{
                anchors.fill: parent
                bodyDelegate: null
                radius: 0
                border.color:"transparent"
            }
        }

    }

    Component.onCompleted: {


    }
}
