#ProjectPopup.qml
import QtQuick
import HuskarUI.Basic
import QtQuick.Controls
import QtQuick.Layouts
import EasyLabel


PopupStandardWindow{
    id: popup
    property int mode: GlobalEnum.DialogMode.Create
    property var projectData: null
    property int index: 0
    property Item detailItem: popup.loaderItem.loaderItem
    signal formDataEditFinished(int index, var projectData)
    title: mode === GlobalEnum.DialogMode.Edit ? qsTr("编辑项目") : qsTr("新建项目")
    contentDelegate: _contentComponent

    onAccepted: {
        projectData = popup.getFormData()
        formDataEditFinished(popup.index, projectData)
        popup.close()
    }

    onRejected:{
        popup.resetForm()
        popup.close()
    }

    Component{
        id:_contentComponent
        Item{
            id: content
            anchors.fill: parent
            property int annotationType: GlobalEnum.AnnotationType.Detection
            property Item loaderItem: detailLoader.item
            onAnnotationTypeChanged:{
                if(annotationType===GlobalEnum.AnnotationType.Detection){
                    _menu.gotoMenu("Detection")
                }
                else if(annotationType===GlobalEnum.AnnotationType.RotatedBox){
                    _menu.gotoMenu("RotatedBox")
                }else{
                    _menu.gotoMenu("Other")
                }
            }
            HusMenu {
                id: _menu
                Layout.fillHeight: true
                showEdge:true
                defaultMenuWidth: 200
                height: parent.height
                initModel: [
                    {key:"Detection", label: qsTr('目标检测'), value: GlobalEnum.AnnotationType.Detection },
                    {key:"RotatedBox", label: qsTr('旋转框检测'), value: GlobalEnum.AnnotationType.RotatedBox },
                    {key:"Other", label: qsTr('其它'), value: GlobalEnum.AnnotationType.Other }
                ]
                onClickMenu: function(deep, key, keyPath, data) {
                    if(data.value===GlobalEnum.AnnotationType.Detection){
                        detailLoader.sourceComponent = detectionDetail
                    }else if(data.value===GlobalEnum.AnnotationType.RotatedBox){
                        detailLoader.sourceComponent = rotatedBoxDetail
                    }else{
                        detailLoader.sourceComponent = otherDetail
                    }
                }
            }

            Loader{
                id: detailLoader
                anchors.left: _menu.right
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                sourceComponent:annotationType === GlobalEnum.AnnotationType.Detection? detectionDetail: rotatedBoxDetail
            }
        }

    }

    Component{
        id: rotatedBoxDetail
        HusRectangle{
            anchors.fill: parent
            color: "red"
            function _reset(){
            }

            function _loadFormData(formData){
            }

            function _getFormData(){
                return {
                }
            }
        }
    }

    Component{
        id: otherDetail
        HusRectangle{
            anchors.fill: parent
            color: "yellow"
            function _reset(){
            }

            function _loadFormData(formData){
            }

            function _getFormData(){
                return {
                }
            }
        }

    }

    Component{
        id: detectionDetail
        ScrollView{
            id: scrollView
            property int labelWidth: 120
            property var formData: null
            anchors.fill: parent
            contentWidth: width
            contentHeight: columnLayout.implicitHeight
            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
            ScrollBar.vertical: HusScrollBar { policy:ScrollBar.AsNeeded}
            ColumnLayout{
                id: columnLayout
                // 填充的是contentHeight和 contentWidth
                anchors.fill: parent
                anchors.leftMargin: 40
                anchors.rightMargin: 40
                spacing: 20
                RowLayout{
                    id: layoutName
                    HusText{
                        Layout.preferredWidth: labelWidth
                        text:"项目名称："
                    }
                    HusInput{
                        id:inputProjectName
                        Layout.fillWidth: true
                        placeholderText: "请输入项目名称"
                        text:""
                    }
                }
                RowLayout{
                    id: layoutImage
                    HusText{
                        Layout.preferredWidth: labelWidth
                        text:"选择图片文件夹："
                    }
                    DirSelectInput{
                        id: dirSelectImageFolder
                        Layout.fillWidth: true
                        text:""
                    }
                }
                RowLayout{
                    id: layoutResult
                    HusText{
                        Layout.preferredWidth: labelWidth
                        text:"选择结果文件夹："
                    }
                    DirSelectInput{
                        id:dirSelectResultFolder
                        Layout.fillWidth: true
                        text:""
                    }
                }
                RowLayout{
                    id: layoutOutOfTarget
                    height: layoutName.height
                    HusText{
                        Layout.preferredWidth: labelWidth
                        text:"目标外标注："
                    }
                    HusSwitch{
                        id:switchOutOfTarget
                        checked: false
                    }
                }
                RowLayout{
                    height: layoutName.height
                    HusText{
                        Layout.preferredWidth: labelWidth
                        text:"显示标注顺序"
                    }
                    HusSwitch{
                        id: switchShowOrder
                        checked: false
                    }
                }
            }
            function _reset(){
                inputProjectName.text = ""
                dirSelectImageFolder.text=""
                dirSelectResultFolder.text=""
                switchOutOfTarget.checked=false
                switchShowOrder.checked=false
            }

            function _loadFormData(formData){
                inputProjectName.text = formData.projectName||""
                dirSelectImageFolder.text=formData.imageFolder||""
                dirSelectResultFolder.text=formData.resultFolder||""
                switchOutOfTarget.checked=formData.outOfTarget||false
                switchShowOrder.checked=formData.showOrder||false
            }

            function _getFormData(){
                return {
                    projectName: inputProjectName.text,
                    imageFolder: dirSelectImageFolder.text,
                    resultFolder: dirSelectResultFolder.text,
                    outOfTarget: switchOutOfTarget.checked,
                    showOrder: switchShowOrder.checked,
                    annotationType: GlobalEnum.AnnotationType.Detection
                }
            }
        }
    }

    function openProjectInfo(index, data){
        if (data) {
            popup.index = index
            popup.projectData = data
            popup.loadFormData(data)
            popup.mode = GlobalEnum.DialogMode.Edit
        } else {
            popup.resetForm()
            popup.mode = GlobalEnum.DialogMode.Create
        }
        popup.open()
    }

    // 内部方法
    function loadFormData(data) {
        popup.loaderItem.annotationType = data.annotationType
        popup.detailItem._loadFormData(data)
    }

    function resetForm() {
        popup.detailItem._reset(data)
    }

    function getFormData() {
        var fromData = popup.detailItem._getFormData()
        return fromData
    }
}
