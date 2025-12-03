
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


    Component{
        id: popoverComponent
        HusPopover {
            property Item target: null
            id: popover
            y: target.height + 6
            width: 300
            contentDelegate:Item{
                height:300
                HusText{
                    id: txtTitle
                    height: 30
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.leftMargin: 10
                    verticalAlignment: HusText.AlignVCenter
                    text:"编辑标注"
                }
                HusDivider {
                    id: dividerTop
                    anchors.top:txtTitle.bottom
                    width: parent.width
                    height: 1
                }
                ColumnLayout{
                    id:columnLayout
                    anchors.top:  dividerTop.bottom
                    anchors.bottom: dividerBottom.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.margins: 10
                    RowLayout{
                        HusText{
                            Layout.preferredWidth: 80
                            text:"标签: "
                        }
                        HusSelect {
                            id: select
                            Layout.fillWidth: true
                            editable: false
                            clearEnabled: false
                            model: annotationListDetail.annotationConfig.labelListModel
                            textRole: "label"
                            currentIndex: target.labelID
                            property bool initialized: false
                            Component.onCompleted: {
                                initialized = true
                            }
                            onCurrentIndexChanged: {
                                if(initialized){
                                    annotationListDetail.annotationConfig.currentAnnotationModel.setLabelID(target.index, currentIndex)
                                    // listDelegate.isEditing = false
                                }
                            }
                        }
                    }

                    RowLayout{
                        HusText{
                            Layout.preferredWidth: 80
                            text:"组ID: "
                        }
                        HusInput {
                            id: inputGroupID
                            height: 30
                            Layout.fillWidth: true
                            clearEnabled: false
                            text:""
                        }
                    }
                    Item{
                        Layout.fillHeight: true
                    }
                }




                HusDivider {
                    id: dividerBottom
                    anchors.bottom:btnLayout.top
                    anchors.margins: 10
                    width: parent.width
                    height: 1
                }

                RowLayout{
                    id: btnLayout
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    anchors.margins: 10
                    Item{
                        Layout.fillWidth: true
                    }
                    HusButton {
                        id: btnCancel
                        text: "取消"
                        type: HusButton.Type_Outlined
                        onClicked:{
                            popup.rejected()
                        }
                    }
                    HusButton {
                        id: btnEnsure
                        text: "确认"
                        type: HusButton.Type_Primary
                        focus: true
                        onClicked:{
                            popup.accepted()
                        }
                    }
                }

            }
        }
    }

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
                onDoubleClicked: {
                    var item = popoverComponent.createObject(listDelegate,{target :listDelegate})
                    item.open()
                }
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

                HusText {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    text: listDelegate.label
                    verticalAlignment: HusText.AlignVCenter
                }
                //              Loader {
                //                  Layout.fillWidth: true
                //                  Layout.fillHeight: true
                //                  sourceComponent: listDelegate.isEditing ? editComponent : displayComponent
                //              }

                //              Component{
                //                  id:displayComponent

                //              }

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


