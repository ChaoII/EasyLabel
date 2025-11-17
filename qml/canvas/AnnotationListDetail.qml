import QtQuick
import HuskarUI.Basic
import QtQuick.Layouts
import EasyLabel

Item{
    implicitHeight: 200
    width: parent.width
    property int currentEditingIndex: -1
    ListView{
        id:listView
        anchors.fill: parent
        focus: true
        highlightMoveDuration: 0
        keyNavigationEnabled: true
        currentIndex: -1  // 默认不选中任何项
        model: AnnotationConfig.currentAnnotationModel
        delegate: Item {
            width: listView.width
            height: 30
            required property int labelID
            required property int index
            required property bool selected
            property color labelColor : AnnotationConfig.labelListModel.getLabelColor(labelID)
            property string label: AnnotationConfig.labelListModel.getLabel(labelID)
            property bool isCurrent: selected
            property bool isHovered: itemMouseArea.containsMouse ||btnDelete.hovered || btnEdit.hovered
            Connections{
                target:AnnotationConfig.labelListModel
                function onDataChanged(){
                    labelColor = AnnotationConfig.labelListModel.getLabelColor(labelID)
                    label= AnnotationConfig.labelListModel.getLabel(labelID)
                }
            }
            HusRectangle {
                color: {
                    if (isCurrent) return HusThemeFunctions.alpha(HusTheme.Primary.colorPrimaryBgActive, 0.45)
                    else if (isHovered) return HusThemeFunctions.alpha(HusTheme.Primary.colorPrimaryBgActive, 0.25)
                    else return index % 2 !== 0 ? HusTheme.HusTableView.colorCellBgHover : HusTheme.HusTableView.colorCellBg;
                }
                anchors.fill: parent

                MouseArea {
                    id: itemMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: AnnotationConfig.currentAnnotationModel.setSingleSelected(index)
                }
                RowLayout{
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    anchors.rightMargin: 10
                    HusRectangle {
                        width: 16
                        height: 16
                        color:labelColor
                    }
                    HusText {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        text: label
                        verticalAlignment: HusText.AlignVCenter
                    }
                    Item{
                        Layout.fillWidth: true
                    }
                    HusIconButton {
                        id:btnEdit
                        Layout.preferredWidth:  24
                        Layout.preferredHeight:  24
                        type: HusButton.Type_Link
                        iconSource: HusIcon.EditOutlined
                        onClicked: {
                            AnnotationConfig.currentAnnotationModel.setSingleSelected(index)
                        }
                    }
                    HusIconButton {
                        id:btnDelete
                        Layout.preferredWidth:  24
                        Layout.preferredHeight:  24
                        type: HusButton.Type_Link
                        iconSource: HusIcon.DeleteOutlined
                        onClicked: {
                            AnnotationConfig.currentAnnotationModel.setSingleSelected(index)
                        }
                    }
                }
            }
        }
    }
}


