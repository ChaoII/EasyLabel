import QtQuick

Item {

    enum OptionStatus{
        Select = 0,
        Drawing = 1
    }

    enum EditStatus{
        Move = 0,
        Resize = 1,
        None = 2
    }

    enum ResizeType{
        LeftTopCorner = 0,
        RightTopCorner = 1,
        LeftBottomCorner = 2,
        RightBottomCorner = 3,
        LeftEdge = 4,
        TopEdge = 5,
        RightEdge = 6,
        BottomEdge = 7,
        None=8
    }
}
