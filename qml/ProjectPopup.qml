import QtQuick
import HuskarUI.Basic
import QtQuick.Controls
import QtQuick.Layouts
import EasyLabel


PopupStandardWindow{
    id: popup
    enum DialogMode {
        Create = 0,
        Edit = 1
    }

    enum AnnotationType {
        Detection = 0,
        RotatedBox=1
    }

    property int mode: ProjectPopup.DialogMode.Create
    property var projectData: null
    property string _projectName: ""
    property string _imageFolder: ""
    property string _resultFolder: ""
    property bool _outOfTarget: false
    property bool _showOrder: false
    property int _annotationType: ProjectPopup.AnnotationType.Detection
    title: mode === ProjectPopup.DialogMode.Edit ? qsTr("编辑项目") : qsTr("新建项目")
    contentDelegate: Item{
        anchors.fill: parent
        HusMenu {
            id: menu
            Layout.fillHeight: true
            showEdge:true
            defaultMenuWidth: 200
            height: parent.height
            initModel: [
                {key:"Detection", label: qsTr('目标检测'), value: ProjectPopup.AnnotationType.Detection },
                {key:"RotatedBox", label: qsTr('旋转框检测'), value: ProjectPopup.AnnotationType.RotatedBox }
            ]
            onClickMenu: function(deep, key, keyPath, data) {
                if(data.value===ProjectPopup.AnnotationType.Detection){
                    detailLoader.sourceComponent = detectionDetail
                }else{
                    detailLoader.sourceComponent = rotatedBoxDetail
                }
            }

            Component.onCompleted: {
                switch(_annotationType){
                case ProjectPopup.AnnotationType.Detection:{
                    gotoMenu("Detection")
                    break
                }
                case ProjectPopup.AnnotationType.RotatedBox:{
                    gotoMenu("RotatedBox")
                    break
                }
                default:
                    gotoMenu("Detection")
                }
            }
        }
        Loader{
            id: detailLoader
            anchors.left: menu.right
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            sourceComponent:_annotationType === ProjectPopup.AnnotationType.Detection? detectionDetail: rotatedBoxDetail
        }
    }

    Component{
        id: rotatedBoxDetail
        HusRectangle{
            anchors.fill: parent
            color: "red"
        }
    }

    Component{
        id: detectionDetail
        ScrollView{
            id: scrollView
            property int labelWidth: 120
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
                        Layout.fillWidth: true
                        placeholderText: "请输入项目名称"
                        text: _projectName
                        Component.onCompleted: {
                        }
                    }
                }

                RowLayout{
                    id: layoutImage
                    HusText{
                        Layout.preferredWidth: labelWidth
                        text:"选择图片文件夹："
                    }
                    DirSelectInput{
                        Layout.fillWidth: true
                        text:_imageFolder
                    }
                }

                RowLayout{
                    id: layoutResult
                    HusText{
                        Layout.preferredWidth: labelWidth
                        text:"选择结果文件夹："
                    }
                    DirSelectInput{
                        Layout.fillWidth: true
                        text:_resultFolder
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
                        enabled: _outOfTarget
                    }
                }
                RowLayout{
                    height: layoutName.height
                    HusText{
                        Layout.preferredWidth: labelWidth
                        text:"显示标注顺序"
                    }
                    HusSwitch{
                        enabled: _showOrder
                    }
                }
            }
        }
    }

    function openProjectInfo(data){
        if (data) {
            popup.projectData = data
            popup._loadFormData(data)
            popup.mode = ProjectPopup.DialogMode.Edit
        } else {
            popup._resetForm()
            popup.mode = ProjectPopup.DialogMode.Create
        }
        popup.open()
    }

    // 内部方法
    function _loadFormData(data) {
        _projectName = data.projectName || ""
        _imageFolder = data.imagePath || ""
        _resultFolder = data.resultPath || ""
        _outOfTarget = data.outOfTarget || false
        _showOrder = data.showOrder || false
        _annotationType = data.annotationType || ProjectPopup.AnnotationType.Detection
    }

    function _resetForm() {
        _projectName = ""
        _imageFolder = ""
        _resultFolder = ""
        _outOfTarget = false
        _showOrder = false
        _annotationType = ProjectPopup.AnnotationType.Detection
    }

    function getFormData() {
        return {
            projectName: _projectName,
            imagePath: _imageFolder,
            resultPath: _resultFolder,
            outOfTarget: _outOfTarget,
            showOrder: _showOrder,
            annotationType: _annotationType
        }
    }
}
