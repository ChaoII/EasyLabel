import QtQuick
import HuskarUI.Basic
import QtQuick.Controls
import QtQuick.Layouts
import Qt.labs.platform as Platform


Item {
    id: dirSelect
    property alias text: textInput.text
    property alias placeholderText: textInput.placeholderText
    property string dialogTitle: "选择文件夹"
    signal folderSelected(folderPath:string)
    height: 30
    width: 320

    HusInput {
        id: textInput
        anchors.left:parent.left
        anchors.right:parent.right
        rightPadding: iconBtn.width + 10
        placeholderText: "请选择文件夹"
        // 右侧搜索区域
        HusIconButton {
            id: iconBtn
            width: 30
            animationEnabled: false
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.margins: 2
            iconSource: HusIcon.FolderOpenOutlined
            colorBorder: "transparent"
            onClicked: {
                folderDialog.open()
            }
        }

        HusRectangle{
            width:1
            height: parent.height
            anchors.right: iconBtn.left
            border.color: parent.colorBorder
        }
    }

    Platform.FolderDialog {
        id: folderDialog
        title: dialogTitle
        folder: Platform.StandardPaths.writableLocation(Platform.StandardPaths.HomeLocation)
        onAccepted: {
            // 获取文件夹路径（去掉 file:// 前缀）
            var folderPath = currentFolder.toString().replace("file:///", "")
            textInput.text = folderPath
            folderSelected(folderPath)
        }
    }
}
