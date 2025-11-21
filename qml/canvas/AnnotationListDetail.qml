
import QtQuick
import HuskarUI.Basic
import QtQuick.Layouts
import EasyLabel

Item{
    id: annotationListDetail
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
        model: annotationListDetail.annotationConfig.currentAnnotationModel
        delegate: HusRectangle {
            id: listDelegate
            width: ListView.view.width
            height: 30
            required property int labelID
            required property int index
            required property bool selected
            property color labelColor : annotationListDetail.annotationConfig.labelListModel.getLabelColor(labelID)
            property string label: annotationListDetail.annotationConfig.labelListModel.getLabel(labelID)
            property bool isCurrent: selected
            property bool isHovered: itemMouseArea.containsMouse || btnDelete.hovered
            property bool isEditing: false
            Connections{
                target: annotationListDetail.annotationConfig.labelListModel
                function onDataChanged(){
                    listDelegate.labelColor = annotationListDetail.annotationConfig.labelListModel.getLabelColor(listDelegate.labelID)
                    listDelegate.label = annotationListDetail.annotationConfig.labelListModel.getLabel(listDelegate.labelID)
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
                onClicked: annotationListDetail.annotationConfig.currentAnnotationModel.setSingleSelected(listDelegate.index)
                onDoubleClicked: listDelegate.isEditing = true
            }
            RowLayout{
                anchors.fill: parent
                anchors.leftMargin: 10
                anchors.rightMargin: 10
                HusRectangle {
                    Layout.preferredWidth: 16
                    Layout.preferredHeight: 16
                    color: listDelegate.labelColor
                }
                // 根据编辑状态切换显示
                Loader {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    sourceComponent: listDelegate.isEditing ? editComponent : displayComponent
                }

                Component{
                    id:displayComponent
                    HusText {
                        text: listDelegate.label
                        verticalAlignment: HusText.AlignVCenter
                    }
                }

                Component{
                    id: editComponent
                    HusSelect {
                        editable: false
                        clearEnabled: false
                        model: annotationListDetail.annotationConfig.labelListModel
                        textRole: "label"
                        currentIndex: listDelegate.labelID
                        property bool initialized: false

                        Component.onCompleted: {
                            initialized = true
                        }
                        onCurrentIndexChanged: {
                            if(initialized){
                                annotationListDetail.annotationConfig.currentAnnotationModel.setLabelID(listDelegate.index, currentIndex)
                                listDelegate.isEditing = false
                            }
                        }
                    }
                }

                Item{
                    Layout.fillWidth: true
                }
                HusIconButton {
                    id:btnDelete
                    visible: listDelegate.isHovered
                    Layout.preferredWidth: 24
                    Layout.preferredHeight: 24
                    type: HusButton.Type_Link
                    iconSource: HusIcon.DeleteOutlined
                    onClicked: {
                        annotationListDetail.annotationConfig.currentAnnotationModel.removeItem(listDelegate.index)
                    }
                }
            }
        }
    }
}


