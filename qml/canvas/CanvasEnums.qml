import QtQuick

Item {

    enum OptionStatus{
        Select = 0,
        Drawing = 1
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
        None = 9
    }
}
