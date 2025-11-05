import QtQuick
import HuskarUI.Basic
Item {
    id: annotationLayer
    property int drawStatus: CanvasEnums.OptionStatus.Drawing
    property ListModel listModel: ListModel{}
    property int selectedIndex: -1  // 当前选中的矩形索引
    property int editMode: CanvasEnums.EditStatus.None
    property int resizeType: CanvasEnums.ResizeType.None
    signal drawFinished()

    function getSlectedIndex(mouseX, mouseY){
        let _selectIndex = -1
        for(let i=0;i<listModel.count;i++){
            let rect = listModel.get(i)
            if(mouseX > rect.x && mouseY > rect.y && mouseX < rect.x + rect.w && mouseY < rect.y + rect.h){
                // 有元素被选中
                _selectIndex = i
            }
        }
        return _selectIndex
    }

    function removeAllSelected(){
        for(let i=0;i<listModel.count;i++){
            listModel.setProperty(i, "selected", false)
        }
    }

    function setOneSelected(index){
        removeAllSelected()
        listModel.setProperty(index, "selected", true)
    }

    // 鼠标绘制矩形标注
    MouseArea {
        id: drawArea
        anchors.fill: parent
        property real startX
        property real startY
        hoverEnabled: true
        onPressed: function(mouse) {
            if(mouse.button === Qt.LeftButton) {
                if(drawStatus === CanvasEnums.Drawing) {
                    // 绘制模式：开始绘制新矩形
                    startX = mouse.x
                    startY = mouse.y
                    listModel.append( { "x": mouse.x, "y": mouse.y, "w": 0, "h": 0,"selected": false})
                    selectedIndex = listModel.count - 1
                    setOneSelected(selectedIndex)
                }else{
                    selectedIndex = getSlectedIndex(mouse.x, mouse.y)
                    if(selectedIndex >= 0){
                        setOneSelected(selectedIndex)
                    }else{
                        // 没有元素被选中
                        removeAllSelected()
                    }
                }
            }
        }

        onPositionChanged: function(mouse) {
            if (mouse.buttons & Qt.LeftButton && drawStatus === CanvasEnums.Drawing) {
                // 绘制模式：更新矩形大小
                let last = listModel.count - 1
                let realX = mouse.x < startX ? mouse.x : startX
                let realY = mouse.y < startY ? mouse.y : startY
                listModel.set(last, {
                                  "x": realX,
                                  "y": realY,
                                  "w": Math.abs(mouse.x - startX),
                                  "h": Math.abs(mouse.y - startY),
                                  "selected": true
                              })
            }
        }
        onReleased: function(mouse) {
            if (mouse.button === Qt.LeftButton && drawStatus === CanvasEnums.Drawing) {
                console.log("finished a detection label")
                annotationLayer.drawFinished()
            }
        }
    }

    // 显示所有标注框
    Repeater {
        model: listModel
        delegate: HusRectangle {
            id: obj
            x: model.x
            y: model.y
            width: model.w
            height: model.h
            border.color: model.selected ? "blue" : "red"  // 选中时变蓝色
            border.width: model.selected ? 3 : 2  // 选中时边框加粗
            border.style: model.selected ? Qt.DashLine : Qt.SolidLine
            color: "#00FF0000"
            property bool showHandlers: model.selected
            property point pressPoint: Qt.point(0, 0)  // 鼠标按下的画布坐标
            property point rectStartPos: Qt.point(0, 0)  // 矩形初始位置
            MouseArea{
                anchors.fill: parent
                // 关键：只有选中的矩形才启用 MouseArea
                enabled: model.selected || containsMouse
                cursorShape: model.selected ? Qt.SizeAllCursor : Qt.ArrowCursor
                onPressed:function(mouse) {
                    // 记录鼠标在画布中的绝对坐标
                    pressPoint = Qt.point(mouse.x + obj.x, mouse.y + obj.y)
                    // 记录矩形初始位置
                    rectStartPos = Qt.point(model.x, model.y)
                }
                onPositionChanged:function(mouse) {
                    let currentCanvasX = mouse.x + obj.x
                    let currentCanvasY = mouse.y + obj.y
                    // 计算移动距离（基于画布坐标）
                    let deltaX = currentCanvasX - pressPoint.x
                    let deltaY = currentCanvasY - pressPoint.y
                    // 计算新位置
                    let newX = rectStartPos.x + deltaX
                    let newY = rectStartPos.y + deltaY
                    console.log("移动距离:", deltaX, deltaY, "新位置:", newX, newY)
                    // 边界检查
                    newX = Math.max(0, Math.min(newX, annotationLayer.width - model.w))
                    newY = Math.max(0, Math.min(newY, annotationLayer.height - model.h))

                    // 更新模型数据
                    listModel.setProperty(index, "x", newX)
                    listModel.setProperty(index, "y", newY)
                }
            }
            // 角控制点 - 只在选中时显示
            Repeater {
                property int handlerWidth: 10
                property int handlerHeight: 10
                model: obj.showHandlers ? getCornerHandlerModel(obj.width, obj.height, handlerWidth, handlerHeight) : []
                delegate: Rectangle {
                    x: modelData.cornerHandlerX
                    y: modelData.cornerHandlerY
                    width: modelData.cornerHandlerWidth
                    height: modelData.cornerHandlerHeight
                    radius: modelData.cornerHandlerWidth/2
                    color: "red"




                }
            }

            // 边控制点 - 只在选中时显示
            Repeater {
                property int handlerWidth: 12
                property int handlerHeight: 6
                model: obj.showHandlers ? getEdgeHandlerModel(obj.width, obj.height, handlerWidth, handlerHeight) : []
                delegate: Rectangle {
                    x: modelData.edgeHandlerX
                    y: modelData.edgeHandlerY
                    width: modelData.edgeHandlerWidth
                    height: modelData.edgeHandlerHeight
                    radius: 2
                    color: "red"
                }
            }
        }
    }

    function getCornerHandlerModel(labelWidth, labelHeight, handlerWidth, handlerHeight) {
        return [
                    {
                        "cornerHandlerX": 0 - handlerWidth/2,
                        "cornerHandlerY": 0 - handlerHeight/2,
                        "cornerHandlerWidth":handlerWidth,
                        "cornerHandlerHeight":handlerHeight
                    },
                    {
                        "cornerHandlerX": labelWidth - handlerWidth/2,
                        "cornerHandlerY": 0 - handlerHeight/2,
                        "cornerHandlerWidth":handlerWidth,
                        "cornerHandlerHeight":handlerHeight},
                    {
                        "cornerHandlerX": labelWidth - handlerWidth/2,
                        "cornerHandlerY": labelHeight - handlerHeight/2,
                        "cornerHandlerWidth":handlerWidth,
                        "cornerHandlerHeight":handlerHeight},
                    {
                        "cornerHandlerX": 0 - handlerWidth/2,
                        "cornerHandlerY": labelHeight - handlerHeight/2,
                        "cornerHandlerWidth":handlerWidth,
                        "cornerHandlerHeight":handlerHeight}
                ]
    }

    function getEdgeHandlerModel(labelWidth, labelHeight, handlerWidth, handlerHeight) {
        return [
                    {
                        "edgeHandlerX": labelWidth/2 - handlerWidth/2,
                        "edgeHandlerY": 0 - handlerHeight/2,
                        "edgeHandlerWidth": handlerWidth,
                        "edgeHandlerHeight": handlerHeight
                    },
                    {
                        "edgeHandlerX": labelWidth/2 - handlerWidth/2,
                        "edgeHandlerY": labelHeight - handlerHeight/2,
                        "edgeHandlerWidth": handlerWidth,
                        "edgeHandlerHeight": handlerHeight
                    },
                    {
                        "edgeHandlerX": 0 - handlerHeight/2,
                        "edgeHandlerY": labelHeight/2 - handlerWidth/2,
                        "edgeHandlerWidth": handlerHeight,
                        "edgeHandlerHeight": handlerWidth
                    },
                    {
                        "edgeHandlerX": labelWidth - handlerHeight/2,
                        "edgeHandlerY": labelHeight/2 - handlerWidth/2,
                        "edgeHandlerWidth": handlerHeight,
                        "edgeHandlerHeight": handlerWidth
                    }
                ]
    }
}
