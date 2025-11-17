#pragma once

#include <QRect>
#include <QColor>
#include <QAbstractListModel>

class DetectionAnnotationModel : public QAbstractListModel
{
    Q_OBJECT
    // Q_PROPERTY(int count READ rowCount NOTIFY countChanged)
    // Q_PROPERTY(int selectedCount READ selectedCount NOTIFY selectedCountChanged)

public:

    struct DetectionAnnotationItem {
        int labelID;
        int x;
        int y;
        int width;
        int height;
        int zOrder;
        bool selected;
    };


    enum DetectionAnnotationRoles {
        LabelIDRole= Qt::UserRole + 1,
        XRole,
        YRole,
        WidthRole,
        HeightRole,
        ZOrderRole,
        SelectedRole
    };

    explicit DetectionAnnotationModel(QObject *parent = nullptr);

    // QAbstractItemModel interface
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    bool setData(const QModelIndex &index, const QVariant &value, int role) override;
    QHash<int, QByteArray> roleNames() const override;

    // 基本属性
    // int selectedCount() const;

    Q_INVOKABLE void addItem(int lableID, int x,int y,int width,int height,int zOrder, bool selected);

    Q_INVOKABLE void updateItem(int index, int lableID, int x,int y,int width,int height, int zOrder, bool selected);

    Q_INVOKABLE void setSelected(int index, bool selected);

    Q_INVOKABLE void removeItem(int index);

    Q_INVOKABLE void clear();

    Q_INVOKABLE QRect getRect(int index);

    Q_INVOKABLE void removeAllSelected();

    Q_INVOKABLE void setSingleSelected(int index);

    Q_INVOKABLE int getSelectedIndex(int x, int y);



    // 标注操作 - 增删改查
    // Q_INVOKABLE int addRectangle(const QRectF& rect, int groupId = 0, const QColor& color = Qt::red, const QString& label = "");
    // Q_INVOKABLE int addPoint(const QPointF& point, int groupId = 0, const QColor& color = Qt::red, const QString& label = "");
    // Q_INVOKABLE int addPolygon(const QVector<QPointF>& polygon, int groupId = 0, const QColor& color = Qt::red, const QString& label = "");
    // Q_INVOKABLE int addText(const QString& text, const QPointF& position, int groupId = 0, const QColor& color = Qt::red, const QString& label = "");

    //     Q_INVOKABLE bool removeAnnotation(int id);
    //     Q_INVOKABLE void clear();
    //     Q_INVOKABLE AnnotationItem* getAnnotation(int id) const;
    //     Q_INVOKABLE int getIndexById(int id) const;

    //     // 选择操作
    //     Q_INVOKABLE void selectAnnotation(int id, bool selected = true);
    //     Q_INVOKABLE void clearSelection();
    //     Q_INVOKABLE void selectAll();
    //     Q_INVOKABLE QList<int> getSelectedIds() const;

    //     // 分组操作
    //     Q_INVOKABLE void setGroupVisible(int groupId, bool visible);
    //     Q_INVOKABLE void setGroupColor(int groupId, const QColor& color);
    //     Q_INVOKABLE void removeGroup(int groupId);
    //     Q_INVOKABLE QList<int> getGroupIds() const;
    //     Q_INVOKABLE QList<AnnotationItem*> getAnnotationsByGroup(int groupId) const;

    //     // 几何更新
    //     Q_INVOKABLE void updateRect(int id, const QRectF& rect);
    //     Q_INVOKABLE void updatePoint(int id, const QPointF& point);
    //     Q_INVOKABLE void updatePolygon(int id, const QVector<QPointF>& polygon);
    //     Q_INVOKABLE void updateText(int id, const QString& text, const QPointF& position);

    //     // 导入导出
    //     Q_INVOKABLE QJsonArray toJsonArray() const;
    //     Q_INVOKABLE bool loadFromJson(const QJsonArray& jsonArray);
    //     Q_INVOKABLE bool saveToFile(const QString& filePath) const;
    //     Q_INVOKABLE bool loadFromFile(const QString& filePath);

    //     // 查找和过滤
    //     Q_INVOKABLE QList<int> findAnnotationsByType(const QString& type) const;
    //     Q_INVOKABLE QList<int> findAnnotationsByLabel(const QString& label) const;
    //     Q_INVOKABLE int findAnnotationAtPoint(const QPointF& point, double tolerance = 5.0) const;

    // signals:
    //     void countChanged();
    //     void selectedCountChanged();
    //     void annotationAdded(int id);
    //     void annotationRemoved(int id);
    //     void annotationChanged(int id);
    //     void selectionChanged();
    //     void groupUpdated(int groupId);

    // private slots:
    //     void onItemDataChanged();

    // private:
    QVector<DetectionAnnotationItem> items_;
    //     QHash<int, int> m_idToIndex;  // ID到索引的映射
    //     int m_nextId;

    //     int generateId();
    //     int addAnnotation(AnnotationItem* item);
    //     void emitDataChanged(int index, const QVector<int>& roles = {});
};

