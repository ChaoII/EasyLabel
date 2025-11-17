import QtQuick
import HuskarUI.Basic
import EasyLabel
Item {
    id: annotationLayer
    property int drawStatus: CanvasEnums.OptionStatus.Drawing
    property var listModel: AnnotationConfig.currentAnnotationModel
    property int currentLabelID: 0
    // 当前选中的矩形索引
    property int selectedIndex: -1
    property int zOrder: -1
    property int editType: CanvasEnums.EditType.None
    property point dragStartPoint: Qt.point(0, 0)
    property rect startRect: Qt.rect(0, 0, 0, 0)
    property point mousePosition: Qt.point(0,0)
    signal drawFinished()

    Crosshair {
        id: crosshair
        anchors.fill: parent
        visible: drawStatus === CanvasEnums.Drawing
        color: "#ffff00"
        lineWidth: 5
        showCoordinates: true
        showCenterPoint: true
    }

    onMousePositionChanged: {
        crosshair.mousePosition = mousePosition
    }

    HoverHandler{
        id: hoverHandler
        target:annotationLayer
        onPointChanged: function () {
            if(drawStatus === CanvasEnums.Drawing){
                mousePosition=point.position
            }
        }
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
                    listModel.addItem(currentLabelID, mouse.x, mouse.y, 0, 0, zOrder++, false)
                } else {
                    // 选择模式：检查是否点击了矩形
                    selectedIndex = listModel.getSelectedIndex(mouse.x, mouse.y)
                    if(selectedIndex >= 0){
                        listModel.setSingleSelected(selectedIndex)
                        // 如果不处于编辑状态 判断非常重要，因为子组件的鼠标事件会传递，不判断的话，就只会走Move
                        if(editType === CanvasEnums.None){
                            editType = CanvasEnums.Move
                        }
                        dragStartPoint = Qt.point(mouse.x, mouse.y)
                        let selectedRect = listModel.getRect(selectedIndex)
                        startRect = Qt.rect(selectedRect.x, selectedRect.y, selectedRect.width, selectedRect.height)
                    } else {
                        // 没有元素被选中
                        listModel.removeAllSelected()
                        selectedIndex = -1
                        editType=CanvasEnums.None
                    }
                }
            }
        }

        onPositionChanged: function(mouse) {
            if (mouse.buttons & Qt.LeftButton) {
                if (drawStatus === CanvasEnums.Drawing) {
                    // 鼠标按下会拦截HoverHandler,所以在绘制状态持续更新十字线的坐标
                    mousePosition = Qt.point(mouse.x, mouse.y)
                    // 绘制模式：更新矩形大小（保持不变）
                    let last = listModel.rowCount() - 1
                    let realX = mouse.x < startX ? mouse.x : startX
                    let realY = mouse.y < startY ? mouse.y : startY
                    let realWidth = Math.abs(mouse.x - startX)
                    let realHeight = Math.abs(mouse.y - startY)

                    // 绘制时的边界检查
                    realX = Math.max(0, realX)
                    realY = Math.max(0, realY)
                    realWidth = Math.min(realWidth, parent.width - realX)
                    realHeight = Math.min(realHeight, parent.height - realY)
                    realWidth = Math.max(5, realWidth)
                    realHeight = Math.max(5, realHeight)
                    listModel.updateItem(last, currentLabelID, realX, realY, realWidth, realHeight, zOrder, false)

                } else if (selectedIndex >= 0) {
                    var dx = mouse.x - dragStartPoint.x
                    var dy = mouse.y - dragStartPoint.y
                    var newX = startRect.x
                    var newY = startRect.y
                    var newWidth = startRect.width
                    var newHeight = startRect.height

                    // 根据编辑类型计算新的位置和尺寸
                    if(editType===CanvasEnums.Move){
                        newX = startRect.x + dx
                        newY = startRect.y + dy

                        // 移动操作：确保整个矩形不超出边界
                        newX = Math.max(0, Math.min(newX, parent.width - newWidth))
                        newY = Math.max(0, Math.min(newY, parent.height - newHeight))
                    }
                    else{
                        // 调整大小操作：保持对应的锚点固定
                        var minWidth = 5
                        var minHeight = 5

                        if(editType===CanvasEnums.ResizeLeftTopCorner){
                            // 保持右下角固定
                            newX = Math.min(startRect.x + dx, startRect.x + startRect.width - minWidth)
                            newY = Math.min(startRect.y + dy, startRect.y + startRect.height - minHeight)
                            newWidth = startRect.width - (newX - startRect.x)
                            newHeight = startRect.height - (newY - startRect.y)
                        }
                        else if(editType===CanvasEnums.ResizeRightTopCorner){
                            // 保持左下角固定
                            newY = Math.min(startRect.y + dy, startRect.y + startRect.height - minHeight)
                            newWidth = Math.max(minWidth, startRect.width + dx)
                            newHeight = startRect.height - (newY - startRect.y)
                        }
                        else if(editType===CanvasEnums.ResizeRightBottomCorner){
                            // 保持左上角固定
                            newWidth = Math.max(minWidth, startRect.width + dx)
                            newHeight = Math.max(minHeight, startRect.height + dy)
                        }
                        else if(editType===CanvasEnums.ResizeLeftBottomCorner){
                            // 保持右上角固定
                            newX = Math.min(startRect.x + dx, startRect.x + startRect.width - minWidth)
                            newWidth = startRect.width - (newX - startRect.x)
                            newHeight = Math.max(minHeight, startRect.height + dy)
                        }
                        else if(editType===CanvasEnums.ResizeLeftEdge){
                            // 保持右边固定
                            newX = Math.min(startRect.x + dx, startRect.x + startRect.width - minWidth)
                            newWidth = startRect.width - (newX - startRect.x)
                        }
                        else if(editType===CanvasEnums.ResizeTopEdge){
                            // 保持底边固定
                            newY = Math.min(startRect.y + dy, startRect.y + startRect.height - minHeight)
                            newHeight = startRect.height - (newY - startRect.y)
                        }
                        else if(editType===CanvasEnums.ResizeRightEdge){
                            // 保持左边固定
                            newWidth = Math.max(minWidth, startRect.width + dx)
                        }
                        else if(editType===CanvasEnums.ResizeBottomEdge){
                            // 保持顶边固定
                            newHeight = Math.max(minHeight, startRect.height + dy)
                        }

                        // 边界检查：确保矩形不超出画布
                        if(newX < 0){
                            newWidth = newWidth + newX  // 调整宽度
                            newX = 0
                        }

                        if(newY < 0){
                            newHeight = newHeight + newY  // 调整高度
                            newY = 0
                        }

                        if(newX + newWidth > parent.width){
                            newWidth = parent.width - newX
                        }

                        if(newY + newHeight > parent.height){
                            newHeight = parent.height - newY
                        }
                        // 最终确保最小尺寸
                        newWidth = Math.max(minWidth, newWidth)
                        newHeight = Math.max(minHeight, newHeight)
                    }
                    listModel.updateItem(selectedIndex, currentLabelID ,newX, newY,newWidth,newHeight, zOrder, true)
                }
            }
        }

        onReleased: function(mouse) {
            if (mouse.button === Qt.LeftButton) {
                if (drawStatus === CanvasEnums.Drawing) {
                    annotationLayer.drawFinished()
                }
                editType = CanvasEnums.None
            }
        }
    }
    // 显示所有标注框
    Repeater {
        model: listModel
        delegate: HusRectangle {
            id: obj
            property color currentLabelColor: AnnotationConfig.currentLabelColor
            property string currentLabel: AnnotationConfig.currentLabel
            property bool showHandlers: model.selected
            x: model.boxX
            y: model.boxY
            width: model.boxWidth
            height: model.boxHeight
            border.color: currentLabelColor
            border.width: AnnotationConfig.currentLineWidth
            border.style: model.selected ? Qt.DashDotLine : Qt.SolidLine
            color: Qt.rgba(border.color.r, border.color.g, border.color.b, AnnotationConfig.currentFillOpacity)
            Connections{
                target:AnnotationConfig.labelListModel
                function onDataChanged(){
                    currentLabelColor = AnnotationConfig.currentLabelColor
                    currentLabel = AnnotationConfig.currentLabel
                }
            }

            // 显示标签
            HusRectangle{
                x: 0
                y: -text.height
                width: text.width
                height: text.height
                color: obj.border.color
                HusText{
                    id: text
                    color: QmlGlobalHelper.revertColor(obj.border.color)
                    text: currentLabel
                }
            }

            MouseArea{
                anchors.fill: parent
                anchors.margins: -Math.max(AnnotationConfig.currentCornerRadius, AnnotationConfig.currentEdgeHeight)
                hoverEnabled: true
                propagateComposedEvents: true
                onEntered: {
                    if(drawStatus === CanvasEnums.OptionStatus.Select){
                        cursorShape = Qt.SizeAllCursor
                    }
                }
                onExited: {
                    if(drawStatus === CanvasEnums.OptionStatus.Select){
                        cursorShape = Qt.ArrowCursor
                    }
                }
                onPressed:function(mouse) {
                    mouse.accepted = false
                }
            }

            // 角控制点
            Repeater {
                property int handlerWidth: AnnotationConfig.currentCornerRadius
                property int handlerHeight: AnnotationConfig.currentCornerRadius
                model: obj.showHandlers ? getCornerHandlerModel(obj.width, obj.height, handlerWidth, handlerHeight) : []
                delegate: Rectangle {
                    id: cornerHandler
                    x: modelData.cornerHandlerX
                    y: modelData.cornerHandlerY
                    width: modelData.cornerHandlerWidth
                    height: modelData.cornerHandlerHeight
                    radius: modelData.cornerHandlerWidth/2
                    color: currentLabelColor
                    // 根据角点索引确定调整方向 0:左上 1:右上 2:右下 3:左下
                    property int resizeType: index
                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        propagateComposedEvents: true  // 允许事件传播
                        cursorShape:{
                            switch(parent.resizeType) {
                            case 0: return Qt.SizeFDiagCursor
                            case 1: return Qt.SizeBDiagCursor
                            case 2: return Qt.SizeFDiagCursor
                            case 3: return Qt.SizeBDiagCursor
                            default: return Qt.ArrowCursor
                            }
                        }
                        onEntered: {
                            switch(parent.resizeType) {
                            case 0: {
                                annotationLayer.editType = CanvasEnums.EditType.ResizeLeftTopCorner
                                break
                            }
                            case 1: {
                                annotationLayer.editType = CanvasEnums.EditType.ResizeRightTopCorner
                                break
                            }
                            case 2: {
                                annotationLayer.editType = CanvasEnums.EditType.ResizeRightBottomCorner
                                break
                            }
                            case 3: {
                                annotationLayer.editType = CanvasEnums.EditType.ResizeLeftBottomCorner
                                break
                            }
                            default: {
                                annotationLayer.editType = CanvasEnums.EditType.None
                                break
                            }
                            }
                        }
                        onExited: {
                            editType = CanvasEnums.EditType.None
                        }

                        onPressed: function(mouse) {
                            // 允许事件继续传播到上层
                            mouse.accepted = false
                        }
                    }
                }
            }

            // 边控制点
            Repeater {
                property int handlerWidth: AnnotationConfig.currentEdgeWidth
                property int handlerHeight: AnnotationConfig.currentEdgeHeight
                model: obj.showHandlers ? getEdgeHandlerModel(obj.width, obj.height, handlerWidth, handlerHeight) : []
                delegate: Rectangle {
                    id: edgeHandler
                    x: modelData.edgeHandlerX
                    y: modelData.edgeHandlerY
                    width: modelData.edgeHandlerWidth
                    height: modelData.edgeHandlerHeight
                    radius: 2
                    color: "red"
                    property int resizeType: index // 0:左 1:上 2:右 3:下

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape:{
                            switch(parent.resizeType) {
                            case 0:return Qt.SizeHorCursor
                            case 1: return Qt.SizeVerCursor
                            case 2: return Qt.SizeHorCursor
                            case 3: return Qt.SizeVerCursor
                            default: return Qt.ArrowCursor
                            }
                        }
                        onEntered: function(mouse){
                            switch(parent.resizeType) {
                            case 0: {
                                annotationLayer.editType = CanvasEnums.EditType.ResizeLeftEdge
                                break
                            }
                            case 1: {
                                annotationLayer.editType = CanvasEnums.EditType.ResizeTopEdge
                                break
                            }
                            case 2: {
                                annotationLayer.editType = CanvasEnums.EditType.ResizeRightEdge
                                break
                            }
                            case 3: {
                                annotationLayer.editType = CanvasEnums.EditType.ResizeBottomEdge
                                break
                            }
                            default: {
                                annotationLayer.editType = CanvasEnums.EditType.None
                                break
                            }
                            }
                        }
                        onExited: {
                            annotationLayer.editType = CanvasEnums.EditType.None
                        }
                        onPressed: function(mouse) {
                            // 允许事件继续传播到上层
                            mouse.accepted = false
                        }
                    }

                }
            }
        }
    }

    function getCornerHandlerModel(labelWidth, labelHeight, handlerWidth, handlerHeight) {
        return [
                    // 左上
                    {
                        "cornerHandlerX": 0 - handlerWidth/2,
                        "cornerHandlerY": 0 - handlerHeight/2,
                        "cornerHandlerWidth":handlerWidth,
                        "cornerHandlerHeight":handlerHeight
                    },
                    // 右上
                    {
                        "cornerHandlerX": labelWidth - handlerWidth/2,
                        "cornerHandlerY": 0 - handlerHeight/2,
                        "cornerHandlerWidth":handlerWidth,
                        "cornerHandlerHeight":handlerHeight
                    },
                    // 右下
                    {
                        "cornerHandlerX": labelWidth - handlerWidth/2,
                        "cornerHandlerY": labelHeight - handlerHeight/2,
                        "cornerHandlerWidth":handlerWidth,
                        "cornerHandlerHeight":handlerHeight
                    },
                    {
                        "cornerHandlerX": 0 - handlerWidth/2,
                        "cornerHandlerY": labelHeight - handlerHeight/2,
                        "cornerHandlerWidth":handlerWidth,
                        "cornerHandlerHeight":handlerHeight}
                ]
    }

    function getEdgeHandlerModel(labelWidth, labelHeight, handlerWidth, handlerHeight) {
        return [
                    // 左
                    {
                        "edgeHandlerX": 0 - handlerHeight/2,
                        "edgeHandlerY": labelHeight/2 - handlerWidth/2,
                        "edgeHandlerWidth": handlerHeight,
                        "edgeHandlerHeight": handlerWidth
                    },
                    // 上
                    {
                        "edgeHandlerX": labelWidth/2 - handlerWidth/2,
                        "edgeHandlerY": 0 - handlerHeight/2,
                        "edgeHandlerWidth": handlerWidth,
                        "edgeHandlerHeight": handlerHeight
                    },
                    // 右
                    {
                        "edgeHandlerX": labelWidth - handlerHeight/2,
                        "edgeHandlerY": labelHeight/2 - handlerWidth/2,
                        "edgeHandlerWidth": handlerHeight,
                        "edgeHandlerHeight": handlerWidth
                    },
                    // 下
                    {
                        "edgeHandlerX": labelWidth/2 - handlerWidth/2,
                        "edgeHandlerY": labelHeight - handlerHeight/2,
                        "edgeHandlerWidth": handlerWidth,
                        "edgeHandlerHeight": handlerHeight
                    }
                ]
    }
}
