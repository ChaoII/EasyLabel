import QtQuick
import HuskarUI.Basic
import QtQuick.Layouts
import EasyLabel

Item{
    required property AnnotationConfig annotationConfig

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
        model: annotationConfig.currentAnnotationModel
        delegate: HusRectangle {
            id:ccc
            width: listView.width
            height: 30
            required property int labelID
            required property int index
            required property bool selected
            property color labelColor : annotationConfig.labelListModel.getLabelColor(labelID)
            property string label: annotationConfig.labelListModel.getLabel(labelID)
            property bool isCurrent: selected
            property bool isHovered: itemMouseArea.containsMouse ||btnDelete.hovered || btnEdit.hovered
            property bool isEditing: false
            Connections{
                target:annotationConfig.labelListModel
                function onDataChanged(){
                    labelColor = annotationConfig.labelListModel.getLabelColor(labelID)
                    label= annotationConfig.labelListModel.getLabel(labelID)
                }
            }

            color: {
                if (isCurrent) return HusThemeFunctions.alpha(HusTheme.Primary.colorPrimaryBgActive, 0.45)
                else if (isHovered) return HusThemeFunctions.alpha(HusTheme.Primary.colorPrimaryBgActive, 0.25)
                else return index % 2 !== 0 ? HusTheme.HusTableView.colorCellBgHover : HusTheme.HusTableView.colorCellBg;
            }

            MouseArea {
                id: itemMouseArea
                anchors.fill: parent
                hoverEnabled: true
                onClicked: annotationConfig.currentAnnotationModel.setSingleSelected(index)
                onDoubleClicked: isEditing = true
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
                // 根据编辑状态切换显示
                Loader {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    sourceComponent: isEditing ? editComponent : displayComponent
                }

                Component{
                    id:displayComponent
                    HusText {
                        text: label
                        verticalAlignment: HusText.AlignVCenter
                    }
                }

                Component{
                    id: editComponent
                    HusSelect {
                        editable: false
                        clearEnabled: false
                        model:annotationConfig.labelListModel
                        textRole: "label"
                        currentIndex: labelID
                        onCurrentIndexChanged: {
                            ccc.isEditing = false

                            annotationConfig.currentAnnotationModel.setLabelID(index, currentIndex)
                        }
                    }
                }


                Item{
                    Layout.fillWidth: true
                }
                HusIconButton {
                    id: btnEdit
                    Layout.preferredWidth:  24
                    Layout.preferredHeight:  24
                    type: HusButton.Type_Link
                    iconSource: HusIcon.EditOutlined
                    onClicked: {
                        annotationConfig.currentAnnotationModel.setSingleSelected(index)
                    }
                }
                HusIconButton {
                    id:btnDelete
                    Layout.preferredWidth: 24
                    Layout.preferredHeight: 24
                    type: HusButton.Type_Link
                    iconSource: HusIcon.DeleteOutlined




                    onClicked: {
                        annotationConfig.currentAnnotationModel.removeItem(index)
                    }
                }
            }
        }
    }
}


