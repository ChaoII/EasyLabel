
import QtQuick
import HuskarUI.Basic
import QtQuick.Layouts
import QtQuick.Dialogs
import EasyLabel

Item{
    id: annotationLabelDetail
    required property AnnotationConfig annotationConfig

    implicitHeight: 200
    width: parent.width
    ColumnLayout{
        anchors.fill: parent
        RowLayout{
            HusText{
                text:"标签数: "+ listView.count
            }
            Item{
                Layout.fillWidth: true
            }
            HusIconButton{
                id:btnAdd
                type: HusButton.Type_Link
                iconSource: HusIcon.PlusOutlined
                onClicked: {
                    annotationLabelDetail.annotationConfig.labelListModel.addItem("untitled", "black")
                }
            }
        }

        ListView{
            id:listView
            focus: true
            clip: true
            Layout.fillWidth: true
            Layout.fillHeight: true
            highlightMoveDuration: 0
            keyNavigationEnabled: true
            model: annotationLabelDetail.annotationConfig.labelListModel
            delegate: HusRectangle {
                id: listViewDelegate
                width: ListView.view.width
                height: 30
                required property string label
                required property color labelColor
                required property bool selected
                required property int index
                property bool isCurrent: selected
                property bool isHovered: itemMouseArea.containsMouse || colorButton.hovered || btnDelete.hovered
                property bool isEditing: false

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
                        annotationLabelDetail.annotationConfig.labelListModel.setSingleSelected(listViewDelegate.index)
                    }
                    onDoubleClicked: {
                        listViewDelegate.isEditing = true
                    }
                }
                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    anchors.rightMargin: 10
                    ColorButton {
                        id: colorButton
                        Layout.preferredWidth: 16
                        Layout.preferredHeight: 16
                        currentColor: listViewDelegate.labelColor
                        onClicked:{
                            annotationLabelDetail.annotationConfig.labelListModel.setSingleSelected(listViewDelegate.index)
                            colorDialog.selectedColor = listViewDelegate.labelColor
                            colorDialog.open()
                        }
                        ColorDialog {
                            id: colorDialog
                            onAccepted: {
                                // 更新数据模型
                                annotationLabelDetail.annotationConfig.labelListModel.setLabelColor(listViewDelegate.index, selectedColor.toString())
                            }
                        }
                    }
                    // 根据编辑状态切换显示
                    Loader {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        sourceComponent: listViewDelegate.isEditing ? editComponent : displayComponent
                    }
                    HusIconButton {
                        id:btnDelete
                        visible: listViewDelegate.isHovered || hovered
                        Layout.preferredWidth:  24
                        Layout.preferredHeight:  24
                        type: HusButton.Type_Link
                        iconSource: HusIcon.DeleteOutlined
                        onClicked: {
                            annotationLabelDetail.annotationConfig.labelListModel.removeItem(listViewDelegate.index)
                        }
                    }
                }
                // 显示文本的组件
                Component {
                    id: displayComponent
                    HusText {
                        text: listViewDelegate.label
                        verticalAlignment: Text.AlignVCenter
                    }
                }

                // 编辑文本的组件
                Component {
                    id: editComponent
                    HusInput {
                        id: textInput
                        text: listViewDelegate.label
                        verticalAlignment: Text.AlignVCenter
                        selectByMouse: true
                        // 自动获取焦点并全选文本
                        Component.onCompleted: {
                            forceActiveFocus()
                            selectAll()
                        }
                        // 处理按键事件
                        Keys.onPressed: function(event)  {
                            if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                // 确认编辑
                                confirmEdit()
                            } else if (event.key === Qt.Key_Escape) {
                                // 取消编辑
                                cancelEdit()
                            }
                        }
                        // 失去焦点时确认编辑
                        onActiveFocusChanged: {
                            if (!activeFocus && listViewDelegate.isEditing) {
                                confirmEdit()
                            }
                        }
                        // 确认编辑
                        function confirmEdit() {
                            if (text.trim() !== "" && text !== listViewDelegate.label) {
                                // 更新数据模型
                                annotationLabelDetail.annotationConfig.labelListModel.setLabel(listViewDelegate.index, text)
                            }
                            listViewDelegate.isEditing = false
                        }
                        // 取消编辑
                        function cancelEdit() {
                            text = listViewDelegate.label
                            listViewDelegate.isEditing = false
                        }
                    }
                }
            }
        }

        Component.onCompleted: {
            if(listView.count > 0){
                annotationLabelDetail.annotationConfig.labelListModel.setSingleSelected(0)
            }
        }
    }
}


