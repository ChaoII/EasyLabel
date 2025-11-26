
import QtQuick
import HuskarUI.Basic
import EasyLabel
Item {
    id: detectionLabelLayer
    property AnnotationConfig annotationConfig
    property int drawStatus: CanvasEnums.OptionStatus.Drawing
    property var listModel: annotationConfig.currentAnnotationModel
    property int currentLabelID: annotationConfig.currentLabelIndex
    property color currentLabelColor: annotationConfig.currentLabelColor
    property string currentLabel: annotationConfig.currentLabel
    property int selectedIndex: -1
    property real scaleFactor: 1.0
    property int zOrder: -1
    property int editType: CanvasEnums.EditType.None
    property point dragStartPoint: Qt.point(0, 0)
    property rect startRect: Qt.rect(0, 0, 0, 0)
    property point mousePosition: Qt.point(0,0)
    signal drawFinished()

    Crosshair {
        id: crosshair
        anchors.fill: parent
        visible: detectionLabelLayer.drawStatus === CanvasEnums.Drawing
        crossColor: detectionLabelLayer.currentLabelColor
        centerPointerSize: detectionLabelLayer.annotationConfig.centerPointerSize
        lineWidth: detectionLabelLayer.annotationConfig.currentLineWidth
        scaleFactor: detectionLabelLayer.scaleFactor
        showCoordinates: true
        showCenterPoint: true
    }

    onMousePositionChanged: {
        crosshair.mousePosition = mousePosition
    }

    HoverHandler{
        id: hoverHandler
        target:detectionLabelLayer
        onPointChanged: function () {
            if(detectionLabelLayer.drawStatus === CanvasEnums.Drawing){
                detectionLabelLayer.mousePosition = point.position
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
                if(detectionLabelLayer.drawStatus === CanvasEnums.Drawing) {
                    // 绘制模式：开始绘制新矩形
                    if(detectionLabelLayer.currentLabelID===-1){
                        QmlGlobalHelper.message.error("请选择一个标签")
                        return
                    }
                    startX = mouse.x
                    startY = mouse.y
                    detectionLabelLayer.listModel.addItem(detectionLabelLayer.currentLabelID, mouse.x, mouse.y, 0, 0, detectionLabelLayer.zOrder++, false)
                } else {
                    // 选择模式：检查是否点击了矩形
                    selectedIndex = detectionLabelLayer.listModel.getSelectedIndex(mouse.x, mouse.y)
                    if(detectionLabelLayer.selectedIndex >= 0){
                        detectionLabelLayer.listModel.setSingleSelected(detectionLabelLayer.selectedIndex)
                        // 如果不处于编辑状态 判断非常重要，因为子组件的鼠标事件会传递，不判断的话，就只会走Move
                        if(detectionLabelLayer.editType === CanvasEnums.None){
                            detectionLabelLayer.editType = CanvasEnums.Move
                        }
                        detectionLabelLayer.dragStartPoint = Qt.point(mouse.x, mouse.y)
                        let selectedRect = detectionLabelLayer.listModel.getRect(detectionLabelLayer.selectedIndex)
                        detectionLabelLayer.startRect = Qt.rect(selectedRect.x, selectedRect.y, selectedRect.width, selectedRect.height)
                    } else {
                        // 没有元素被选中
                        detectionLabelLayer.listModel.removeAllSelected()
                        detectionLabelLayer.selectedIndex = -1
                        detectionLabelLayer.editType=CanvasEnums.None
                    }
                }
            }
        }
        onPositionChanged: function(mouse) {
            if (mouse.buttons & Qt.LeftButton) {
                if (detectionLabelLayer.drawStatus === CanvasEnums.Drawing) {
                    if(detectionLabelLayer.currentLabelID===-1) return
                    // 鼠标按下会拦截HoverHandler,所以在绘制状态持续更新十字线的坐标
                    detectionLabelLayer.mousePosition = Qt.point(mouse.x, mouse.y)
                    // 绘制模式：更新矩形大小（保持不变）
                    let last = detectionLabelLayer.listModel.rowCount() - 1
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
                    detectionLabelLayer.listModel.updateItem(last, detectionLabelLayer.currentLabelID, realX, realY, realWidth, realHeight, detectionLabelLayer.zOrder, false)
                } else if (detectionLabelLayer.selectedIndex >= 0) {
                    var dx = mouse.x - detectionLabelLayer.dragStartPoint.x
                    var dy = mouse.y - detectionLabelLayer.dragStartPoint.y
                    var newX = detectionLabelLayer.startRect.x
                    var newY = detectionLabelLayer.startRect.y
                    var newWidth = detectionLabelLayer.startRect.width
                    var newHeight = detectionLabelLayer.startRect.height

                    // 根据编辑类型计算新的位置和尺寸
                    if(detectionLabelLayer.editType===CanvasEnums.Move){
                        newX = detectionLabelLayer.startRect.x + dx
                        newY = detectionLabelLayer.startRect.y + dy

                        // 移动操作：确保整个矩形不超出边界
                        newX = Math.max(0, Math.min(newX, parent.width - newWidth))
                        newY = Math.max(0, Math.min(newY, parent.height - newHeight))
                    }
                    else{
                        // 调整大小操作：保持对应的锚点固定
                        var minWidth = 5
                        var minHeight = 5

                        if(detectionLabelLayer.editType===CanvasEnums.ResizeLeftTopCorner){
                            // 保持右下角固定
                            newX = Math.min(detectionLabelLayer.startRect.x + dx, detectionLabelLayer.startRect.x + detectionLabelLayer.startRect.width - minWidth)
                            newY = Math.min(detectionLabelLayer.startRect.y + dy, detectionLabelLayer.startRect.y + detectionLabelLayer.startRect.height - minHeight)
                            newWidth = detectionLabelLayer.startRect.width - (newX - detectionLabelLayer.startRect.x)
                            newHeight = detectionLabelLayer.startRect.height - (newY - detectionLabelLayer.startRect.y)
                        }
                        else if(detectionLabelLayer.editType===CanvasEnums.ResizeRightTopCorner){
                            // 保持左下角固定
                            newY = Math.min(detectionLabelLayer.startRect.y + dy, detectionLabelLayer.startRect.y + detectionLabelLayer.startRect.height - minHeight)
                            newWidth = Math.max(minWidth, detectionLabelLayer.startRect.width + dx)
                            newHeight = detectionLabelLayer.startRect.height - (newY - detectionLabelLayer.startRect.y)
                        }
                        else if(detectionLabelLayer.editType===CanvasEnums.ResizeRightBottomCorner){
                            // 保持左上角固定
                            newWidth = Math.max(minWidth, detectionLabelLayer.startRect.width + dx)
                            newHeight = Math.max(minHeight, detectionLabelLayer.startRect.height + dy)
                        }
                        else if(detectionLabelLayer.editType===CanvasEnums.ResizeLeftBottomCorner){
                            // 保持右上角固定
                            newX = Math.min(detectionLabelLayer.startRect.x + dx, detectionLabelLayer.startRect.x + detectionLabelLayer.startRect.width - minWidth)
                            newWidth = detectionLabelLayer.startRect.width - (newX - detectionLabelLayer.startRect.x)
                            newHeight = Math.max(minHeight, detectionLabelLayer.startRect.height + dy)
                        }
                        else if(detectionLabelLayer.editType===CanvasEnums.ResizeLeftEdge){
                            // 保持右边固定
                            newX = Math.min(detectionLabelLayer.startRect.x + dx, detectionLabelLayer.startRect.x + detectionLabelLayer.startRect.width - minWidth)
                            newWidth = detectionLabelLayer.startRect.width - (newX - detectionLabelLayer.startRect.x)
                        }
                        else if(detectionLabelLayer.editType===CanvasEnums.ResizeTopEdge){
                            // 保持底边固定
                            newY = Math.min(detectionLabelLayer.startRect.y + dy, detectionLabelLayer.startRect.y + detectionLabelLayer.startRect.height - minHeight)
                            newHeight = detectionLabelLayer.startRect.height - (newY - detectionLabelLayer.startRect.y)
                        }
                        else if(detectionLabelLayer.editType===CanvasEnums.ResizeRightEdge){
                            // 保持左边固定
                            newWidth = Math.max(minWidth, detectionLabelLayer.startRect.width + dx)
                        }
                        else if(detectionLabelLayer.editType===CanvasEnums.ResizeBottomEdge){
                            // 保持顶边固定
                            newHeight = Math.max(minHeight, detectionLabelLayer.startRect.height + dy)
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
                    let annotationID = detectionLabelLayer.listModel.getLabelID(detectionLabelLayer.selectedIndex)
                    detectionLabelLayer.listModel.updateItem(detectionLabelLayer.selectedIndex, annotationID ,newX, newY,newWidth,newHeight, detectionLabelLayer.zOrder, true)
                }
            }
        }
        onReleased: function(mouse) {
            if (mouse.button === Qt.LeftButton) {
                if (detectionLabelLayer.drawStatus === CanvasEnums.Drawing) {
                    detectionLabelLayer.drawFinished()
                }
                detectionLabelLayer.editType = CanvasEnums.None
            }
        }
    }
    // 显示所有标注框
    Repeater {
        model: detectionLabelLayer.listModel
        delegate: HusRectangle {
            id: obj
            required property int labelID
            required property int boxX
            required property int boxY
            required property int boxWidth
            required property int boxHeight
            required property bool selected
            readonly property bool showHandlers: selected
            property color annotationColor: detectionLabelLayer.annotationConfig.labelListModel.getLabelColor(labelID)
            property string annotationLabel: detectionLabelLayer.annotationConfig.labelListModel.getLabel(labelID)

            x: boxX
            y: boxY
            width: boxWidth
            height: boxHeight
            border.color: annotationColor
            border.width: detectionLabelLayer.annotationConfig.currentLineWidth/detectionLabelLayer.scaleFactor
            border.style: selected ? Qt.DashDotLine: Qt.SolidLine
            color: Qt.rgba(annotationColor.r, annotationColor.g, annotationColor.b, detectionLabelLayer.annotationConfig.currentFillOpacity)

            Connections{
                target: detectionLabelLayer.annotationConfig.labelListModel
                function onDataChanged(){
                    annotationColor = detectionLabelLayer.annotationConfig.labelListModel.getLabelColor(obj.labelID)
                    annotationLabel = detectionLabelLayer.annotationConfig.labelListModel.getLabel(obj.labelID)
                }
            }

            // 显示标签
            HusRectangle{
                x: 0
                y: -text.height
                width: text.width
                height: text.height
                visible: detectionLabelLayer.annotationConfig.showLabel
                color: obj.annotationColor
                HusText{
                    id: text
                    font.pixelSize: detectionLabelLayer.annotationConfig.fontPointSize / detectionLabelLayer.scaleFactor
                    color: QmlGlobalHelper.revertColor(obj.annotationColor)
                    text: obj.annotationLabel
                }
            }

            MouseArea{
                anchors.fill: parent
                anchors.margins: -Math.max(detectionLabelLayer.annotationConfig.currentCornerRadius, detectionLabelLayer.annotationConfig.currentEdgeHeight)
                hoverEnabled: true
                propagateComposedEvents: true
                onEntered: {
                    if(detectionLabelLayer.drawStatus === CanvasEnums.OptionStatus.Select){
                        cursorShape = Qt.SizeAllCursor
                    }
                }
                onExited: {
                    if(detectionLabelLayer.drawStatus === CanvasEnums.OptionStatus.Select){
                        cursorShape = Qt.ArrowCursor
                    }
                }
                onPressed:function(mouse) {
                    mouse.accepted = false
                }
            }

            // 角控制点
            Repeater {
                property int handlerWidth: detectionLabelLayer.annotationConfig.currentCornerRadius/detectionLabelLayer.scaleFactor
                property int handlerHeight: detectionLabelLayer.annotationConfig.currentCornerRadius/detectionLabelLayer.scaleFactor



                model: obj.showHandlers ? detectionLabelLayer.getCornerHandlerModel(obj.width, obj.height, handlerWidth, handlerHeight) : []
                delegate: Rectangle {
                    id: cornerHandler


                    required property int index
                    required property int cornerHandlerX
                    required property int cornerHandlerY
                    required property int cornerHandlerWidth
                    required property int cornerHandlerHeight

                    x: cornerHandlerX
                    y: cornerHandlerY
                    width: cornerHandlerWidth
                    height: cornerHandlerHeight
                    radius: cornerHandlerWidth/2
                    color: obj.annotationColor
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
                                detectionLabelLayer.editType = CanvasEnums.EditType.ResizeLeftTopCorner
                                break
                            }
                            case 1: {
                                detectionLabelLayer.editType = CanvasEnums.EditType.ResizeRightTopCorner
                                break
                            }
                            case 2: {
                                detectionLabelLayer.editType = CanvasEnums.EditType.ResizeRightBottomCorner
                                break
                            }
                            case 3: {
                                detectionLabelLayer.editType = CanvasEnums.EditType.ResizeLeftBottomCorner
                                break
                            }
                            default: {
                                detectionLabelLayer.editType = CanvasEnums.EditType.None
                                break
                            }
                            }
                        }
                        onExited: {
                            detectionLabelLayer.editType = CanvasEnums.EditType.None
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
                property int handlerWidth: detectionLabelLayer.annotationConfig.currentEdgeWidth/detectionLabelLayer.scaleFactor
                property int handlerHeight: detectionLabelLayer.annotationConfig.currentEdgeHeight/detectionLabelLayer.scaleFactor
                model: obj.showHandlers ? detectionLabelLayer.getEdgeHandlerModel(obj.width, obj.height, handlerWidth, handlerHeight) : []
                delegate: Rectangle {
                    id: edgeHandler
                    required property int index
                    required property int edgeHandlerX
                    required property int edgeHandlerY
                    required property int edgeHandlerWidth
                    required property int edgeHandlerHeight
                    x: edgeHandlerX
                    y: edgeHandlerY
                    width: edgeHandlerWidth
                    height: edgeHandlerHeight
                    radius: 2
                    color: obj.annotationColor
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
                        onEntered: function(){
                            switch(parent.resizeType) {
                            case 0: {
                                detectionLabelLayer.editType = CanvasEnums.EditType.ResizeLeftEdge
                                break
                            }
                            case 1: {
                                detectionLabelLayer.editType = CanvasEnums.EditType.ResizeTopEdge
                                break
                            }
                            case 2: {
                                detectionLabelLayer.editType = CanvasEnums.EditType.ResizeRightEdge
                                break
                            }
                            case 3: {
                                detectionLabelLayer.editType = CanvasEnums.EditType.ResizeBottomEdge
                                break
                            }
                            default: {
                                detectionLabelLayer.editType = CanvasEnums.EditType.None
                                break
                            }
                            }
                        }
                        onExited: {
                            detectionLabelLayer.editType = CanvasEnums.EditType.None
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
