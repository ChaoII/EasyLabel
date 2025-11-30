#pragma once
#include <QObject>
#include <QPointF>
#include <QQmlEngine>


struct RotationRectangle{
    double x;
    double y;
    double width;
    double height;
    double rotation;
};


class QmlUtilsCpp : public QObject {
    Q_OBJECT
    QML_SINGLETON
    QML_ELEMENT

public:
    Q_INVOKABLE QString now() const;

    explicit QmlUtilsCpp(QObject *parent = nullptr);

    Q_INVOKABLE static double calculateAngleToRotation(const QPointF &p0,
                                                     const QPointF &p1);
    Q_INVOKABLE static double calculateLength(const QPointF &p0, const QPointF &p1);

    Q_INVOKABLE static double distancePointToPoints(const QPointF &point0,
                                                    const QPointF &point1,
                                                    const QPointF &point2);

    Q_INVOKABLE static QVector<QPointF> rotatedRectCorners(const QRectF &rect,
                                                           double rotation);

    Q_INVOKABLE static QRectF getBoundingRect(const QVector<QPointF>& polygon);

    Q_INVOKABLE static bool
    pointInRotatedRect(const QPointF &point, const QRectF &rect, double rotation);

    Q_INVOKABLE static bool isPointInRect(const QRectF &rect,
                                          const QPointF &point);

    Q_INVOKABLE static bool isPointInPolygon(const QPointF& point, const QVector<QPointF>& polygon);


    Q_INVOKABLE static bool isPointLeftOfLine(const QVector<QPointF> &points);

    Q_INVOKABLE static bool
    isPointLeftOfLineScreen(const QVector<QPointF> &points);

    Q_INVOKABLE static bool isPointAboveLine(const QVector<QPointF> &points);

    Q_INVOKABLE static QVector<QPointF> rotationRectangleToPoints(double x,double y,double width,double height,double rotation);


    // 计算点到直线的距离
    static double distancePointToLine(const QPointF &point, const QLineF &line);

    // 判断点是否在直线的左侧
    static bool isPointLeftOfLine(const QPointF &point, const QLineF &line);

    static bool isPointLeftOfLineScreen(const QPointF &point, const QLineF &line);

    static bool isPointAboveLine(const QPointF &point, const QLineF &line);

    static RotationRectangle pointsToRotationRectangle(const QVector<QPointF> &points);





    static QVector<QPointF> rotationRectangleToPoints(const RotationRectangle &rotationRectangle);



signals:
};
