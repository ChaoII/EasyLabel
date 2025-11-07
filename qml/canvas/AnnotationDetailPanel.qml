import QtQuick
import HuskarUI.Basic

Item{
    id: splitRight

    HusCard{
        id: card
        anchors.fill: parent
        border.color:"transparent"
        bodyDelegate: bodyComponent
    }

    Component{
        id:bodyComponent
        HusMenu {
            id: _menu
            showEdge:true
            width: card.width
            height: card.height
            initModel: [
                {key:"A", label: qsTr('一心二意'), value: 1 , menuChildren: [{contentDelegate: aaa}] },
                {key:"B", label: qsTr('煮都还实'), value: 2 , menuChildren: [{contentDelegate: aaa}] },
                {key:"C", label: qsTr('浓度高强'), value: 3 , menuChildren: [{contentDelegate: aaa}] }
            ]
            onClickMenu: function(deep, key, keyPath, data) {

            }
            Component.onCompleted: {
            }
        }
    }

    Component{
        id:aaa
        HusRectangle{
            implicitHeight: 200
            width: parent.width
            color:"lightgreen"
            HusSlider {
                id:control
                width: parent.width -30
                height: 30
                min: 0
                max: 10
                stepSize: 1
                snapMode: HusSlider.SnapAlways
                handleDelegate: Rectangle {
                    id: __handleItem
                    x:  slider.leftPadding + visualPosition * (slider.availableWidth - width)
                    y:  slider.topPadding + (slider.availableHeight - height) * 0.5 -3
                    implicitWidth: active ? 18 : 14
                    implicitHeight: active ? 18 : 14
                    color: "transparent"

                    HusRectangle{
                        y : tt.y+9
                        anchors.horizontalCenter:  parent.horizontalCenter
                        width: tt.width/Math.sqrt(2)
                        height: tt.width/Math.sqrt(2)
                        color: "blue"
                        rotation: 45
                        bottomLeftRadius:0
                        bottomRightRadius: 2
                        topLeftRadius: 0
                        topRightRadius: 0
                        transformOrigin: Item.Center
                    }

                    HusRectangle{
                        id:tt
                        anchors.centerIn: parent
                        width:14
                        height:14
                        bottomLeftRadius:2
                        bottomRightRadius: 2
                        topLeftRadius: 2
                        topRightRadius: 2
                        color:"blue"
                    }




                }
                HusCopyableText {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.right
                    anchors.leftMargin: 10
                    text: parent.currentValue;
                }

            }
        }

    }

}
