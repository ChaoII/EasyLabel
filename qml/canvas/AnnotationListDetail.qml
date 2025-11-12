import QtQuick
import HuskarUI.Basic
import QtQuick.Layouts

Item{
    implicitHeight: 200
    width: parent.width
    property ListModel dataModel:ListModel
    {
        ListElement{labelX:10;   labelY:30;   labelWidth:100;  labelHeight:100; label:"mouse"}
        ListElement{labelX:110;  labelY:130;  labelWidth:100;  labelHeight:100; label:"mouse"}
        ListElement{labelX:20;   labelY:230;  labelWidth:100;  labelHeight:100; label:"mouse"}
        ListElement{labelX:310;  labelY:330;  labelWidth:100;  labelHeight:100; label:"mouse"}
        ListElement{labelX:410;  labelY:30;   labelWidth:100;  labelHeight:100; label:"truck"}
        ListElement{labelX:510;  labelY:30;   labelWidth:100;  labelHeight:100; label:"truck"}

    }
    property int currentEditingIndex:-1
    ListView{
        id:listView
        anchors.fill: parent
        focus: true
        highlightMoveDuration: 0 // 取消高亮移动动画
        keyNavigationEnabled: true // 启用键盘导航
        model: dataModel
        delegate: Item {
            width: listView.width
            height: 30
            required property int labelX
            required property int labelY
            required property int labelWidth
            required property int labelHeight
            required property string label
            required property int index
            property color labelColor:"#FFFF00"

            property bool isCurrent: listView.currentIndex === index
            property bool isHovered: itemMouseArea.containsMouse ||btnDelete.hovered || btnEdit.hovered

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
                }
                RowLayout{
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    anchors.rightMargin: 10
                    HusRectangle {
                        id: colorButton
                        width: 24
                        height: 24
                        color: labelColor
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

                            listView.currentIndex = index
                        }
                    }
                    HusIconButton {
                        id:btnDelete
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
        }
    }
}


