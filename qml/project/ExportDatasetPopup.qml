#ExportDatasetPopup.qml
import QtQuick
import HuskarUI.Basic
import QtQuick.Layouts
import EasyLabel
import QtQuick.Controls



HusPopup {
    id: exportDatasetPopup
    property alias title: txtTitle.text
    property alias exportDir: dirSelectExport.text
    property alias exportTemplate: dirExportTemplate.text
    property alias trainSplitRate: trainNum.value
    property alias exportImage: switchExportImage.checked
    property alias exportTypeModel: selectExportType.model
    property alias exportType: selectExportType.currentValue
    property int annotationType: -1

    signal accepted()
    signal rejected()

    x: (parent.width - width) * 0.5
    y: (parent.height - height) * 0.5
    parent: Overlay.overlay
    closePolicy: HusPopup.NoAutoClose
    movable: true
    modal: true
    resizable: false
    minimumX: 0
    minimumY: 0
    maximumX: parent.width - width
    maximumY: parent.height - height
    Overlay.modal: Rectangle {
        color: "#90000000"
    }
    contentItem: Item {
        HusCaptionButton {
            id: btnClose
            anchors.right: parent.right
            radiusBg.all: exportDatasetPopup.radiusBg.all * 0.5
            colorText: colorIcon
            iconSource: HusIcon.CloseOutlined
            onClicked: exportDatasetPopup.close();
        }

        HusText{
            id: txtTitle
            anchors.left: parent.left
            anchors.verticalCenter: btnClose.verticalCenter
            anchors.leftMargin: 10
            text:"新建项目"
        }

        HusDivider {
            id: dividerTop
            anchors.top:btnClose.bottom
            width: parent.width
            height: 1
        }

        Item{
            id: content
            anchors.top: dividerTop.bottom
            anchors.bottom: dividerBottom.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: 40
            anchors.rightMargin: 40
            anchors.topMargin: 10
            anchors.bottomMargin: 10

            property int labelWidth: 100
            ColumnLayout{
                anchors.fill: parent
                spacing: 20


                RowLayout{
                    HusText{
                        Layout.preferredWidth: content.labelWidth
                        text:"导出类型"
                    }
                    HusSelect{
                        id: selectExportType
                        Layout.fillWidth: true
                        Layout.preferredHeight: 30
                        onCurrentValueChanged: {
                            let newPath = changeExportPath(dirSelectExport.text, currentText)
                            dirSelectExport.text = newPath
                        }
                    }
                }

                RowLayout{
                    HusText{
                        Layout.preferredWidth: content.labelWidth
                        text: "导出目录"
                    }
                    DirSelectInput{
                        id: dirSelectExport
                        Layout.fillWidth:true
                    }
                }

                RowLayout{
                    visible: exportDatasetPopup.annotationType === AnnotationConfig.KeyPoint
                    HusText{
                        Layout.preferredWidth: content.labelWidth
                        text: "导出模板"
                    }
                    DirSelectInput{
                        id: dirExportTemplate
                        Layout.fillWidth:true
                    }
                }

                RowLayout{
                    HusText{
                        Layout.preferredWidth: content.labelWidth
                        text:"导出图片"
                    }
                    Item{
                        Layout.fillWidth: true
                    }

                    HusSwitch {
                        id: switchExportImage
                        radiusBg.all: 2
                        animationEnabled: false
                        handleDelegate: HusRectangle {
                            radius: 2
                            color: switchExportImage.colorHandle
                        }
                        checked: true
                        checkedText: "是"
                        uncheckedText: "否"
                        onCheckedChanged: {

                        }
                    }
                }
                RowLayout{
                    HusText{
                        Layout.preferredWidth: content.labelWidth
                        text:"数据集划分"
                    }
                    Item{
                        Layout.fillWidth: true
                    }

                    HusSwitch {
                        id: switchDatasetSplit
                        radiusBg.all: 2
                        animationEnabled: false
                        checked: true
                        handleDelegate: HusRectangle {
                            radius: 2
                            color: switchDatasetSplit.colorHandle
                        }
                        checkedText: "是"
                        uncheckedText: "否"
                        onCheckedChanged: {

                        }
                    }
                }
                RowLayout{
                    visible: switchDatasetSplit.checked
                    spacing: 10
                    HusText{
                        text:"训练集"
                    }
                    HusInputNumber {
                        id:trainNum
                        Layout.fillWidth:true
                        afterLabel:"%"
                        value: 80
                        min: 60
                        max: 100
                    }
                    HusText{
                        text:"验证集"
                    }
                    HusInputNumber {
                        id:validNum
                        Layout.fillWidth:true
                        afterLabel: "%"
                        enabled: false
                        value: 100 - trainNum.value
                        min:0
                        max:40
                    }
                    Binding {
                        target: validNum
                        property: "value"
                        value: 100 - trainNum.value
                    }
                }
                Item{
                    Layout.fillHeight: true
                }
            }}
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
                Layout.fillHeight: true
                HusText{
                    id:textQuto
                    anchors.left: parent.left
                    anchors.top: parent.top
                    visible: exportProgress.percent > 0
                    text:"正在导出，请稍后..."
                }
                HusProgress{
                    id: exportProgress
                    status: HusProgress.Status_Active
                    animationEnabled: false
                    visible: percent > 0
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: textQuto.bottom
                    percent: 0
                }
            }
            HusButton {
                id: btnCancel
                text: "取消"
                type: HusButton.Type_Outlined
                onClicked:{
                    exportDatasetPopup.rejected()
                    close()
                }
            }
            HusButton {
                id: btnEnsure
                text: "确认"
                type: HusButton.Type_Primary
                focus: true
                onClicked:{
                    exportDatasetPopup.accepted()
                }
            }
        }
    }

    function updateExportProgress(progress){
        exportProgress.percent = progress
    }

    function changeExportPath(sourceDir, newDirName) {
        let newDir = ""
        var lastSlash = sourceDir.lastIndexOf("/")
        if (lastSlash !== -1) {
            newDir = sourceDir.substring(0, lastSlash) + "/" + newDirName
        } else {
            newDir = sourceDir + "/" + newDirName
        }
        return newDir
    }
}





