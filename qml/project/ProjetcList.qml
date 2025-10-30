import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import HuskarUI.Basic
import EasyLabel


Item {
    id:root
    anchors.margins: 10
    anchors.fill: parent
    property var projectDto:ProjectDto{}
    property var listModel: []
    Component.onCompleted: {
        searchProject()
    }


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
        total: 0
        pageSizeModel: [
            { label: qsTr('10条每页'), value: 10 },
            { label: qsTr('20条每页'), value: 20 },
            { label: qsTr('30条每页'), value: 30 },
            { label: qsTr('40条每页'), value: 40 }
        ]
        onCurrentPageIndexChanged:{
            searchProject()
        }
        onPageSizeChanged: {
            searchProject()
        }
    }

    function searchProject(){
        pagination.total = projectDto.getProjectCount()
        let _limit = pagination.pageSize
        let _offset = pagination.pageSize* pagination.currentPageIndex
        let result = projectDto.getProjectList( _limit,  _offset, "createTime")
        listModel=result
    }

    function removeProject(index){
        let success = false
        if(index >= 0 && index < listModel.length){
            let formData = listModel[index]
            let removed = projectDto.removeProject(formData.id)
            searchProject()
            success = true
        }
        return success
    }

    Component{
        id:cardDetegate
        HusCard{
            id:_card
            required property int index
            required property var modelData
            property int fontSize: 12
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
                    text: modelData.projectName
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
                        text: GlobalEnum.annotationTypeStringMap[modelData.annotationType]
                        presetColor: GlobalEnum.annotationTagColorMap[modelData.annotationType]
                    }
                    RowLayout{
                        height: 20
                        HusText {
                            Layout.fillWidth: true
                            font.pixelSize: fontSize
                            text:"图片路径："+ modelData.imageFolder
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
                                QmlGlobalHelper.openFolderDialog("图像目录", modelData.imageFolder)
                            }
                        }
                    }
                    RowLayout{
                        height: 20
                        HusText{
                            Layout.fillWidth: true
                            font.pixelSize: fontSize
                            text:"结果路径："+ modelData.resultFolder
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
                                QmlGlobalHelper.openFolderDialog("结果目录", modelData.resultFolder)
                            }
                        }
                    }
                    HusText{
                        Layout.preferredHeight: 20
                        font.pixelSize: fontSize
                        text:"创建时间："+ modelData.createTime
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
                        onClicked:{
                            QmlGlobalHelper.message.info("message")
                        }
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
                            if(removeProject(index)){
                                QmlGlobalHelper.message.success("删除项目成功！")
                            }else{
                                QmlGlobalHelper.message.error("删除项目失败！")
                            }
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
                if(projectDto.insertProject(formData)){
                    QmlGlobalHelper.message.success("创建项目成功！")
                }else{
                    QmlGlobalHelper.message.error("创建项目失败！")
                }
                Qt.callLater(searchProject);
            }if(popup.mode === GlobalEnum.Edit){
                if (index >= 0 && index < listModel.length) {
                    var currentListItem = listModel[index]
                    console.log(JSON.stringify(formData))
                    currentListItem["projectName"] = formData.projectName || currentListItem.projectName
                    currentListItem["imageFolder"] = formData.imageFolder || currentListItem.imageFolder
                    currentListItem["resultFolder"] = formData.resultFolder || currentListItem.resultFolder
                    currentListItem["annotationType"] = formData.annotationType !== undefined ? formData.annotationType: currentListItem.annotationType
                    currentListItem["outOfTarget"] = formData.outOfTarget !== undefined ? formData.outOfTarget: currentListItem.outOfTarget
                    currentListItem["showOrder"] = formData.showOrder !== undefined ? formData.showOrder: currentListItem.showOrder
                    currentListItem["updateTime"] = formData.showOrder !== undefined ? formData.updateTime: currentListItem.showOrder
                    if(projectDto.updateProject(currentListItem)){
                        QmlGlobalHelper.message.success("修改项目成功！")
                    }else{
                        QmlGlobalHelper.message.error("修改项目失败！")
                    }
                    Qt.callLater(searchProject);
                }
            }
        }
    }
}
