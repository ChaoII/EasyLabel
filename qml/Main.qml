import QtQuick
import QtQuick.Controls
import HuskarUI.Basic
import EasyLabel

HusWindow {
    id: root
    width: 1300
    height: 850
    visible: true
    title: qsTr("EasyLabel")
    followThemeSwitch: true
    captionBar.color: HusTheme.Primary.colorFillTertiary
    captionBar.themeButtonVisible: true
    captionBar.topButtonVisible: true
    captionBar.height: 30
    captionBar.winIconWidth: 20
    captionBar.winIconHeight: 20
    captionBar.winIconDelegate:
        Image {
        width: 16
        height: 16
        anchors.centerIn: parent
        source: 'qrc:/images/logo.svg'
    }
    captionBar.topCallback: function(checked){
        HusApi.setWindowStaysOnTopHint(root, checked);
    }
    Component.onCompleted: {
        setSpecialEffect(HusWindow.Win_MicaAlt)
        QmlGlobalHelper.initialize(root)
    }
    Item{
        id: content
        anchors.top: root.captionBar.bottom
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        StackView{
            id: stackView
            anchors.fill: parent
            initialItem: ProjetcList{}
        }
    }
}

