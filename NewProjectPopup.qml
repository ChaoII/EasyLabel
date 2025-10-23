import QtQuick
import HuskarUI.Basic
import QtQuick.Controls


HusPopup {
    id: popup
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
            anchors.left: parent.left
            anchors.verticalCenter: btnClose.verticalCenter
            anchors.leftMargin: 10
            text:"新建项目"
        }

        HusDivider {
            anchors.top:btnClose.bottom
            width: parent.width
            height: 1
        }
    }
}

