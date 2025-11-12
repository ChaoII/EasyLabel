import QtQuick
import HuskarUI.Basic
import QtQuick.Layouts
import QtQuick.Dialogs
import EasyLabel

Item{
    ColorDialog {
        id: colorDialog
        onAccepted: {
            // 更新数据模型
            dataModel.setProperty(currentEditingIndex,"labelColor",selectedColor.toString())
        }
    }
    implicitHeight: 200
    width: parent.width
    property var dataModel: []
    property int currentEditingIndex:-1

    ColumnLayout{
        anchors.fill: parent
        RowLayout{
            HusText{
                text:"标签数: "+ dataModel.length
            }
            Item{
                Layout.fillWidth: true
            }
            HusIconButton{
                id:btnAdd
                type: HusButton.Type_Link
                iconSource: HusIcon.PlusOutlined
                onClicked: {
                    dataModel.push({"label":"untitled","color":"black"})
                }
            }
        }

        ListView{
            id:listView
            focus: true
            clip: true
            Layout.fillWidth: true
            Layout.fillHeight: true
            highlightMoveDuration: 0 // 取消高亮移动动画
            keyNavigationEnabled: true // 启用键盘导航
            model: dataModel
            delegate: Item {
                width: listView.width
                height: 30
                required property string label
                required property color labelColor
                required property int index
                property bool isCurrent: listView.currentIndex === index
                property bool isHovered: itemMouseArea.containsMouse || colorButton.hovered
                property bool isEditing: false  // 新增编辑状态
                HusRectangle {
                    color: {
                        if (isCurrent) return HusThemeFunctions.alpha(HusTheme.Primary.colorPrimaryBgActive, 0.45)
                        else if (isHovered) return HusThemeFunctions.alpha(HusTheme.Primary.colorPrimaryBgActive, 0.25)
                        else return "transparent"
                    }
                    anchors.fill: parent

                    MouseArea {
                        id: itemMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: listView.currentIndex = index
                        onDoubleClicked: {
                            listView.currentIndex = index
                            isEditing = true
                            console.log(getLabelColor(label))
                        }
                    }
                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        anchors.rightMargin: 10
                        ColorButton {
                            id: colorButton
                            width: 24
                            height: 24
                            currentColor: labelColor
                            onClicked:{
                                listView.currentIndex = index
                                currentEditingIndex = index
                                colorDialog.selectedColor = labelColor
                                colorDialog.open()
                            }
                        }
                        // 根据编辑状态切换显示
                        Loader {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            sourceComponent: isEditing ? editComponent : displayComponent
                        }
                        HusIconButton {
                            id:btnDelete
                            visible: isHovered || hovered
                            Layout.preferredWidth:  24
                            Layout.preferredHeight:  24
                            type: HusButton.Type_Link
                            iconSource: HusIcon.DeleteOutlined
                            onClicked: {
                                listView.currentIndex = index
                            }
                        }
                    }
                }
                // 显示文本的组件
                Component {
                    id: displayComponent
                    HusText {
                        text: label
                        verticalAlignment: Text.AlignVCenter
                    }
                }

                // 编辑文本的组件
                Component {
                    id: editComponent
                    HusInput {
                        id: textInput
                        text: label
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
                            if (!activeFocus && isEditing) {
                                confirmEdit()
                            }
                        }
                        // 确认编辑
                        function confirmEdit() {
                            if (text.trim() !== "" && text !== label) {
                                // 更新数据模型
                                dataModel.setProperty(index,"label",text)
                            }
                            isEditing = false
                        }

                        // 取消编辑
                        function cancelEdit() {
                            text = label
                            isEditing = false
                        }
                    }
                }
            }
        }
    }
    function getLabelColor(label){
        for(let i=0;i<dataModel.count;i++){
            var data = dataModel.get(i)
            if(data.label === label){
                return data.labelColor
            }
        }
    }
}


