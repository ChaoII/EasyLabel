import QtQuick
import QtCore
import QtQuick.Dialogs
import HuskarUI.Basic

Item {
    id: dirSelect
    property alias text: textInput.text
    property alias placeholderText: textInput.placeholderText
    property string dialogTitle: "选择文件夹"
    property bool shouldBind: true
    height: 30
    width: 320
    HusInput {
        id: textInput
        anchors.left: parent.left
        anchors.right: iconBtn.left
        radiusBg.topRight: 0
        radiusBg.bottomRight: 0
        placeholderText: "请选择文件夹"
        text: dirSelect.text
    }

    HusIconButton {
        id: iconBtn
        width: 30
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        type: HusButton.Type_Primary
        radiusBg.topLeft: 0
        radiusBg.bottomLeft: 0
        iconSource: HusIcon.FolderOpenOutlined
        onClicked: {
            folderDialog.open()
        }
    }

    FolderDialog {
        id: folderDialog
        title: dialogTitle
        currentFolder: StandardPaths.writableLocation(StandardPaths.HomeLocation)
        onAccepted: {
            // 获取文件夹路径（去掉 file:// 前缀）
            var folderPath = currentFolder.toString().replace("file:///", "")
            textInput.text = folderPath
        }
    }
}
