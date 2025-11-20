import QtQuick
import QtQuick.Layouts
import HuskarUI.Basic
import EasyLabel


Item{
    required property AnnotationConfig annotationConfig
    implicitHeight: 200
    width: parent.width
    ListView {
        id: listView
        anchors.fill: parent
        model: annotationConfig.fileListModel
        currentIndex: annotationConfig.currentImageIndex
        delegate: Rectangle {
            width: ListView.view.width
            height: 30
            required property int index
            required property string fileName
            required property bool isDir
            required property bool isAnnotation
            property bool isCurrent: annotationConfig.currentImageIndex === index
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
                    annotationConfig.currentImageIndex = index
                }
            }

            RowLayout{
                anchors.fill: parent
                anchors.leftMargin: 10
                anchors.rightMargin: 10
                Rectangle{
                    property color baseColor: isAnnotation? "green" : "red"
                    width: 16
                    height: 16
                    radius: 8
                    color: QmlGlobalHelper.getColor(baseColor, 5)
                }

                HusText {
                    Layout.fillWidth: true
                    text: fileName
                }
            }
        }
    }
}

