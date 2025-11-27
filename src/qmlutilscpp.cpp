#include "qmlutilscpp.h"
#include <QDateTime>
#include <QLineF>
#include <QRect>
#include <QTransform>

QmlUtilsCpp::QmlUtilsCpp(QObject *parent)
    : QObject{parent}
{

}

QString QmlUtilsCpp::now() const{
    return  QDateTime::currentDateTime().toString("yyyy-MM-ddTHH:mm:ss.zzz");
}

double QmlUtilsCpp::calcateAngleToRotation(const QPointF& p0, const QPointF& p1){
    QLineF line(p0,p1);
    return 360 - line.angle();
}

double QmlUtilsCpp::calcateLength(const QPointF& p0, const QPointF& p1){
    QLineF line(p0, p1);
    return line.length();
}

double QmlUtilsCpp::distancePointToPoints(const QPointF& point0, const QPointF& point1,const QPointF& point2){

    QLineF line(point0,point1);
    return distancePointToLine(point2,line);

}

QVector<QPointF> QmlUtilsCpp::rotatedRectCorners(const QRectF &rect, double rotation){
    QPointF origin = rect.topLeft();
    QTransform transform;
    transform.translate(origin.x(), origin.y());
    transform.rotate(rotation);
    transform.translate(-origin.x(), -origin.y());
    return {
        transform.map(rect.topLeft()),
        transform.map(rect.topRight()),
        transform.map(rect.bottomRight()),
        transform.map(rect.bottomLeft())
    };
}

bool QmlUtilsCpp::pointInRotatedRect(const QPointF& point, const QRectF& rect, double rotation) {
    // 将点转换到矩形局部坐标系
    QTransform transform;
    QPointF origin = rect.topLeft();

    transform.translate(origin.x(), origin.y());
    transform.rotate(-rotation);
    transform.translate(-origin.x(), -origin.y());
    QPointF localPoint = transform.map(point);

    // 在局部坐标系中判断点是否在未旋转矩形内
    return rect.contains(localPoint);
}

bool QmlUtilsCpp::isPointInRect(const QRectF& rect, const QPointF &point){
    return rect.contains(point);
}


bool QmlUtilsCpp::isPointLeftOfLine(const QVector<QPointF>& points){
    Q_ASSERT(points.size() >= 3);
    QLineF line(points[0],points[1]);
    return isPointLeftOfLine(points[2], line);
}

bool QmlUtilsCpp::isPointLeftOfLineScreen(const QVector<QPointF>& points){
    Q_ASSERT(points.size() >= 3);
    QLineF line(points[0],points[1]);
    return isPointLeftOfLineScreen(points[2], line);
}

bool QmlUtilsCpp::isPointAboveLine(const QVector<QPointF>& points){
    Q_ASSERT(points.size() >= 3);
    QLineF line(points[0],points[1]);
    return isPointAboveLine(points[2], line);
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
// 判断点是否在直线的左侧(屏幕坐标系)
bool QmlUtilsCpp::isPointLeftOfLineScreen(const QPointF& point, const QLineF& line) {
    double x1 = line.p1().x();
    double y1 = line.p1().y();
    double x2 = line.p2().x();
    double y2 = line.p2().y();
    double x3 = point.x();
    double y3 = point.y();
    // y 取反
    double cross = (x2 - x1)*((y1 - y3)) - ((y1 - y2)*(x3 - x1));
    return cross > 0;
}

// 屏幕坐标系
bool QmlUtilsCpp::isPointAboveLine(const QPointF& point, const QLineF& line) {
    double x1 = line.p1().x(), y1 = line.p1().y();
    double x2 = line.p2().x(), y2 = line.p2().y();
    double x = point.x(), y = point.y();

    // 屏幕坐标系：y向下 ，求直线方程
    double y_line = y1 + (y2 - y1) / (x2 - x1) * (x - x1);
    return y < y_line; // 小于直线则在上方
}


// 判断点是否在直线的左侧(数学直角坐标系)
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

