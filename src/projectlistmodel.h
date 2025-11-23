#pragma once
#include "projectdto.h"
#include <QAbstractListModel>
#include <QQmlEngine>

class ProjectListModel : public QAbstractListModel {
    Q_OBJECT
    QML_ELEMENT

    Q_PROPERTY(int pageSize READ pageSize WRITE setPageSize NOTIFY pageSizeChanged)
    Q_PROPERTY(int currentPage READ currentPage WRITE setCurrentPage NOTIFY currentPageChanged)

public:
    struct ProjectItem {
        int id;
        QString projectName;
        QString imageFolder;
        QString resultFolder;
        int annotationType;
        bool outOfTarget;
        bool showOrder;
        int current;
        int total;
        QString createTime;
        QString updateTime;
    };

    enum ItemRoles {
        IDRole = Qt::UserRole + 1,
        ProjectNameRole,
        ImageFolderRole,
        ResultFolderRole,
        AnnotationTypeRole,
        OutOfTargetRole,
        ShowOrderRole,
        CurrentRole,
        TotalRole,
        CreateTimeRole,
        UpdateTimeRole
    };

    explicit ProjectListModel(QObject *parent = nullptr);

    // QAbstractItemModel interface
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    bool setData(const QModelIndex &index, const QVariant &value, int role) override;
    QHash<int, QByteArray> roleNames() const override;

    // 属性访问器
    int pageSize() const { return pageSize_; }
    int currentPage() const { return currentPage_; }
    int totalCount() const { return totalCount_; }
    int totalPages() const { return totalPages_; }

    void setPageSize(int pageSize);
    void setCurrentPage(int currentPage);

public slots:

    Q_INVOKABLE void filterProjectListModel(const QString &projectName = "",
                                            const QString &startTime = "",
                                            const QString &endTime = "",
                                            const QString &orderField = "id",
                                            bool descending = true);

    Q_INVOKABLE int getProjectCount(const QString &projectName = "",
                                    const QString &startTime = "",
                                    const QString &endTime = "");

    Q_INVOKABLE bool addItem(const QString &projectName,
                             const QString &imageFolder = "",
                             const QString &resultFolder = "",
                             int annotationType = 0,bool outOfTarget=false,bool showOrder=false);

    Q_INVOKABLE bool removeItem(int projectID);
    Q_INVOKABLE bool updateItem(int projectId, const QVariantMap &updates);

    // 属性设置辅助方法
    Q_INVOKABLE QVariant getProperty(int index, const QString &property);
    Q_INVOKABLE bool setProperty(int index, const QString &property, const QVariant &value);
    Q_INVOKABLE bool setPropertyById(int projectId, const QString &property, const QVariant &value);
    Q_INVOKABLE int findIndexById(int projectId);

signals:
    void pageSizeChanged();
    void currentPageChanged();
    void loadFinished(bool success, const QString &errorMessage = "");

private:
    ProjectDto *projectDto_;
    QVector<ProjectItem> items_;

    int pageSize_ = 20;
    int currentPage_ = 1;
    int totalCount_ = 0;
    int totalPages_ = 1;

    bool currentDescending_ = false;

};
