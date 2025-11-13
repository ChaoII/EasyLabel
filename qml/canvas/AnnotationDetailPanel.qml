import QtQuick
import QtQuick.Layouts
import HuskarUI.Basic
import Qt.labs.folderlistmodel
import EasyLabel

Item{
    id: splitRight
    property int annotationType: GlobalEnum.AnnotationType.Detection
    HusCard{
        id: card
        anchors.fill: parent
        border.color:"transparent"
        titleDelegate: Item{
            width: parent.width
            height: 40
            property color colorBase: GlobalEnum.annotationTagColorMap[annotationType]

            RowLayout{
                anchors.fill: parent
                anchors.margins: 10
                HusIconText{
                    id: logo
                    font.bold: true
                    colorIcon: getColor(colorBase, 5)
                    iconSize: 16
                    iconSource: HusIcon.BorderOutlined
                }
                HusText{
                    Layout.fillWidth: true
                    font.bold: true
                    font.pixelSize: 16
                    color: getColor(colorBase, 5)
                    text: GlobalEnum.annotationTypeStringMap[annotationType]
                }
            }
        }
        bodyDelegate: bodyComponent
    }


    function getColor(colorBase, index){
        return HusThemeFunctions.genColor(colorBase,!HusTheme.isDark,HusTheme.Primary.colorBgBase)[index]
    }

    Component{
        id:bodyComponent
        HusCollapse {
            id: annotaionDetail
            accordion: true
            radiusBg.topLeft: 0
            radiusBg.topRight: 0
            defaultActiveKey: ["A"]
            initModel: [
                {key:"A", title: qsTr('样式'), value: 1 , contentDelegate: aaa },
                {key:"B", title: qsTr('标签'), value: 2 , contentDelegate: bbb },
                {key:"C", title: qsTr('标注列表'), value: 3 , contentDelegate: ccc },
                {key:"D", title: qsTr('文件列表'), value: 4 , contentDelegate: ddd }
            ]
            contentDelegate:Item{
                height: splitRight.height - 40 * annotaionDetail.count - 37
                Loader{
                    anchors.fill: parent
                    anchors.margins: 10
                    sourceComponent: model.contentDelegate
                }
            }
            Component.onCompleted: {
                console.log( annotaionDetail.get(2).title)
                console.log( annotaionDetail.height)
            }
        }
    }


    Component{
        id:aaa
        AnnotationStyleDetail{
        }
    }

    Component{
        id:bbb
        AnnotationLabelDetail{
            // dataModel: AnnotationConfig.loadLabelFile()
        }
    }

    Component{
        id:ccc
        AnnotationListDetail{
        }
    }

    Component{
        id:ddd
        AnnotationFileListDetail{
        }
    }
}
