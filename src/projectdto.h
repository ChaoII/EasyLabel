#pragma once

#include <QObject>
#include <QQmlEngine>
#include <db/dbHelper.h>

class ProjectDto : public QObject {
    Q_OBJECT

public:
    explicit ProjectDto(QObject *parent = nullptr);

    // 查询相关
    size_t getProjectCount(const QString &projectName = "",
                           const QString &startTime = "",
                           const QString &endTime = "");

    std::vector<Project>
    getProjectList(const QString &projectName = "", const QString &startTime = "",
                   const QString &endTime = "", int limit = -1, int offset = 0,
                   const QString &orderField = "id", bool descending = true);

    Project getProjectById(int projectId);
    bool existsProjectByName(const QString &projectName);

    // 增删改操作
    int addProject(const Project &project);
    bool updateProject(const Project &project);
    bool removeProject(int projectId);


    // 字段更新操作
    bool updateProjectName(int projectId, const QString &projectName);
    bool updateImageFolder(int projectId, const QString &imageFolder);
    bool updateResultFolder(int projectId, const QString &resultFolder);
    bool updateAnnotationType(int projectId, int annotationType);
    bool updateOutOfTarget(int projectId, bool outOfTarget);
    bool updateShowOrder(int projectId, bool showOrder);
    bool updateCurrent(int projectId, int current);
    bool updateTotal(int projectId, int total);
    bool updateUpdateTime(int projectId, const QString &updateTime);

private:
    QString buildLikePattern(const QString &pattern) const;
    QString getDefaultStartTime() const;
    QString getDefaultEndTime() const;
    std::string getOrderField(const QString &fieldName) const;
};
