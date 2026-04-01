import QtQuick
import QtCore
import QtQuick.Dialogs
import HuskarUI.Basic


HusSpace {
    id: dirSelect
    property alias text: textInput.text
    property alias placeholderText: textInput.placeholderText
    property string dialogTitle: "选择文件夹"
    layout: 'Row'
    height: 30
    width: 320
    HusInput {
        id: textInput
        height: dirSelect.height
        width: dirSelect.width - iconBtn.width
        placeholderText: "请选择文件夹"
        text: dirSelect.text
    }
    HusIconButton {
        id: iconBtn
        height: dirSelect.height
        width: dirSelect.height
        type: HusButton.Type_Primary
        iconSource: HusIcon.FolderOpenOutlined
        onClicked: {
            folderDialog.currentFolder = textInput.text.startsWith("file:///") ? textInput.text : "file:///"+textInput.text
            folderDialog.open()
        }
    }



    FolderDialog {
        id: folderDialog
        title: dialogTitle
        currentFolder: StandardPaths.writableLocation(StandardPaths.HomeLocation)
        onAccepted: {
            // 获取文件夹路径（去掉 file:// 前缀）
            let folderPath = ""
            if (Qt.platform.os === "windows"){
                folderPath = currentFolder.toString().replace("file:///", "")
            }else{
                folderPath = currentFolder.toString().replace("file://", "")
            }
            textInput.text = folderPath
        }
    }
}
