import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import HuskarUI.Basic


Item {
    id:root
    anchors.margins: 10
    anchors.fill: parent
    RowLayout{
        id: layoutBtn
        anchors.top : parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        HusButton{
            id: btnCreateProject
            type: HusButton.Type_Primary
            text: "创建项目"
            onClicked: {
                popup.openProjectInfo()
            }
        }
        Item{
            Layout.fillWidth: true
        }
        HusRadioBlock {
            initCheckedIndex: 0
            model: [
                { label: 'Apple', value: 'Apple' },
                { label: 'Pear', value: 'Pear' },
                { label: 'Orange', value: 'Orange' },
            ]
        }
    }
    ScrollView   {
        id: scrollView
        anchors.top: layoutBtn.bottom
        anchors.bottom: pagination.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.topMargin: 10
        anchors.bottomMargin: 10
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
        ScrollBar.vertical: HusScrollBar { policy:ScrollBar.AsNeeded}
        Flow{
            width: scrollView.width
            spacing: 10
            Repeater {
                model: listModel
                delegate: cardDetegate
            }
        }
    }

    HusPagination{
        id: pagination
        anchors.bottom: parent.bottom
        currentPageIndex: 0
        total: 50
        pageSizeModel: [
            { label: qsTr('10条每页'), value: 10 },
            { label: qsTr('20条每页'), value: 20 },
            { label: qsTr('30条每页'), value: 30 },
            { label: qsTr('40条每页'), value: 40 }
        ]
    }

    ListModel{
        id:listModel
        ListElement{
            projectName:"我是猪"
            imageFolder:"/user/local/bin/images"
            resultFolder:"/user/local/bin/results"
            annotationType: 0
            createTime:"2025-10-26 12:08:23"
            outOfTarget:false
            showOrder:true
        }
        ListElement{
            projectName:"我是猪"
            imageFolder:"/user/local/bin/images"
            resultFolder:"/user/local/bin/results"
            annotationType: 0
            createTime:"2025-10-26 12:08:23"
            outOfTarget:false
            showOrder:false
        }
        ListElement{
            projectName:"我是猪"
            imageFolder:"/user/local/bin/images"
            resultFolder:"/user/local/bin/results/user/local/bin/results"
            annotationType: 0
            createTime:"2025-10-26 12:08:23"
            outOfTarget:false
            showOrder:false
        }
        ListElement{
            projectName:"我是猪"
            imageFolder:"/user/local/bin/images"
            resultFolder:"/user/local/bin/results"
            annotationType: 1
            createTime:"2025-10-26 12:08:23"
            outOfTarget:true
            showOrder:false
        }
        ListElement{
            projectName:"我是猪"
            imageFolder:"/user/local/bin/images"
            resultFolder:"/user/local/bin/results"
            annotationType: 2
            createTime:"2025-10-26 12:08:23"
            outOfTarget:true
            showOrder:true
        }
    }

    Component{
        id:cardDetegate
        HusCard{
            id:_card
            required property var modelData
            required property int index
            required property string projectName
            required property string imageFolder
            required property string resultFolder
            required property string annotationType
            required property string createTime
            property int fontSize: 12
            readonly property var annotationTagColor:{
                0 : "red",
                1 : "blue",
                2 : "green"
            }
            width: 310
            height: 200
            titleDelegate: null

            Item{
                id:itemTitle
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: 10
                height:20

                HusText{
                    height: parent.height
                    anchors.left: parent.left
                    verticalAlignment: HusText.AlignVCenter
                    text: projectName
                }
            }

            HusDivider {
                id:dividerTop
                anchors.top: itemTitle.bottom
                anchors.margins: 10
                width: parent.width
                height: 1
            }

            Item{
                id: itemBody
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: dividerTop.bottom
                anchors.bottom: dividerBottom.top
                anchors.margins: 10
                HusIconText{
                    id: avator
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    iconSize: 40
                    iconSource: HusIcon.BorderOutlined
                }
                ColumnLayout{
                    anchors.left: avator.right
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.right: parent.right
                    anchors.leftMargin: 10
                    HusTag{
                        id: textType
                        text: annotationType
                        presetColor: _card.annotationTagColor[annotationType]
                    }
                    RowLayout{
                        height: 20
                        HusText {
                            Layout.fillWidth: true
                            font.pixelSize: fontSize
                            text:"图片路径："+ imageFolder
                            elide: Text.ElideRight
                            color: HusTheme.Primary.colorPrimaryTextDisabled
                        }
                        HusIconButton{
                            Layout.preferredHeight: parent.height
                            Layout.preferredWidth: 20
                            padding: 0
                            type: HusButton.Type_Link
                            iconSource: HusIcon.FolderOpenOutlined
                            onClicked: {
                                QmlGlobalHelper.openFolderDialog("图像目录", imageFolder)
                            }
                        }
                    }
                    RowLayout{
                        height: 20
                        HusText{
                            Layout.fillWidth: true
                            font.pixelSize: fontSize
                            text:"结果路径："+ resultFolder
                            elide: Text.ElideRight
                            color: HusTheme.Primary.colorPrimaryTextDisabled
                        }
                        HusIconButton{
                            Layout.preferredHeight: parent.height
                            Layout.preferredWidth: 20
                            padding: 0
                            type: HusButton.Type_Link
                            iconSource: HusIcon.FolderOpenOutlined
                            onClicked: {
                                QmlGlobalHelper.openFolderDialog("结果目录", resultFolder)
                            }
                        }
                    }
                    HusText{
                        Layout.preferredHeight: 20
                        font.pixelSize: fontSize
                        text:"创建时间："+ createTime
                        verticalAlignment: Text.AlignVCenter
                        color: HusTheme.Primary.colorPrimaryTextDisabled
                    }
                }
            }

            HusDivider {
                id:dividerBottom
                anchors.bottom:layoutAction.top
                width: parent.width
                height: 1
            }

            RowLayout {
                id: layoutAction
                anchors.bottom: parent.bottom
                height:40
                width: parent.width
                HusIconButton {
                    Layout.preferredWidth: parent.width / 3
                    Layout.fillHeight: true
                    type: HusButton.Type_Link
                    iconSource: HusIcon.EditOutlined
                    iconSize: 16
                    onClicked: {
                        popup.openProjectInfo(index, modelData)
                    }
                }
                Item {
                    Layout.preferredWidth: parent.width / 3
                    Layout.fillHeight: true
                    HusDivider {
                        width: 1
                        height: parent.height * 0.5
                        anchors.verticalCenter: parent.verticalCenter
                        orientation: Qt.Vertical
                    }
                    HusIconButton {
                        anchors.centerIn: parent
                        type: HusButton.Type_Link
                        iconSource: HusIcon.ExportOutlined
                        iconSize: 16
                    }
                }

                Item {
                    Layout.preferredWidth: parent.width / 3
                    Layout.fillHeight: true
                    HusDivider {
                        width: 1
                        height: parent.height * 0.5
                        anchors.verticalCenter: parent.verticalCenter
                        orientation: Qt.Vertical
                    }
                    HusIconButton {
                        anchors.centerIn: parent
                        type: HusButton.Type_Link
                        iconSource: HusIcon.DeleteOutlined
                        iconSize: 16
                        onClicked: {
                            listModel.remove(index, 1)
                            root.message1.success("吃粑粑")
                        }
                    }
                }
            }
        }
    }




    ProjectPopup{
        id: popup
        x: (parent.width - width) * 0.5
        y: (parent.height - height) * 0.5
        width: 800
        height: 600
        Overlay.modal: Rectangle {
            color: "#90000000"  // 半透明黑色
        }
        onFormDataEditFinished: function(index, formData){
            if(popup.mode === GlobalEnum.Create){
                listModel.append(formData)
                console.log("新增成功")
            }if(popup.mode === GlobalEnum.Edit){
                console.log("修改成功index:" + index)
                if (index >= 0 && index < listModel.count) {
                    var currentListItem = listModel.get(index)
                    console.log(JSON.stringify(formData))
                    console.log(currentListItem)
                    listModel.setProperty(index, "projectName", formData.projectName || currentListItem.projectName)
                    listModel.setProperty(index, "imageFolder", formData.imageFolder || currentListItem.imageFolder)
                    listModel.setProperty(index, "resultFolder", formData.resultFolder || currentListItem.resultFolder)
                    listModel.setProperty(index, "annotationType", formData.annotationType !== undefined ? formData.annotationType : currentListItem.annotationType)
                    listModel.setProperty(index, "outOfTarget", formData.outOfTarget !== undefined ? formData.outOfTarget : currentListItem.outOfTarget)
                    listModel.setProperty(index, "showOrder", formData.showOrder !== undefined ? formData.showOrder : currentListItem.showOrder)
                }
            }
        }
    }
}
