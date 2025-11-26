#pragma once
#include <QObject>
#include <QPointF>
#include <QQmlEngine>

class QmlUtilsCpp : public QObject {
    Q_OBJECT
    QML_SINGLETON
    QML_ELEMENT

public:
    Q_INVOKABLE QString now() const;

    explicit QmlUtilsCpp(QObject *parent = nullptr);

    Q_INVOKABLE double calcateAngle(const QPointF& p0, const QPointF& p1);
    Q_INVOKABLE double calcateLength(const QPointF& p0, const QPointF& p1);
    Q_INVOKABLE double distancePointToPoints(const QPointF &point0,
                                             const QPointF &point1,
                                             const QPointF &point2);

    // 计算点到直线的距离
     double distancePointToLine(const QPointF &point,
                                           const QLineF &line);

    // 判断点是否在直线的左侧
     bool isPointLeftOfLine(const QPointF &point, const QLineF &line);

signals:
};
