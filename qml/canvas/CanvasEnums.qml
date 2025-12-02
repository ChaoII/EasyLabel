import QtQuick

Item {

    enum OptionStatus{
        Select = 0,
        Rectangle = 1,
        RotationBox = 2,
        Polygon = 3,
        Point = 4
    }

    enum EditType{
        Move = 0,
        ResizeLeftTopCorner = 1,
        ResizeRightTopCorner = 2,
        ResizeLeftBottomCorner = 3,
        ResizeRightBottomCorner = 4,
        ResizeLeftEdge = 5,
        ResizeTopEdge = 6,
        ResizeRightEdge = 7,
        ResizeBottomEdge = 8,
        ResizeAnyPoint = 9,
        None = 10
    }
}
