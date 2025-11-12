import QtQuick
import QtQuick.Layouts
import HuskarUI.Basic
import Qt.labs.folderlistmodel
import EasyLabel


Item{
    implicitHeight: 200
    width: parent.width
    property string currentFolder: Qt.resolvedUrl(".").toString().replace("file:///", "")

    FolderListModel {
        id: folderModel
        folder: "file:///" + currentFolder
        showDirs: true
        showFiles: true
        showDotAndDotDot: false
        nameFilters: ["*"]  // 所有文件
    }

    ListView {
        anchors.fill: parent
        model: folderModel
        delegate: Rectangle {
            width: ListView.view.width
            height: 30
            color: index % 2 === 0 ? "#f0f0f0" : "#ffffff"
            border.color: "#dddddd"

            HusText {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 10
                text: fileName + (fileIsDir ? "/" : "")
                color: fileIsDir ? "blue" : "black"
            }

            HusText {
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                anchors.rightMargin: 10
                text: fileIsDir ? "文件夹" : "文件"
                color: "gray"
                font.pixelSize: 12
            }
        }
    }
}

