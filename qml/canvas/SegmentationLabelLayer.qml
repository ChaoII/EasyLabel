
import QtQuick.Shapes
import QtQuick
import HuskarUI.Basic
import EasyLabel
Item {
    id: segmentationLabelLayer
    property AnnotationConfig annotationConfig
    // 该状态是由用户点击某个案件或者快捷键触犯发的，容易在最外层对操作进行限制
    property int drawStatus: CanvasEnums.OptionStatus.Drawing
    property var listModel: annotationConfig.currentAnnotationModel
    property int currentLabelID: annotationConfig.currentLabelIndex
    property color currentLabelColor: annotationConfig.currentLabelColor
    property string currentLabel: annotationConfig.currentLabel
    property int selectedIndex: -1
    property real scaleFactor: 1.0
    property int zOrder: -1
    // 该状态是由用户根据不同过的操作情况手动进行编辑类型，比如鼠标移动到控制点后，就会变成编辑某个控制点的类型
    // 鼠标移动到非编辑点并且点击目标后移动类型
    property int editType: CanvasEnums.EditType.None
    // 确定鼠标移动到哪个编辑点了
    property int editPointIndex: -1
    // 是否正在移动或者编辑点，如果正在编辑点的时候就关闭editType检测，关闭类型检测后，
    // 无论是移动还是编辑点都会很跟手，当释放鼠标左键后，又重新开启了类型检测是移动还是其它
    // 这一点很关键
    property bool isEditing: false
    property point latestDragPoint: Qt.point(0, 0)
    // 全局的一些样式属性，会根据当前画面的缩放比进行自适应，不然当图片分辨率很高,缩放比变很小后，
    // 线宽如果还保持1的话，缩小后，线宽低于1个像素就无法显示
    property real fillOpacity: segmentationLabelLayer.annotationConfig.currentFillOpacity
    property int handlerWidth: annotationConfig.currentCornerRadius / scaleFactor
    property int handlerHeight: annotationConfig.currentCornerRadius / scaleFactor
    property int fontPixSize: annotationConfig.fontPointSize / scaleFactor
    property int borderWidth: annotationConfig.currentLineWidth / scaleFactor
    property bool pointFinished: false
    property bool shapeFinished: true
    property bool showLabel: annotationConfig.showLabel

    Component.onCompleted: {
        console.log("segmentationLabelLayer")
    }

    Crosshair {
        id: crosshair
        anchors.fill: parent
        visible: segmentationLabelLayer.drawStatus === CanvasEnums.Drawing
        crossColor: segmentationLabelLayer.currentLabelColor
        centerPointerSize: segmentationLabelLayer.annotationConfig.centerPointerSize
        lineWidth: segmentationLabelLayer.annotationConfig.currentLineWidth
        scaleFactor: segmentationLabelLayer.scaleFactor
        showCoordinates: true
        showCenterPoint: true
    }

    // 显示所有标注框
    Repeater {
        model: segmentationLabelLayer.listModel
        delegate: Item {
            id: obj
            required property int index
            required property int labelID
            required property var points
            required property bool selected
            property rect boundingRect: points? QmlUtilsCpp.getBoundingRect(points): Qt.rect(0,0,0,0)
            readonly property bool showHandlers: selected
            property color annotationColor: segmentationLabelLayer.annotationConfig.labelListModel.getLabelColor(labelID)
            property string annotationLabel: segmentationLabelLayer.annotationConfig.labelListModel.getLabel(labelID)
            property color fillColor: Qt.rgba(annotationColor.r, annotationColor.g, annotationColor.b, segmentationLabelLayer.fillOpacity)
            // 绘制多边形

            Shape {
                anchors.fill: parent
                visible: points.length > 0
                ShapePath {
                    id: shapePath
                    strokeWidth: borderWidth
                    strokeColor: annotationColor
                    fillColor: Qt.rgba(annotationColor.r, annotationColor.g, annotationColor.b, 0.3)
                    strokeStyle: shapeFinished? ShapePath.SolidLine : ShapePath.DashLine
                    dashPattern: shapeFinished ? [] : [1, 2]
                    // 使用 PathPolyline 动态绘制
                    PathPolyline {
                        id: pathPolyline
                        path: createPath(points)
                    }
                }

                // 绘制顶点
                Repeater {
                    model: obj.showHandlers? points.length:[]
                    delegate: Rectangle {
                        required property int index
                        x: points[index].x - handlerWidth  / 2
                        y: points[index].y - handlerHeight / 2
                        width: handlerWidth
                        height: handlerHeight
                        radius: handlerWidth  / 2
                        color: obj.annotationColor
                        border.width: borderWidth
                        border.color: "white"
                    }
                }
            }

            HusRectangle{
                visible: points.length >= 3
                x: boundingRect.x
                y: boundingRect.y
                width: boundingRect.width
                height: boundingRect.height
                border.color: annotationColor
                antialiasing: true
                smooth: true
                border.width: borderWidth
                border.style: selected ? Qt.DashDotLine: Qt.SolidLine
                color: fillColor
                // 标签
                Rectangle{
                    x: 0
                    y: -text.height
                    width: text.width
                    height: text.height
                    visible: segmentationLabelLayer.showLabel
                    color: obj.annotationColor
                    HusText{
                        id: text
                        font.pixelSize: segmentationLabelLayer.fontPixSize
                        color: QmlGlobalHelper.revertColor(obj.annotationColor)
                        text: obj.annotationLabel
                    }
                }
                Connections{
                    target: segmentationLabelLayer.annotationConfig.labelListModel
                    function onDataChanged(){
                        annotationColor = segmentationLabelLayer.annotationConfig.labelListModel.getLabelColor(obj.labelID)
                        annotationLabel = segmentationLabelLayer.annotationConfig.labelListModel.getLabel(obj.labelID)
                    }
                }
            }
        }
    }

    function createPath(points) {
        var path = points
        if (points.length >= 3) {
            path.push(points[0])
        }
        return path
    }


    MouseArea {
        id: drawArea
        anchors.fill: parent
        // anchors.margins: -handlerWidth/2
        property int selectedIndex
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        hoverEnabled: true
        onPressed: function(mouse) {
            if(mouse.button === Qt.LeftButton) {
                if(segmentationLabelLayer.drawStatus === CanvasEnums.Drawing) {
                    // 绘制模式：开始绘制新矩形
                    if(segmentationLabelLayer.currentLabelID===-1){
                        QmlGlobalHelper.message.error("请选择一个标签")
                        return
                    }
                }else{
                    segmentationLabelLayer.selectedIndex = segmentationLabelLayer.listModel.getSelectedIndex(mouse.x, mouse.y)
                    if(segmentationLabelLayer.selectedIndex >= 0){
                        segmentationLabelLayer.listModel.setSingleSelected(segmentationLabelLayer.selectedIndex)
                        // 如果不处于编辑状态 判断非常重要，因为子组件的鼠标事件会传递，不判断的话，就只会走Move
                        if(segmentationLabelLayer.editType === CanvasEnums.None){
                            segmentationLabelLayer.editType = CanvasEnums.Move
                            segmentationLabelLayer.isEditing = true

                        }
                        segmentationLabelLayer.latestDragPoint = Qt.point(mouse.x, mouse.y)
                    } else {
                        // 没有元素被选中
                        segmentationLabelLayer.listModel.removeAllSelected()
                        segmentationLabelLayer.selectedIndex = -1
                        segmentationLabelLayer.editType=CanvasEnums.None
                    }
                }
            }
        }

        onClicked:function(mouse) {
            if(mouse.button === Qt.RightButton){
                if (segmentationLabelLayer.drawStatus === CanvasEnums.Drawing){
                    let last = segmentationLabelLayer.listModel.rowCount()-1
                    let lastPointSize = segmentationLabelLayer.listModel.getPointSize(last)
                    if (lastPointSize > 3 && !shapeFinished) {
                        segmentationLabelLayer.listModel.popBackPoint(last)
                        shapeFinished = true
                        segmentationLabelLayer.editType = CanvasEnums.None
                    }
                }
            }
        }

        onPositionChanged: function(mouse) {
            if (segmentationLabelLayer.drawStatus === CanvasEnums.Drawing) {
                if(segmentationLabelLayer.currentLabelID === -1) return
                // 鼠标按下会拦截HoverHandler,所以在绘制状态持续更新十字线的坐标
                let mousePosition = Qt.point(mouse.x, mouse.y)
                crosshair.mousePosition = mousePosition
                let last = segmentationLabelLayer.listModel.rowCount() - 1
                if(segmentationLabelLayer.listModel.rowCount() >= 1){
                    if(!shapeFinished){
                        if(pointFinished ){
                            segmentationLabelLayer.listModel.appendPoint(last, mousePosition)
                            pointFinished = false
                        }
                        segmentationLabelLayer.listModel.updateLastPoint(last, mousePosition)
                    }
                }
            }else if (segmentationLabelLayer.drawStatus === CanvasEnums.Select){
                if(segmentationLabelLayer.selectedIndex >= 0){
                    let points = segmentationLabelLayer.listModel.getPoints(segmentationLabelLayer.selectedIndex)
                    updateEditType(points, Qt.point(mouse.x, mouse.y))
                    console.log("onPositionChanged",segmentationLabelLayer.isEditing, segmentationLabelLayer.editPointIndex, segmentationLabelLayer.editType)

                    if(segmentationLabelLayer.editType !== CanvasEnums.None){
                        drawArea.cursorShape = Qt.PointingHandCursor
                    }else{
                        drawArea.cursorShape = Qt.ArrowCursor
                    }
                    if(mouse.buttons & Qt.LeftButton ){
                        // 根据编辑类型计算新的位置和尺寸
                        if(segmentationLabelLayer.editType===CanvasEnums.Move){
                            segmentationLabelLayer.isEditing = true
                            var dx = mouse.x - segmentationLabelLayer.latestDragPoint.x
                            var dy = mouse.y - segmentationLabelLayer.latestDragPoint.y
                            segmentationLabelLayer.latestDragPoint.x = mouse.x
                            segmentationLabelLayer.latestDragPoint.y = mouse.y
                            segmentationLabelLayer.listModel.moveShape(segmentationLabelLayer.selectedIndex, Qt.point(dx, dy))
                        }
                        if(segmentationLabelLayer.editType===CanvasEnums.ResizeAnyPoint){
                            segmentationLabelLayer.isEditing = true
                            let mousePoint = Qt.point(mouse.x,mouse.y);
                            segmentationLabelLayer.listModel.updatePoint(segmentationLabelLayer.selectedIndex, segmentationLabelLayer.editPointIndex, mousePoint)
                        }
                    }
                }
            }
        }
        onReleased: function(mouse) {
            if (mouse.button === Qt.LeftButton) {
                if (segmentationLabelLayer.drawStatus === CanvasEnums.Drawing) {
                    let point = Qt.point(mouse.x, mouse.y)
                    if(shapeFinished){
                        segmentationLabelLayer.listModel.addItem(segmentationLabelLayer.currentLabelID, [point], segmentationLabelLayer.zOrder++, false)
                        shapeFinished = false
                    }
                    pointFinished = true
                }
                segmentationLabelLayer.isEditing = false
                segmentationLabelLayer.editType = CanvasEnums.None
                console.log("onReleased",segmentationLabelLayer.isEditing,segmentationLabelLayer.editType)
            }
        }
    }

    function updateEditType(points, point){
        if(segmentationLabelLayer.isEditing) return
        if(points.length < 3)  return
        for(let i = 0; i < points.length; i++){
            let itemRect = Qt.rect(points[i].x-handlerWidth/2, points[i].y-handlerHeight/2, handlerWidth, handlerHeight)
            if(QmlUtilsCpp.isPointInRect(itemRect, point)){
                segmentationLabelLayer.editType =  CanvasEnums.ResizeAnyPoint
                segmentationLabelLayer.editPointIndex = i
                return
            }
        }
        segmentationLabelLayer.editType =  CanvasEnums.None
        segmentationLabelLayer.editPointIndex = -1
        console.log("updateEditType",segmentationLabelLayer.isEditing,segmentationLabelLayer.editType)
    }
}
