pragma Singleton
import QtQuick
import Qt.labs.platform as Platform

QtObject {
    id: root
    // 信号：选择完成时发出
    signal folderSelected(string folderPath)

    property var folderDialog: Platform.FolderDialog {
        id: internalDialog
        folder: Platform.StandardPaths.writableLocation(Platform.StandardPaths.HomeLocation)

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
            console.log(defaultFolder)
            internalDialog.folder = defaultFolder
        }
        internalDialog.open()
    }
}
