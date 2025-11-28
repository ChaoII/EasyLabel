
import QtQuick
import HuskarUI.Basic
import QtQuick.Controls
import QtQuick.Layouts
import EasyLabel


Item{
    id: detectionDetail
    property int labelWidth: 120
    property var formData: null
    ScrollView{
        id: scrollView
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

    }
    function _reset(){
        inputProjectName.text = ""
        dirSelectImageFolder.text = ""
        dirSelectResultFolder.text = ""
        switchOutOfTarget.checked= false
        switchShowOrder.checked = false
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
            annotationType: AnnotationConfig.Segmentation
        }
    }
}

