pragma Singleton
import QtQuick
import QtQuick.Controls
import QtCore
import QtQuick.Dialogs
import HuskarUI.Basic

QtObject {
    id: root

    // 信号：选择完成时发出
    signal folderSelected(string folderPath)

    property var rootWindow: null
    property HusMessage message: null



    property Component messageComponent: Component {
        id: messageComponent
        HusMessage {
            z: 999
            width: root.rootWindow ? root.rootWindow.width : 0
            anchors.horizontalCenter: root.rootWindow ? root.rootWindow.horizontalCenter : undefined
            anchors.top: root.rootWindow ? root.rootWindow.top : undefined
        }
    }

    function initialize(window) {
        rootWindow = window
        if (!message) {
            message = messageComponent.createObject(window)
        }
    }

    property var folderDialog: FolderDialog {
        id: internalDialog
        currentFolder: StandardPaths.writableLocation(StandardPaths.HomeLocation)
        onAccepted: {
            var folderPath = currentFolder.toString().replace("file:///", "")
            root.folderSelected(folderPath)
        }
    }

    // 公开的打开方法
    function openFolderDialog(title, defaultFolder) {
        if (title) {
            internalDialog.title = title
        }
        if (defaultFolder) {
            var correctP = correctPath(defaultFolder)
            internalDialog.currentFolder = correctP
        }
        internalDialog.open()
    }

    function correctPath(path) {
        // 如果已经是 URL 格式，直接返回
        if (path.startsWith("file:///")) {
            return path
        }
        // Windows 路径处理
        if (Qt.platform.os === "windows") {
            // 确保是绝对路径
            if (path.length >= 2 && path[1] === ':') {
                // 已经是绝对路径，添加 file:///
                return "file:///" + path
            } else {
                // 相对路径，转换为绝对路径
                return "file:///" + Platform.StandardPaths.writableLocation(Platform.StandardPaths.HomeLocation) + "/" + path
            }
        } else {
            // Linux/Mac 路径处理
            return "file://" + path
        }
    }
}
