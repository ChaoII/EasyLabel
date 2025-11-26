
import QtQuick
import HuskarUI.Basic
import EasyLabel
Item {
    id: rotationBoxLabelLayer
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
    property var points: []

    property rect startRect: Qt.rect(0, 0, 0, 0)
    property point mousePosition: Qt.point(0,0)
    signal drawFinished()

    Component.onCompleted: {
        console.log("rotationBoxLabelLayer")
    }

    Crosshair {
        id: crosshair
        anchors.fill: parent
        visible: rotationBoxLabelLayer.drawStatus === CanvasEnums.Drawing
        crossColor: rotationBoxLabelLayer.currentLabelColor
        centerPointerSize: rotationBoxLabelLayer.annotationConfig.centerPointerSize
        lineWidth: rotationBoxLabelLayer.annotationConfig.currentLineWidth
        scaleFactor: rotationBoxLabelLayer.scaleFactor
        showCoordinates: true
        showCenterPoint: true
    }

    onMousePositionChanged: {
        crosshair.mousePosition = mousePosition
    }

    HoverHandler{
        id: hoverHandler
        target:rotationBoxLabelLayer
        onPointChanged: function () {
            if(rotationBoxLabelLayer.drawStatus === CanvasEnums.Drawing){
                rotationBoxLabelLayer.mousePosition = point.position
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
                if(rotationBoxLabelLayer.drawStatus === CanvasEnums.Drawing) {
                    // 绘制模式：开始绘制新矩形
                    if(rotationBoxLabelLayer.currentLabelID===-1){
                        QmlGlobalHelper.message.error("请选择一个标签")
                        return
                    }
                    startX = mouse.x
                    startY = mouse.y
                } else {
                    // 选择模式：检查是否点击了矩形
                    selectedIndex = rotationBoxLabelLayer.listModel.getSelectedIndex(mouse.x, mouse.y)
                    if(rotationBoxLabelLayer.selectedIndex >= 0){
                        rotationBoxLabelLayer.listModel.setSingleSelected(rotationBoxLabelLayer.selectedIndex)
                        // 如果不处于编辑状态 判断非常重要，因为子组件的鼠标事件会传递，不判断的话，就只会走Move
                        if(rotationBoxLabelLayer.editType === CanvasEnums.None){
                            rotationBoxLabelLayer.editType = CanvasEnums.Move
                        }
                        rotationBoxLabelLayer.dragStartPoint = Qt.point(mouse.x, mouse.y)
                        let selectedRect = rotationBoxLabelLayer.listModel.getRect(rotationBoxLabelLayer.selectedIndex)
                        rotationBoxLabelLayer.startRect = Qt.rect(selectedRect.x, selectedRect.y, selectedRect.width, selectedRect.height)
                    } else {
                        // 没有元素被选中
                        rotationBoxLabelLayer.listModel.removeAllSelected()
                        rotationBoxLabelLayer.selectedIndex = -1
                        rotationBoxLabelLayer.editType=CanvasEnums.None
                    }
                }
            }
        }

        onPositionChanged: function(mouse) {
            /*if (mouse.buttons & Qt.LeftButton) */{
                if (rotationBoxLabelLayer.drawStatus === CanvasEnums.Drawing) {
                    if(rotationBoxLabelLayer.currentLabelID===-1) return
                    // 鼠标按下会拦截HoverHandler,所以在绘制状态持续更新十字线的坐标
                    rotationBoxLabelLayer.mousePosition = Qt.point(mouse.x, mouse.y)
                    // 绘制模式：更新矩形大小（保持不变）
                    let last = rotationBoxLabelLayer.listModel.rowCount() - 1
                    // console.log("points.length",points.length)
                    if(points.length===1){
                        let p0 = points[0]
                        let p1 = Qt.point(mouse.x, mouse.y)
                        let angle = QmlUtilsCpp.calcateAngle(p0, p1);
                        let length = QmlUtilsCpp.calcateLength(p0,  p1);
                        // console.log("angle",angle,"length",length)

                        rotationBoxLabelLayer.listModel.setProperty(last,"boxWidth", length);
                        rotationBoxLabelLayer.listModel.setProperty(last,"boxRotation", angle);
                    }else if(points.length===2){
                        let p0 = points[0]
                        let p1 = points[1]
                        let p2 = Qt.point(mouse.x, mouse.y)
                        let boxHeight = QmlUtilsCpp.distancePointToPoints(p0, p1, p2);
                        rotationBoxLabelLayer.listModel.setProperty(last,"boxHeight", boxHeight);
                    }
                } else if (rotationBoxLabelLayer.selectedIndex >= 0) {
                    var dx = mouse.x - rotationBoxLabelLayer.dragStartPoint.x
                    var dy = mouse.y - rotationBoxLabelLayer.dragStartPoint.y
                    var newX = rotationBoxLabelLayer.startRect.x
                    var newY = rotationBoxLabelLayer.startRect.y
                    var newWidth = rotationBoxLabelLayer.startRect.width
                    var newHeight = rotationBoxLabelLayer.startRect.height

                    // 根据编辑类型计算新的位置和尺寸
                    if(rotationBoxLabelLayer.editType===CanvasEnums.Move){
                        newX = rotationBoxLabelLayer.startRect.x + dx
                        newY = rotationBoxLabelLayer.startRect.y + dy

                        // 移动操作：确保整个矩形不超出边界
                        newX = Math.max(0, Math.min(newX, parent.width - newWidth))
                        newY = Math.max(0, Math.min(newY, parent.height - newHeight))
                    }
                    else{
                        // 调整大小操作：保持对应的锚点固定
                        var minWidth = 5
                        var minHeight = 5
                        if(rotationBoxLabelLayer.editType===CanvasEnums.ResizeLeftEdge){
                            // 保持右边固定
                            newX = Math.min(rotationBoxLabelLayer.startRect.x + dx, rotationBoxLabelLayer.startRect.x + rotationBoxLabelLayer.startRect.width - minWidth)
                            newWidth = rotationBoxLabelLayer.startRect.width - (newX - rotationBoxLabelLayer.startRect.x)
                        }
                        else if(rotationBoxLabelLayer.editType===CanvasEnums.ResizeTopEdge){
                            // 保持底边固定
                            newY = Math.min(rotationBoxLabelLayer.startRect.y + dy, rotationBoxLabelLayer.startRect.y + rotationBoxLabelLayer.startRect.height - minHeight)
                            newHeight = rotationBoxLabelLayer.startRect.height - (newY - rotationBoxLabelLayer.startRect.y)
                        }
                        else if(rotationBoxLabelLayer.editType===CanvasEnums.ResizeRightEdge){
                            // 保持左边固定
                            newWidth = Math.max(minWidth, rotationBoxLabelLayer.startRect.width + dx)
                        }
                        else if(rotationBoxLabelLayer.editType===CanvasEnums.ResizeBottomEdge){
                            // 保持顶边固定
                            newHeight = Math.max(minHeight, rotationBoxLabelLayer.startRect.height + dy)
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
                    let annotationID = rotationBoxLabelLayer.listModel.getLabelID(rotationBoxLabelLayer.selectedIndex)
                    rotationBoxLabelLayer.listModel.updateItem(rotationBoxLabelLayer.selectedIndex, annotationID ,newX, newY,newWidth,newHeight, rotationBoxLabelLayer.zOrder, true)
                }
            }
        }
        onReleased: function(mouse) {
            if (mouse.button === Qt.LeftButton) {
                if (rotationBoxLabelLayer.drawStatus === CanvasEnums.Drawing) {
                    rotationBoxLabelLayer.drawFinished()
                    points.push(Qt.point(mouse.x, mouse.y))
                    if(points.length===1){
                        rotationBoxLabelLayer.listModel.addItem(rotationBoxLabelLayer.currentLabelID, mouse.x, mouse.y, 0, 10, rotationBoxLabelLayer.zOrder++,0, false)
                    }

                    if(points.length ===3){
                        rotationBoxLabelLayer.editType = CanvasEnums.None
                        points=[]
                    }
                }
                rotationBoxLabelLayer.editType = CanvasEnums.None
            }
        }
    }
    // 显示所有标注框
    Repeater {
        model: rotationBoxLabelLayer.listModel
        delegate: HusRectangle {
            id: obj
            required property int labelID
            required property int boxX
            required property int boxY
            required property int boxWidth
            required property int boxHeight
            required property real boxRotation
            required property bool selected
            readonly property bool showHandlers: selected
            property color annotationColor: rotationBoxLabelLayer.annotationConfig.labelListModel.getLabelColor(labelID)
            property string annotationLabel: rotationBoxLabelLayer.annotationConfig.labelListModel.getLabel(labelID)

            onBoxWidthChanged:{
                console.log("boxWidth",boxWidth)
            }
            onBoxRotationChanged:{
                console.log("boxRotation",boxRotation)
            }


            onBoxHeightChanged:{
                console.log("boxHeight",boxHeight)
            }



            x: boxX
            y: boxY
            width: boxWidth
            height: boxHeight
            rotation: -boxRotation
            border.color: annotationColor
            transformOrigin: Item.TopLeft
            border.width: rotationBoxLabelLayer.annotationConfig.currentLineWidth/rotationBoxLabelLayer.scaleFactor
            border.style: selected ? Qt.DashDotLine: Qt.SolidLine
            color: Qt.rgba(annotationColor.r, annotationColor.g, annotationColor.b, rotationBoxLabelLayer.annotationConfig.currentFillOpacity)

            Connections{
                target: rotationBoxLabelLayer.annotationConfig.labelListModel
                function onDataChanged(){
                    annotationColor = rotationBoxLabelLayer.annotationConfig.labelListModel.getLabelColor(obj.labelID)
                    annotationLabel = rotationBoxLabelLayer.annotationConfig.labelListModel.getLabel(obj.labelID)
                }
            }

            // 显示标签
            HusRectangle{
                x: 0
                y: -text.height
                width: text.width
                height: text.height
                visible: rotationBoxLabelLayer.annotationConfig.showLabel
                color: obj.annotationColor
                HusText{
                    id: text
                    font.pixelSize: rotationBoxLabelLayer.annotationConfig.fontPointSize / rotationBoxLabelLayer.scaleFactor
                    color: QmlGlobalHelper.revertColor(obj.annotationColor)
                    text: obj.annotationLabel
                }
            }

            MouseArea{
                anchors.fill: parent
                anchors.margins: -Math.max(rotationBoxLabelLayer.annotationConfig.currentCornerRadius, rotationBoxLabelLayer.annotationConfig.currentEdgeHeight)
                hoverEnabled: true
                propagateComposedEvents: true
                onEntered: {
                    if(rotationBoxLabelLayer.drawStatus === CanvasEnums.OptionStatus.Select){
                        cursorShape = Qt.SizeAllCursor
                    }
                }
                onExited: {
                    if(rotationBoxLabelLayer.drawStatus === CanvasEnums.OptionStatus.Select){
                        cursorShape = Qt.ArrowCursor
                    }
                }
                onPressed:function(mouse) {
                    mouse.accepted = false
                }
            }

            // 边控制点
            Repeater {
                property int handlerWidth: rotationBoxLabelLayer.annotationConfig.currentEdgeWidth/rotationBoxLabelLayer.scaleFactor
                property int handlerHeight: rotationBoxLabelLayer.annotationConfig.currentEdgeHeight/rotationBoxLabelLayer.scaleFactor
                model: obj.showHandlers ? rotationBoxLabelLayer.getEdgeHandlerModel(obj.width, obj.height, handlerWidth, handlerHeight) : []
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
                                rotationBoxLabelLayer.editType = CanvasEnums.EditType.ResizeLeftEdge
                                break
                            }
                            case 1: {
                                rotationBoxLabelLayer.editType = CanvasEnums.EditType.ResizeTopEdge
                                break
                            }
                            case 2: {
                                rotationBoxLabelLayer.editType = CanvasEnums.EditType.ResizeRightEdge
                                break
                            }
                            case 3: {
                                rotationBoxLabelLayer.editType = CanvasEnums.EditType.ResizeBottomEdge
                                break
                            }
                            default: {
                                rotationBoxLabelLayer.editType = CanvasEnums.EditType.None
                                break
                            }
                            }
                        }
                        onExited: {
                            rotationBoxLabelLayer.editType = CanvasEnums.EditType.None
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
