
import QtQuick.Shapes
import QtQuick
import HuskarUI.Basic
import EasyLabel
Item {
    id: keyPointLabelLayer
    property AnnotationConfig annotationConfig
    // 该状态是由用户点击某个案件或者快捷键触犯发的，容易在最外层对操作进行限制
    property int drawStatus: CanvasEnums.OptionStatus.Drawing
    property int drawType: -1
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
    property bool isClosing: false
    property var points: []
    // 在多边形绘制中，判断某个点是否已经绘制完成的标志
    property bool pointFinished: false
    // 判断整个多边形是否已经绘制完成的标志（这是比大多数标注工具更加实用的部分，因为大多数标注工具标注玩一个后，又要重新触发一个对象去标注）
    property bool shapeFinished: true
    property point latestDragPoint: Qt.point(0, 0)
    // 全局的一些样式属性，会根据当前画面的缩放比进行自适应，不然当图片分辨率很高,缩放比变很小后，
    // 线宽如果还保持1的话，缩小后，线宽低于1个像素就无法显示
    property real closingThreshold: 5 / scaleFactor
    property real fillOpacity: keyPointLabelLayer.annotationConfig.currentFillOpacity
    property int handlerWidth: annotationConfig.currentCornerRadius / scaleFactor
    property int handlerHeight: annotationConfig.currentCornerRadius / scaleFactor
    property int fontPixSize: annotationConfig.fontPointSize / scaleFactor
    property int borderWidth: Math.max(1.0, annotationConfig.currentLineWidth / scaleFactor)
    property bool showLabel: annotationConfig.showLabel

    Crosshair {
        id: crosshair
        anchors.fill: parent
        visible: keyPointLabelLayer.drawStatus !== CanvasEnums.Select
        crossColor: keyPointLabelLayer.currentLabelColor
        centerPointerSize: keyPointLabelLayer.annotationConfig.centerPointerSize
        lineWidth: keyPointLabelLayer.annotationConfig.currentLineWidth
        scaleFactor: keyPointLabelLayer.scaleFactor
        showCoordinates: true
        showCenterPoint: true
    }

    // 显示所有标注框
    Repeater {
        model: keyPointLabelLayer.listModel
        delegate: Item {
            id: obj
            required property int index
            required property int labelID
            required property double boxX
            required property double boxY
            required property double boxWidth
            required property double boxHeight
            required property int type // 0: bounxing box   1:point
            required property bool selected
            readonly property bool showHandlers: selected
            property int pointRadius: 4
            property color annotationColor: keyPointLabelLayer.annotationConfig.labelListModel.getLabelColor(labelID)
            property string annotationLabel: keyPointLabelLayer.annotationConfig.labelListModel.getLabel(labelID)
            property color fillColor: Qt.rgba(annotationColor.r, annotationColor.g, annotationColor.b, keyPointLabelLayer.fillOpacity)

            Connections{
                target: keyPointLabelLayer.annotationConfig.labelListModel
                function onDataChanged(){
                    annotationColor = keyPointLabelLayer.annotationConfig.labelListModel.getLabelColor(obj.labelID)
                    annotationLabel = keyPointLabelLayer.annotationConfig.labelListModel.getLabel(obj.labelID)
                }
            }
            // 绘制bounding box 和 point type 0: bounxing box   1:point
            Rectangle{
                x: type === 0 ? boxX: boxX - pointRadius
                y: type === 0 ? boxY: boxY - pointRadius
                width: type === 0 ? boxWidth: 2* pointRadius
                height: type === 0 ? boxHeight: 2* pointRadius
                radius: pointRadius
                border.color: annotationColor
                border.width: borderWidth
                // border.style: selected ? Qt.DashDotLine: Qt.SolidLine
                color: type === 0? fillColor: annotationColor
                // 标签
                Rectangle{
                    x: 0
                    y: -text.height
                    width: text.width
                    height: text.height
                    visible: keyPointLabelLayer.showLabel
                    color: obj.annotationColor
                    HusText{
                        id: text
                        font.pixelSize: keyPointLabelLayer.fontPixSize
                        color: QmlGlobalHelper.revertColor(obj.annotationColor)
                        text: obj.annotationLabel
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
                if(keyPointLabelLayer.drawStatus !== CanvasEnums.Select) {
                    // 绘制模式：开始绘制新矩形
                    if(keyPointLabelLayer.currentLabelID===-1){
                        QmlGlobalHelper.message.error("请选择一个标签")
                        return
                    }
                }else{
                    keyPointLabelLayer.selectedIndex = keyPointLabelLayer.listModel.getSelectedIndex(mouse.x, mouse.y)
                    if(keyPointLabelLayer.selectedIndex >= 0){
                        keyPointLabelLayer.listModel.setSingleSelected(keyPointLabelLayer.selectedIndex)
                        // 如果不处于编辑状态 判断非常重要，因为子组件的鼠标事件会传递，不判断的话，就只会走Move
                        if(keyPointLabelLayer.editType === CanvasEnums.None){
                            keyPointLabelLayer.editType = CanvasEnums.Move
                            keyPointLabelLayer.isEditing = true

                        }
                        keyPointLabelLayer.latestDragPoint = Qt.point(mouse.x, mouse.y)
                    } else {
                        // 没有元素被选中
                        keyPointLabelLayer.listModel.removeAllSelected()
                        keyPointLabelLayer.selectedIndex = -1
                        keyPointLabelLayer.editType=CanvasEnums.None
                    }
                }
            }
        }

        onPositionChanged: function(mouse) {
            if (keyPointLabelLayer.drawStatus !== CanvasEnums.Select) {
                if(keyPointLabelLayer.currentLabelID === -1) return
                // 鼠标按下会拦截HoverHandler,所以在绘制状态持续更新十字线的坐标
                let mousePosition = Qt.point(mouse.x, mouse.y)
                crosshair.mousePosition = mousePosition
                let last = keyPointLabelLayer.listModel.rowCount() - 1
                // if(keyPointLabelLayer.listModel.rowCount() >= 1){
                //     if(!keyPointLabelLayer.shapeFinished){
                //         if(keyPointLabelLayer.pointFinished){
                //             // keyPointLabelLayer.listModel.appendPoint(last, mousePosition)
                //             keyPointLabelLayer.pointFinished = false
                //         }
                //         let p0 = keyPointLabelLayer.listModel.getPoints(last)[0]
                //         keyPointLabelLayer.isClosing = QmlUtilsCpp.calculateLength(mousePosition, p0) < keyPointLabelLayer.closingThreshold
                //         keyPointLabelLayer.listModel.updateLastPoint(last, mousePosition)
                //     }
                // }
            }else if (keyPointLabelLayer.drawStatus === CanvasEnums.Select){
                if(keyPointLabelLayer.selectedIndex >= 0){
                    let points = keyPointLabelLayer.listModel.getPoints(keyPointLabelLayer.selectedIndex)
                    // 这里很关键，不然对象在修改某个点的时候不流畅，因为在鼠标拖动过程中实时检测EditType，
                    // 如果鼠标移动过快，编辑状态可能会改变，导致编辑不流畅
                    if(!keyPointLabelLayer.isEditing){
                        updateEditType(points, Qt.point(mouse.x, mouse.y))
                    }
                    // 修改鼠标的央视
                    if(keyPointLabelLayer.editType !== CanvasEnums.None){
                        drawArea.cursorShape = Qt.PointingHandCursor
                    }else{
                        drawArea.cursorShape = Qt.ArrowCursor
                    }
                    if(mouse.buttons & Qt.LeftButton ){
                        // 根据编辑类型计算新的位置和尺寸
                        if(keyPointLabelLayer.editType===CanvasEnums.Move){
                            keyPointLabelLayer.isEditing = true
                            var dx = mouse.x - keyPointLabelLayer.latestDragPoint.x
                            var dy = mouse.y - keyPointLabelLayer.latestDragPoint.y
                            keyPointLabelLayer.latestDragPoint.x = mouse.x
                            keyPointLabelLayer.latestDragPoint.y = mouse.y
                            keyPointLabelLayer.listModel.moveShape(keyPointLabelLayer.selectedIndex, Qt.point(dx, dy))
                        }
                        if(keyPointLabelLayer.editType===CanvasEnums.ResizeAnyPoint){
                            keyPointLabelLayer.isEditing = true
                            let mousePoint = Qt.point(mouse.x,mouse.y);
                            keyPointLabelLayer.listModel.updatePoint(keyPointLabelLayer.selectedIndex, keyPointLabelLayer.editPointIndex, mousePoint)
                        }
                    }
                }
            }
        }
        onReleased: function(mouse) {
            if (mouse.button === Qt.LeftButton) {
                let point = Qt.point(mouse.x, mouse.y)
                if(keyPointLabelLayer.drawStatus === CanvasEnums.Point){
                    // x,y,width,height,type,visible,groupID,zorder,selected
                    keyPointLabelLayer.listModel.addItem(
                                keyPointLabelLayer.currentLabelID, point.x, point.y,
                                0,0,1,2,0,keyPointLabelLayer.zOrder++, false)
                }

                if (keyPointLabelLayer.drawStatus === CanvasEnums.Rectangle) {
                    if(keyPointLabelLayer.shapeFinished){
                        // x,y,width,height,type,visible,groupID,zorder,selected
                        keyPointLabelLayer.listModel.addItem(
                                    keyPointLabelLayer.currentLabelID, point.x, point.y,
                                    0,0,0,2,0,keyPointLabelLayer.zOrder++, false)
                        keyPointLabelLayer.points.push(point)
                        keyPointLabelLayer.shapeFinished = false
                    }
                    // 该处逻辑表达的是，当最后一个点移动到离第一个点很近的时候，再次点击鼠标后即完成一个shape的绘制，将shapeFinished 设置为 true
                    let last = keyPointLabelLayer.listModel.rowCount() - 1
                    keyPointLabelLayer.points.push(point)
                    if (!keyPointLabelLayer.shapeFinished){
                        if(keyPointLabelLayer.points.length === 2){
                            // 点击一下应该删除最后一个点（在鼠标移动中一直动态的一个点），因为最后一个点就是第一个点
                            let p0 = keyPointLabelLayer.points[0]
                            let p1 = keyPointLabelLayer.points[1]
                            let width = p1.x - p0.x
                            let height = p1.y - p0.y
                            keyPointLabelLayer.listModel.setProperty(last,"boxWidth",width)
                            keyPointLabelLayer.listModel.setProperty(last,"boxHeight",height)
                            keyPointLabelLayer.shapeFinished = true
                            keyPointLabelLayer.editType = CanvasEnums.None
                            keyPointLabelLayer.listModel.setSelected(last, false)
                        }
                    }
                    pointFinished = true
                }
                keyPointLabelLayer.isEditing = false
                keyPointLabelLayer.editType = CanvasEnums.None
            }
        }
    }

    function updateEditType(points, point){
        if(points.length < 3)  return
        for(let i = 0; i < points.length; i++){
            let itemRect = Qt.rect(points[i].x-handlerWidth/2, points[i].y-handlerHeight/2, handlerWidth, handlerHeight)
            if(QmlUtilsCpp.isPointInRect(itemRect, point)){
                keyPointLabelLayer.editType =  CanvasEnums.ResizeAnyPoint
                keyPointLabelLayer.editPointIndex = i
                return
            }
        }
        keyPointLabelLayer.editType =  CanvasEnums.None
        keyPointLabelLayer.editPointIndex = -1
    }
}
