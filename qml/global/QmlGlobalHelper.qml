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
    signal colorSelected(selectColod: color)

    property var rootWindow: null
    property HusMessage message: null
    property StackView mainStackView: null


    property Component messageComponent: Component {
        id: messageComponent
        HusMessage {
            z: 999
            width: parent ? parent.width : 0
            anchors.horizontalCenter: parent ? parent.horizontalCenter : undefined
            anchors.top: parent ? parent.top : undefined
        }
    }

    function initialize(window) {
        rootWindow = window
        if (!message) {
            message = messageComponent.createObject(window)
        }
    }

    property var fileDialog: FileDialog {
        id: internalFileDialog
        nameFilters: ["所有文件(*.*)" , "图像文件(*.jpg *.png *.bmp *.jpeg)", "文本文件(*.txt)","json文件(*.json)"]
        currentFolder: StandardPaths.writableLocation(StandardPaths.HomeLocation)
        onAccepted: {

        }
    }

    property var folderDialog: FolderDialog {
        id: internalFolderDialog
        currentFolder: StandardPaths.writableLocation(StandardPaths.HomeLocation)
        onAccepted: {
            var folderPath = currentFolder.toString().replace("file:///", "")
            root.folderSelected(folderPath)
        }
    }


    property var colorDialog: ColorDialog {
        id: internalColorDialog
        onAccepted: colorSelected(selectedColor)
    }

    function revertColor(color){
        let color_ = Qt.color(color)
        return Qt.rgba(1-color_.r, 1-color_.g, 1-color_.b, color_.a)
    }

    function getColor(colorBase, index){
        return HusThemeFunctions.genColor(colorBase,!HusTheme.isDark,HusTheme.Primary.colorBgBase)[index]
    }

    function openColorDialog(color) {
        if(color){
            internalColorDialog.selectedColor=color
        }
        internalColorDialog.open()
    }


    // 公开的打开方法
    function openFolderDialog(title, defaultFolder) {
        if (title) {
            internalFolderDialog.title = title
        }
        if (defaultFolder) {
            var correctP = correctPath(defaultFolder)
            internalFolderDialog.currentFolder = correctP
        }
        internalFolderDialog.open()
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
                return "file:///" + StandardPaths.writableLocation(StandardPaths.HomeLocation) + "/" + path
            }
        } else {
            // Linux/Mac 路径处理
            return "file://" + path
        }
    }
}
