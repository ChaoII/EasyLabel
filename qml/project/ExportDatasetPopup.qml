#ExportDatasetPopup.qml
import QtQuick
import HuskarUI.Basic
import QtQuick.Layouts
import EasyLabel

PopupStandardWindow{
    id: popup
    property string exportDir: loaderItem.internalExportDir
    property bool exportImage: loaderItem.internalExportImage
    property var exportTypeList: loaderItem.internalExportTypeModel
    readonly property var currentExportType: loaderItem.internalExportType
    property real tarinRate: loaderItem.internaltarinRate
    property bool isInitialed: false
    signal exportDataReady(string exportDir, bool exportImage, int currentExportType, real tarinRate)
    onAccepted: {
        popup.exportDataReady( popup.exportDir, popup.exportImage,
                              popup.currentExportType, popup.tarinRate/100)
    }
    Component.onCompleted: {
        isInitialed = true
    }
    onRejected:{
        popup.close()
    }
    onExportTypeListChanged:{
        if(isInitialed){
            loaderItem.internalExportTypeModel = popup.exportTypeList
        }
    }
    title: "数据导出"
    contentDelegate: _contentComponent
    Component{
        id: _contentComponent
        Item{
            id: content
            property int labelWidth: 100
            property alias internalExportDir: dirSelectExport.text
            property alias internaltarinRate: trainNum.value
            property alias internalExportImage: switchExportImage.checked
            property var internalExportTypeModel: []
            property alias internalExportType: selectExportType.currentValue
            ColumnLayout{
                anchors.fill: parent
                anchors.leftMargin: 40
                anchors.rightMargin: 40
                spacing: 20
                RowLayout{
                    HusText{
                        Layout.preferredWidth: content.labelWidth
                        text: "导出目录"
                    }
                    DirSelectInput{
                        id: dirSelectExport
                        Layout.fillWidth:true
                        text: content.internalExportDir
                    }
                }
                RowLayout{
                    HusText{
                        Layout.preferredWidth: content.labelWidth
                        text:"导出类型"
                    }
                    HusSelect{
                        id: selectExportType
                        Layout.fillWidth: true
                        Layout.preferredHeight: 30
                        model: content.internalExportTypeModel
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
            }
        }
    }
}
