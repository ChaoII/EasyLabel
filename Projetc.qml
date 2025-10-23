import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import HuskarUI.Basic

Item {
    ColumnLayout{
        anchors.margins: 10
        anchors.fill: parent
        RowLayout{
            HusButton{
                id: btnCreateProject
                type: HusButton.Type_Primary
                text: "创建项目"
                onClicked: {
                    popup.open()
                }
            }
            Item{
                Layout.fillWidth: true
            }
            HusRadioBlock {
                initCheckedIndex: 0
                model: [
                    { label: 'Apple', value: 'Apple' },
                    { label: 'Pear', value: 'Pear' },
                    { label: 'Orange', value: 'Orange' },
                ]
            }
        }
        ScrollView   {
            id: flick
            Layout.fillWidth: true
            Layout.fillHeight: true
            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
            ScrollBar.vertical: HusScrollBar { policy:ScrollBar.AsNeeded}
            Flow{
                width: flick.width
                spacing: 10
                Repeater {
                    model: 100
                    delegate: HusCard {
                        width: 312
                        height: 200
                        HusText {
                            text: "Item " + index
                            anchors.centerIn: parent
                        }
                    }
                }
            }
        }
        HusPagination{
            Layout.preferredHeight: 30
            currentPageIndex: 0
            total: 50
            pageSizeModel: [
                { label: qsTr('10条每页'), value: 10 },
                { label: qsTr('20条每页'), value: 20 },
                { label: qsTr('30条每页'), value: 30 },
                { label: qsTr('40条每页'), value: 40 }
            ]
        }
    }


    NewProjectPopup{
        id:popup
        x: (parent.width - width) * 0.5
        y: (parent.height - height) * 0.5
        width: 800
        height: 600

    }

}




