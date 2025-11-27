
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

    property int handlerWidth: annotationConfig.currentCornerRadius/scaleFactor
    property int handlerHeight: annotationConfig.currentCornerRadius/scaleFactor
    property int fontPixSize: annotationConfig.fontPointSize / rotationBoxLabelLayer.scaleFactor
    property bool showLabel: annotationConfig.showLabel
    property rect startRect: Qt.rect(0, 0, 0, 0)
    property double startRotation : 0.0
    property var realRotatedRectPoints: QmlUtilsCpp.rotatedRectCorners(startRect, startRotation)
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

    // 显示所有标注框
    Repeater {
        model: rotationBoxLabelLayer.listModel
        delegate: Item {
            id: obj
            required property int index
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
            HusRectangle{
                x: boxX
                y: boxY
                width: boxWidth
                height: boxHeight
                rotation: boxRotation
                border.color: annotationColor
                transformOrigin: Item.TopLeft
                antialiasing: true
                smooth: true
                border.width: rotationBoxLabelLayer.annotationConfig.currentLineWidth/rotationBoxLabelLayer.scaleFactor
                border.style: selected ? Qt.DashDotLine: Qt.SolidLine
                color: Qt.rgba(annotationColor.r, annotationColor.g, annotationColor.b, rotationBoxLabelLayer.annotationConfig.currentFillOpacity)
                // 标签
                Rectangle{
                    x: 0
                    y: -text.height
                    width: text.width
                    height: text.height
                    visible: rotationBoxLabelLayer.showLabel
                    color: obj.annotationColor
                    HusText{
                        id: text
                        font.pixelSize: rotationBoxLabelLayer.fontPixSize
                        color: QmlGlobalHelper.revertColor(obj.annotationColor)
                        text: obj.annotationLabel
                    }
                }

                // 控制点
                Repeater {
                    model: obj.showHandlers ? rotationBoxLabelLayer.
                                              getCornerHandlerModel(obj.boxWidth, obj.boxHeight,
                                                                    rotationBoxLabelLayer.handlerWidth, rotationBoxLabelLayer.handlerHeight) : []
                    delegate: Rectangle {
                        id: edgeHandler
                        required property int index
                        required property int cornerHandlerX
                        required property int cornerHandlerY
                        required property int cornerHandlerWidth
                        required property int cornerHandlerHeight
                        x: cornerHandlerX
                        y: cornerHandlerY
                        width: cornerHandlerWidth
                        height: cornerHandlerHeight
                        radius: cornerHandlerWidth / 2
                        color: obj.annotationColor
                        property int resizeType: index // 0:左 1:上 2:右 3:下
                    }
                }
                Connections{
                    target: rotationBoxLabelLayer.annotationConfig.labelListModel
                    function onDataChanged(){
                        annotationColor = rotationBoxLabelLayer.annotationConfig.labelListModel.getLabelColor(obj.labelID)
                        annotationLabel = rotationBoxLabelLayer.annotationConfig.labelListModel.getLabel(obj.labelID)
                    }
                }
            }
        }
    }
    MouseArea {
        id: drawArea
        anchors.fill: parent
        // anchors.margins: -handlerWidth/2
        property int selectedIndex
        hoverEnabled: true
        onPressed: function(mouse) {
            if(mouse.button === Qt.LeftButton) {
                if(rotationBoxLabelLayer.drawStatus === CanvasEnums.Drawing) {
                    // 绘制模式：开始绘制新矩形
                    if(rotationBoxLabelLayer.currentLabelID===-1){
                        QmlGlobalHelper.message.error("请选择一个标签")
                        return
                    }
                }else{
                    rotationBoxLabelLayer.selectedIndex = rotationBoxLabelLayer.listModel.getSelectedIndex(mouse.x, mouse.y)
                    if(rotationBoxLabelLayer.selectedIndex >= 0){
                        rotationBoxLabelLayer.listModel.setSingleSelected(rotationBoxLabelLayer.selectedIndex)
                        // 如果不处于编辑状态 判断非常重要，因为子组件的鼠标事件会传递，不判断的话，就只会走Move
                        if(rotationBoxLabelLayer.editType === CanvasEnums.None){
                            rotationBoxLabelLayer.editType = CanvasEnums.Move
                        }
                        rotationBoxLabelLayer.dragStartPoint = Qt.point(mouse.x, mouse.y)
                        rotationBoxLabelLayer.startRect = rotationBoxLabelLayer.listModel.getRect(rotationBoxLabelLayer.selectedIndex)
                        rotationBoxLabelLayer.startRotation = rotationBoxLabelLayer.listModel.getRotation(rotationBoxLabelLayer.selectedIndex)
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
            if (rotationBoxLabelLayer.drawStatus === CanvasEnums.Drawing) {
                if(rotationBoxLabelLayer.currentLabelID === -1) return
                // 鼠标按下会拦截HoverHandler,所以在绘制状态持续更新十字线的坐标
                rotationBoxLabelLayer.mousePosition = Qt.point(mouse.x, mouse.y)
                crosshair.mousePosition = rotationBoxLabelLayer.mousePosition
                // 绘制模式：更新矩形大小（保持不变）
                let last = rotationBoxLabelLayer.listModel.rowCount() - 1
                if(points.length===1){
                    let p0 = points[0]
                    let p1 = rotationBoxLabelLayer.mousePosition
                    let angle = QmlUtilsCpp.calcateAngleToRotation(p0, p1)
                    let length = QmlUtilsCpp.calcateLength(p0,  p1)
                    rotationBoxLabelLayer.listModel.setProperty(last,"boxWidth", length)
                    rotationBoxLabelLayer.listModel.setProperty(last,"boxRotation", angle)
                }else if(points.length===2){
                    let p0 = points[0]
                    let p1 = points[1]
                    let p2 = Qt.point(mouse.x, mouse.y)
                    let boxHeight = QmlUtilsCpp.distancePointToPoints(p0, p1, p2)
                    if(QmlUtilsCpp.isPointAboveLine([p0,p1,p2])){
                        boxHeight = 1
                    }
                    rotationBoxLabelLayer.listModel.setProperty(last,"boxHeight", boxHeight)
                }
            }else if (rotationBoxLabelLayer.drawStatus === CanvasEnums.Select){
                if(rotationBoxLabelLayer.selectedIndex >= 0){
                    updateEditType(rotationBoxLabelLayer.realRotatedRectPoints, Qt.point(mouse.x,mouse.y))
                    if(rotationBoxLabelLayer.editType !== CanvasEnums.None){
                        drawArea.cursorShape = Qt.PointingHandCursor
                    }else{
                        drawArea.cursorShape = Qt.ArrowCursor
                    }
                    if(mouse.buttons & Qt.LeftButton ){
                        // 根据编辑类型计算新的位置和尺寸
                        if(rotationBoxLabelLayer.editType===CanvasEnums.Move){
                            var dx = mouse.x - rotationBoxLabelLayer.dragStartPoint.x
                            var dy = mouse.y - rotationBoxLabelLayer.dragStartPoint.y
                            var newX = rotationBoxLabelLayer.startRect.x + dx
                            var newY = rotationBoxLabelLayer.startRect.y + dy
                            rotationBoxLabelLayer.listModel.setProperty(rotationBoxLabelLayer.selectedIndex, "boxX", newX)
                            rotationBoxLabelLayer.listModel.setProperty(rotationBoxLabelLayer.selectedIndex, "boxY", newY)
                        }
                        if(rotationBoxLabelLayer.editType===CanvasEnums.ResizeLeftTopCorner){
                            let rectPoints = QmlUtilsCpp.rotatedRectCorners(startRect, startRotation)
                            let p0 = Qt.point(mouse.x,mouse.y);
                            let p1 = rectPoints[1];
                            let p2 = rectPoints[2];
                            let p3 = rectPoints[3];
                            let boxWidth = QmlUtilsCpp.distancePointToPoints(p1,p2,p0);
                            let boxHeight = QmlUtilsCpp.distancePointToPoints(p3,p2,p0);
                            rotationBoxLabelLayer.listModel.setProperty(rotationBoxLabelLayer.selectedIndex, "boxX", p0.x)
                            rotationBoxLabelLayer.listModel.setProperty(rotationBoxLabelLayer.selectedIndex, "boxY", p0.y)
                            rotationBoxLabelLayer.listModel.setProperty(rotationBoxLabelLayer.selectedIndex, "boxWidth", boxWidth)
                            rotationBoxLabelLayer.listModel.setProperty(rotationBoxLabelLayer.selectedIndex, "boxHeight", boxHeight)
                        }
                        if(rotationBoxLabelLayer.editType===CanvasEnums.ResizeRightTopCorner){
                            let rectPoints = QmlUtilsCpp.rotatedRectCorners(startRect, startRotation)
                            let p0 = rectPoints[0];
                            let p1 = Qt.point(mouse.x,mouse.y);
                            let p2 = rectPoints[2];
                            let p3 = rectPoints[3];
                            let boxWidth = QmlUtilsCpp.distancePointToPoints(p0, p3, p1);
                            let boxRotation = QmlUtilsCpp.calcateAngleToRotation(p0, p1)
                            rotationBoxLabelLayer.listModel.setProperty(rotationBoxLabelLayer.selectedIndex, "boxRotation", boxRotation)
                            rotationBoxLabelLayer.listModel.setProperty(rotationBoxLabelLayer.selectedIndex, "boxWidth", boxWidth)
                        }
                        if(rotationBoxLabelLayer.editType===CanvasEnums.ResizeBottomEdge){
                            let rectPoints = QmlUtilsCpp.rotatedRectCorners(startRect, startRotation)
                            let p0 = rectPoints[0];
                            let p1 = rectPoints[1];
                            let p2 = Qt.point(mouse.x,mouse.y);
                            let boxHeight = QmlUtilsCpp.distancePointToPoints(p0, p1, p2)
                            if(QmlUtilsCpp.isPointAboveLine([p0,p1,p2])){
                                boxHeight = 1
                            }
                            rotationBoxLabelLayer.listModel.setProperty(rotationBoxLabelLayer.selectedIndex, "boxHeight", boxHeight)
                        }
                    }
                }
            }
        }
        onReleased: function(mouse) {
            if (mouse.button === Qt.LeftButton) {
                if (rotationBoxLabelLayer.drawStatus === CanvasEnums.Drawing) {
                    rotationBoxLabelLayer.drawFinished()
                    let point = Qt.point(mouse.x, mouse.y)
                    points.push(point)
                    if(points.length===1){
                        rotationBoxLabelLayer.listModel.addItem(rotationBoxLabelLayer.currentLabelID, point.x, point.y, 0, 1, rotationBoxLabelLayer.zOrder++, 0 , false)
                    }
                    if(points.length === 3){
                        rotationBoxLabelLayer.editType = CanvasEnums.None
                        points = []
                    }
                }
                rotationBoxLabelLayer.editType = CanvasEnums.None
            }
        }
    }

    function updateEditType(points, point){
        if(points.length < 4)  return
        let point0 = points[0]
        let point1 = points[1]
        let point2 = Qt.point((points[2].x +points[3].x)/2,(points[2].y +points[3].y)/2 )
        let itemRect1 = Qt.rect(point0.x-handlerWidth/2, point0.y-handlerHeight/2, handlerWidth, handlerHeight)
        let itemRect2 = Qt.rect(point1.x-handlerWidth/2, point1.y-handlerHeight/2, handlerWidth, handlerHeight)
        let itemRect3 = Qt.rect(point2.x-handlerWidth/2, point2.y-handlerHeight/2, handlerWidth, handlerHeight)
        if(QmlUtilsCpp.isPointInRect(itemRect1,point)){
            rotationBoxLabelLayer.editType = CanvasEnums.ResizeLeftTopCorner
        }
        if(QmlUtilsCpp.isPointInRect(itemRect2,point)){
            rotationBoxLabelLayer.editType =  CanvasEnums.ResizeRightTopCorner
        }
        if(QmlUtilsCpp.isPointInRect(itemRect3,point)){
            rotationBoxLabelLayer.editType =  CanvasEnums.ResizeBottomEdge
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
                    //下
                    {
                        "cornerHandlerX": labelWidth/2 - handlerWidth/2,
                        "cornerHandlerY": labelHeight - handlerHeight/2,
                        "cornerHandlerWidth":handlerWidth,
                        "cornerHandlerHeight":handlerHeight
                    }

                ]
    }
}
