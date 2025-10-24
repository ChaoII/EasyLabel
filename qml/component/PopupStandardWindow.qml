import QtQuick
import HuskarUI.Basic
import QtQuick.Controls
import QtQuick.Layouts


HusPopup {
    id: popup
    property alias title: txtTitle.text
    property Component contentDelegate: null
    x: (parent.width - width) * 0.5
    y: (parent.height - height) * 0.5
    width: 800
    height: 600
    parent: Overlay.overlay
    closePolicy: HusPopup.NoAutoClose
    movable: true
    modal: true
    resizable: false
    minimumX: 0
    minimumY: 0
    maximumX: parent.width - width
    maximumY: parent.height - height

    contentItem: Item {
        HusCaptionButton {
            id: btnClose
            anchors.right: parent.right
            radiusBg: popup.radiusBg * 0.5
            colorText: colorIcon
            iconSource: HusIcon.CloseOutlined
            onClicked: popup.close();
        }

        HusText{
            id: txtTitle
            anchors.left: parent.left
            anchors.verticalCenter: btnClose.verticalCenter
            anchors.leftMargin: 10
            text:"新建项目"
        }

        HusDivider {
            id: dividerTop
            anchors.top:btnClose.bottom
            width: parent.width
            height: 1
        }

        Loader {
            id: contentLoader
            anchors {
                top: dividerTop.bottom
                left: parent.left
                right: parent.right
                bottom: dividerBottom.top
                margins: 10
            }
            sourceComponent: popup.contentDelegate
        }

        HusDivider {
            id: dividerBottom
            anchors.bottom:btnLayout.top
            anchors.margins: 10
            width: parent.width
            height: 1
        }


        RowLayout{
            id: btnLayout
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.margins: 10

            Item{
                Layout.fillWidth: true
            }

            HusButton {
                id: btnCancel
                text: "取消"
                type: HusButton.Type_Outlined
            }

            HusButton {
                id: btnEnsure
                text: "确认"
                type: HusButton.Type_Primary
                focus: true
            }
        }
    }
}

