#pragma once

#include <QObject>
#include <QQmlEngine>
#include <db/dbHelper.h>

class ProjectDto : public QObject {
    Q_OBJECT
    QML_ELEMENT

public:
    explicit ProjectDto(QObject* parent = nullptr);

    Q_INVOKABLE static QVariantList getProjectList(const QString& projectName, const QString& startTime,
                                                   const QString& endTime, int _limit, int _offset,
                                                   const QString& _orderField, bool descending = true);

    Q_INVOKABLE static size_t getProjectCount(const QString& projectName, const QString& startTime,
                                              const QString& endTime);

    Q_INVOKABLE static bool insertProject(const QVariantMap& projectMap);

    Q_INVOKABLE static bool updateProject(const QVariantMap& projectMap);

    Q_INVOKABLE static bool removeProject(int projectID);

private:
    static QVariantMap projectToMap(const Project& project);

    static Project mapToProject(const QVariantMap& projectMap);

    static QVariantList projectsToVariantList(const std::vector<Project>& projects);
};
