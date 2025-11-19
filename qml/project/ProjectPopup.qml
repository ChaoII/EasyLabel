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
            property int annotationType: AnnotationConfig.Detection
            property Item loaderItem: detailLoader.item
            onAnnotationTypeChanged:{
                gotoMenuByAnnotationType()
            }
            HusMenu {
                id: _menu
                Layout.fillHeight: true
                showEdge:true
                defaultMenuWidth: 200
                height: parent.height
                initModel: [
                    {key:"Detection", label: qsTr('目标检测'), value: AnnotationConfig.Detection },
                    {key:"RotatedBox", label: qsTr('旋转框检测'), value: AnnotationConfig.RotatedBox },
                    {key:"Other", label: qsTr('其它'), value: AnnotationConfig.Other }
                ]
                onClickMenu: function(deep, key, keyPath, data) {
                    if(data.value===AnnotationConfig.Detection){
                        detailLoader.source = "DetectionDetailComponent.qml"
                    }else if(data.value===AnnotationConfig.RotatedBox){
                        detailLoader.source = "RotatedBoxDetailComponent.qml"
                    }else{
                        detailLoader.source = "OtherDetailComponent.qml"
                    }
                }
                Component.onCompleted: {
                    gotoMenuByAnnotationType()
                }
            }
            Loader{
                id: detailLoader
                anchors.left: _menu.right
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                source: selsetComponentByAnnotation(annotationType)
            }
            function selsetComponentByAnnotation(annotationType){
                switch (annotationType){
                case AnnotationConfig.Detection:
                    return "DetectionDetailComponent.qml"
                case AnnotationConfig.RotatedBox:
                    return "RotatedBoxDetailComponent.qml"
                case AnnotationConfig.Other:
                    return "OtherDetailComponent.qml"
                default:
                    return "DetectionDetailComponent.qml"
                }
            }

            function gotoMenuByAnnotationType(){
                if(annotationType===AnnotationConfig.Detection){
                    _menu.gotoMenu("Detection")
                }
                else if(annotationType===AnnotationConfig.RotatedBox){
                    _menu.gotoMenu("RotatedBox")
                }else{
                    _menu.gotoMenu("Other")
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
        if(mode===GlobalEnum.Create){
            fromData["createTime"] = QmlUtilsCpp.now()
            fromData["updateTime"] = QmlUtilsCpp.now()
        }if(mode===GlobalEnum.Edit){
            fromData["updateTime"] = QmlUtilsCpp.now()
        }
        return fromData
    }
}
