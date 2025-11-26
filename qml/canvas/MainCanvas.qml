import QtQuick
import QtQuick.Controls
import HuskarUI.Basic
import EasyLabel

Item {
    id: root
    required property AnnotationConfig annotationConfig
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
            border.color: "transparent"
            Component.onCompleted: {
            }
        }

        // 返回按钮
        HusIconButton{
            id: btnBack
            anchors.left: parent.left
            type: HusButton.Type_Link
            iconSource: HusIcon.LeftOutlined
            onClicked: QmlGlobalHelper.mainStackView.pop()
            Component.onCompleted: {
            }

        }
        HusText{
            id:textProjectName
            anchors.left: btnBack.right
            anchors.leftMargin: 10
            anchors.verticalCenter: btnBack.verticalCenter
            text:root.annotationConfig.projectName
            Component.onCompleted: {
            }
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
        CentralAnnotationView{
            id: splitLeft
            SplitView.fillWidth: true
            SplitView.fillHeight: true
            annotationConfig: root.annotationConfig

            Component.onCompleted: {

            }
        }

        AnnotationDetailPanel{
            id: splitRight
            SplitView.fillHeight: true
            SplitView.preferredWidth: 280
            SplitView.maximumWidth: 400
            annotationConfig: root.annotationConfig
            Component.onCompleted: {
            }
        }
    }

}
