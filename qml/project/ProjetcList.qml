import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import HuskarUI.Basic
import EasyLabel


Item {
    id:root
    property alias searchProjectName: inputSecrch.text
    property string searchStartTime:""
    property string searchEndTime:""
    property var listModel: ProjectListModel{ }
    Component.onCompleted: {
        // searchProject()
    }
    Item{
        id: header
        height:30
        anchors.top : parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        HusButton{
            id: btnCreateProject
            anchors.left: parent.left
            type: HusButton.Type_Primary
            text: "创建项目"
            onClicked: {
                projectPopup.openProjectInfo()
            }
        }
        RowLayout{
            height:30
            anchors.right: parent.right
            HusDateTimePicker {
                id:dtpStart
                Layout.preferredWidth: 180
                placeholderText: qsTr('请选择开始日期时间')
                format: qsTr('yyyy-MM-dd hh:mm:ss')
                onSelected: (dateTime)=>{
                                searchStartTime = Qt.formatDateTime(dateTime, "yyyy-MM-ddThh:mm:ss.zzz")
                            }
            }
            HusText{
                text:"~"
            }
            HusDateTimePicker {
                id:dtpEnd
                Layout.preferredWidth: 180
                placeholderText: qsTr('请选择结束日期时间')
                format: qsTr('yyyy-MM-dd hh:mm:ss')
                onSelected: (dateTime)=>{
                                searchEndTime = Qt.formatDateTime(dateTime, "yyyy-MM-ddThh:mm:ss.zzz")
                            }
            }
            HusInput {
                id: inputSecrch
                Layout.preferredWidth: 180
                clearEnabled: true
                placeholderText: "请输入项目名称"
                text:""
            }
            HusIconButton {
                id: icoBtnSecrch
                width: 30
                type: HusButton.Type_Primary
                iconSource: HusIcon.SearchOutlined
                onClicked: {
                    searchProject()
                }
            }
        }
    }

    Flickable   {
        id: flickable
        anchors.top: header.bottom
        anchors.bottom: pagination.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.topMargin: 10
        anchors.bottomMargin: 10
        ScrollBar.vertical: HusScrollBar { policy:ScrollBar.AsNeeded}
        clip:true

        contentWidth: width
        contentHeight: flow.implicitHeight

        Flow{
            id: flow
            width: flickable.width
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
        pagination.total = listModel.getProjectCount(searchProjectName, searchStartTime, searchEndTime)
        listModel.pageSize = pagination.pageSize
        listModel.currentPage = pagination.currentPageIndex
        listModel.filterProjectListModel(searchProjectName, searchStartTime, searchEndTime);
    }

    function removeProject(index){
        let success = false
        if(index >= 0 && index < listModel.rowCount()){
            let projeID = listModel.getProperty(index, "id")
            let removed = listModel.removeItem(projeID)
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
            property AnnotationConfig annotationConfig: AnnotationConfig{
                annotationType: modelData.annotationType
                imageDir: modelData.imageFolder
                resultDir: modelData.resultFolder
                projectName: modelData.projectName
            }
            property color annotationTypeBaseColor
            property string annotationTypeName
            width: 310
            height: 200
            titleDelegate: null
            Component.onCompleted: {
                annotationTypeBaseColor = annotationConfig.getAnnotationTypeColor()
                annotationTypeName = annotationConfig.getAnnotationTypeName()
            }
            MouseArea{
                anchors.fill: parent
                onClicked: {
                    annotationConfig.loadAnnotationConfig()
                    QmlGlobalHelper.mainStackView.push("../canvas/MainCanvas.qml",{
                                                           annotationConfig: annotationConfig
                                                       })
                }
            }
            Item{
                id:itemTitle
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: 10
                height:20

                Connections{
                    target: annotationConfig
                    function onAnnotatedImageNumChanged(){
                        listModel.setProperty(index, "current", annotationConfig.annotatedImageNum)
                        listModel.setProperty(index, "total", annotationConfig.totalImageNum)
                        progressBar.percent = annotationConfig.annotatedImageNum/annotationConfig.totalImageNum *100
                    }
                }
                HusText{
                    id: txtTitle
                    width: parent.width * 0.6 - 10
                    height: parent.height
                    anchors.left: parent.left
                    verticalAlignment: HusText.AlignVCenter
                    text: modelData.projectName
                    elide: HusText.ElideRight
                }
                HusProgress {
                    id: progressBar
                    anchors.right: parent.right
                    width: parent.width * 0.4
                    barThickness: 2
                    percent: {
                        if(modelData.total<=0){
                            return 0
                        }
                        return modelData.current / modelData.total * 100
                    }
                    status: {
                        if(modelData.total > 0 && modelData.current === modelData.total){
                            return HusProgress.Status_Success
                        }
                        return HusProgress.Status_Active
                    }
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
                    font.family: "remixicon"
                    iconSize: 40
                    iconSource: GlobalEnum.annotationIconTextMap[modelData.annotationType]
                    colorIcon: annotationTypeBaseColor
                }
                ColumnLayout{
                    anchors.left: avator.right
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.right: parent.right
                    anchors.leftMargin: 10
                    HusTag{
                        id: textType
                        text: annotationTypeName
                        presetColor: annotationTypeBaseColor
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
                        projectPopup.openProjectInfo(index, modelData)
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
                            if(modelData.total <=0 || modelData.current !== modelData.total){
                                popconfirm.open()
                            }else{
                                let annotationType = annotationConfig.getExportAnnotationTypeName(0)
                                exportDatasetPopup.exportDir = modelData.resultFolder + "/"+ annotationType
                                exportDatasetPopup.updateExportProgress(0)
                                exportDatasetPopup.open()
                            }
                        }
                        HusPopconfirm {
                            id: popconfirm
                            x: (parent.width - width) * 0.5
                            y: parent.height + 6
                            width: 300
                            title: '警告'
                            description: "标注未完成，导出的数据集可能无法用于训练，当前标注进度: ["+ (modelData.current / (modelData.total + Number.MIN_VALUE) * 100).toFixed(1) + "%]，确认导出?"
                            confirmText: '是'
                            cancelText: '否'
                            onConfirm: {
                                let annotationType = annotationConfig.getExportAnnotationTypeName(0)
                                exportDatasetPopup.exportDir = modelData.resultFolder + "/"+ annotationType
                                exportDatasetPopup.updateExportProgress(0)
                                exportDatasetPopup.open()
                                close();
                            }
                            onCancel: {
                                close();
                            }
                        }

                    }
                    ExportDatasetPopup{
                        id: exportDatasetPopup
                        width: 480
                        height: 320
                        title: "导出标签"
                        exportTypeModel:annotationConfig.getExportAnnotationTypes()
                        Connections{
                            target: annotationConfig
                            function onExportProgress(porgress){
                                exportDatasetPopup.updateExportProgress(porgress)
                            }
                            function onExportFinished(){
                                QmlGlobalHelper.message.success("导出成功！"+ exportDatasetPopup.exportDir)
                                exportDatasetPopup.close()
                                exportDatasetPopup.enabled = true;
                            }
                            function onExportError(errorMsg){
                                QmlGlobalHelper.message.success("导出失败:" + errorMsg)
                                exportDatasetPopup.close()
                                exportDatasetPopup.enabled = true;
                            }
                        }
                        onAccepted: {
                            // trainSplitRate 是一个整数（1-100之间）
                            annotationConfig.exportAnnotation(exportDir, exportImage, exportType, trainSplitRate/100);
                            exportDatasetPopup.enabled = false;
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
        id: projectPopup
        x: (parent.width - width) * 0.5
        y: (parent.height - height) * 0.5
        width: 800
        height: 600
        Overlay.modal: Rectangle {
            color: "#90000000"  // 半透明黑色
        }
        onFormDataEditFinished: function(index, formData){
            if(projectPopup.mode === GlobalEnum.Create){
                let projectName = formData.projectName
                let imageFolder =formData.imageFolder
                let resultFolder = formData.resultFolder
                let annotationType = formData.annotationType
                let outOfTarget = formData.outOfTarget
                let showOrder = formData.showOrder
                if(listModel.addItem(projectName, imageFolder, resultFolder, annotationType, outOfTarget, showOrder)){
                    QmlGlobalHelper.message.success("创建项目成功！")
                }else{
                    QmlGlobalHelper.message.error("创建项目失败！")
                }
                Qt.callLater(searchProject);
            }if(projectPopup.mode === GlobalEnum.Edit){
                if (index >= 0 && index < listModel.rowCount()) {
                    let success = false
                    success = listModel.setProperty(index, "projectName", formData.projectName)
                    success = listModel.setProperty(index, "imageFolder", formData.imageFolder)
                    success = listModel.setProperty(index, "resultFolder", formData.resultFolder)
                    success = listModel.setProperty(index, "annotationType", formData.annotationType)
                    success = listModel.setProperty(index, "outOfTarget", formData.outOfTarget)
                    success = listModel.setProperty(index, "showOrder", formData.showOrder)
                    if(success){
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
