#include "qmlutilscpp.h"
#include <QDateTime>
#include <QLineF>

QmlUtilsCpp::QmlUtilsCpp(QObject *parent)
    : QObject{parent}
{

}

QString QmlUtilsCpp::now() const{
    return  QDateTime::currentDateTime().toString("yyyy-MM-ddTHH:mm:ss.zzz");
}

double QmlUtilsCpp::calcateAngle(const QPointF& p0, const QPointF& p1){
    QLineF line(p0,p1);
    return line.angle();
}

double QmlUtilsCpp::calcateLength(const QPointF& p0, const QPointF& p1){
    QLineF line(p0, p1);
    return line.length();
}

 double QmlUtilsCpp::distancePointToPoints(const QPointF& point0, const QPointF& point1,const QPointF& point2){

    QLineF line(point0,point1);
    return distancePointToLine(point2,line);

}

// 计算点到直线的距离
 double QmlUtilsCpp::distancePointToLine(const QPointF& point, const QLineF& line) {
    double x1 = line.p1().x();
    double y1 = line.p1().y();
    double x2 = line.p2().x();
    double y2 = line.p2().y();
    double x3 = point.x();
    double y3 = point.y();

    // 计算直线方程的系数
    double A = y2 - y1;
    double B = x1 - x2;
    double C = x2 * y1 - x1 * y2;

    // 计算点到直线的距离
    double numerator = std::abs(A * x3 + B * y3 + C);
    double denominator = std::sqrt(A * A + B * B);
    double distance = numerator / denominator;

    return distance;
}

// 判断点是否在直线的左侧
 bool QmlUtilsCpp::isPointLeftOfLine(const QPointF& point, const QLineF& line) {
    double x1 = line.p1().x();
    double y1 = line.p1().y();
    double x2 = line.p2().x();
    double y2 = line.p2().y();
    double x3 = point.x();
    double y3 = point.y();

    // 计算向量 v1 和 v2
    double v1_x = x2 - x1;
    double v1_y = y2 - y1;
    double v2_x = x3 - x1;
    double v2_y = y3 - y1;

    // 计算叉乘
    double crossProduct = v1_x * v2_y - v1_y * v2_x;

    // 判断点的位置（叉乘结果 > 0 表示在左侧）
    return crossProduct > 0;
}

