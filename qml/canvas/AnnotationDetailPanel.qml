import QtQuick
import QtQuick.Layouts
import HuskarUI.Basic
import EasyLabel

Item{
    id: splitRight
    required property AnnotationConfig annotationConfig
    readonly property color annotationTypeColor: QmlGlobalHelper.getColor(annotationConfig.getAnnotationTypeColor(),5)
    readonly property string annotationTypeName: annotationConfig.getAnnotationTypeName()
    readonly property int annotationTypeIconSource: GlobalEnum.annotationIconTextMap[annotationConfig.annotationType]

    HusCard{
        id: card
        anchors.fill: parent
        border.color:"transparent"
        titleDelegate: Item{
            width: parent.width
            height: 40
            RowLayout{
                anchors.fill: parent
                anchors.margins: 10
                HusIconText{
                    id: logo
                    font.bold: true
                    colorIcon: annotationTypeColor
                    iconSize: 16
                    iconSource: annotationTypeIconSource
                }
                HusText{
                    Layout.fillWidth: true
                    font.bold: true
                    font.pixelSize: 16
                    color: annotationTypeColor
                    text: annotationTypeName
                }
            }
        }
        bodyDelegate: bodyComponent
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

            }
        }
    }


    Component{
        id:aaa
        AnnotationStyleDetail{
            annotationConfig:splitRight.annotationConfig
        }
    }

    Component{
        id:bbb
        AnnotationLabelDetail{
            annotationConfig:splitRight.annotationConfig
        }
    }

    Component{
        id:ccc
        AnnotationListDetail{
            annotationConfig:splitRight.annotationConfig

        }
    }

    Component{
        id:ddd
        AnnotationFileListDetail{
            annotationConfig:splitRight.annotationConfig

        }
    }
}
