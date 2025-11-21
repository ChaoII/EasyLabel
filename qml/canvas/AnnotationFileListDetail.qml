
import QtQuick
import QtQuick.Layouts
import HuskarUI.Basic
import EasyLabel


Item{
    id: annotationFileListDetail
    required property AnnotationConfig annotationConfig
    implicitHeight: 200
    width: parent.width
    ListView {
        id: listView
        anchors.fill: parent
        model: annotationFileListDetail.annotationConfig.fileListModel
        currentIndex: annotationFileListDetail.annotationConfig.currentImageIndex
        delegate: Rectangle {
            id: listViewDelegate
            width: ListView.view.width
            height: 30
            required property int index
            required property string fileName
            required property bool isDir
            required property bool isAnnotation
            property bool isCurrent: annotationFileListDetail.annotationConfig.currentImageIndex === listViewDelegate.index
            property bool isHovered: itemMouseArea.containsMouse
            color: {
                if (isCurrent) return HusThemeFunctions.alpha(HusTheme.Primary.colorPrimaryBgActive, 0.45)
                else if (isHovered) return HusThemeFunctions.alpha(HusTheme.Primary.colorPrimaryBgActive, 0.25)
                else return index % 2 !== 0 ? HusTheme.HusTableView.colorCellBgHover : HusTheme.HusTableView.colorCellBg;
            }

            MouseArea {
                id: itemMouseArea
                anchors.fill: parent
                hoverEnabled: true
                onClicked: {
                    annotationFileListDetail.annotationConfig.currentImageIndex = listViewDelegate.index
                }
            }

            RowLayout{
                anchors.fill: parent
                anchors.leftMargin: 10
                anchors.rightMargin: 10
                Rectangle{
                    property color baseColor: listViewDelegate.isAnnotation? "green" : "red"
                    Layout.preferredWidth: 16
                    Layout.preferredHeight: 16
                    radius: 8
                    color: QmlGlobalHelper.getColor(baseColor, 5)
                }

                HusText {
                    Layout.fillWidth: true
                    text: listViewDelegate.fileName
                }
            }
        }
    }
}

