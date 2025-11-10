#include "src/projectdto.h"

ProjectDto::ProjectDto(QObject* parent)
    : QObject{parent} {
}


size_t ProjectDto::getProjectCount(const QString& projectName, const QString& startTime,
                                   const QString& endTime) {
    try {
        const QString _projectName = projectName.isEmpty() ? "%" : "%" + projectName + "%";
        const QString _startTime = startTime.isEmpty()
                                       ? QDateTime::currentDateTime().addYears(-100)
                                             .toString("yyyy-MM-ddTHH:mm:ss.zzz"): startTime;
        const QString _endTime = startTime.isEmpty()
                                     ? QDateTime::currentDateTime().addYears(100)
                                           .toString("yyyy-MM-ddTHH:mm:ss.zzz"): endTime;
        const auto projects = DBHelper::getStorage().get_all<Project>(
            where(like(&Project::projectName, _projectName.toStdString())
                  and c(&Project::createTime) >= _startTime.toStdString()
                  and c(&Project::createTime) <= _endTime.toStdString()));
        return projects.size();
    }
    catch (const std::exception& e) {
        qDebug() << "get project count failed: " << e.what();
        return 0;
    }
}

bool ProjectDto::insertProject(const QVariantMap& projectMap) {
    try {
        const auto project = mapToProject(projectMap);
        return DBHelper::getStorage().insert(project);
    }
    catch (const std::exception& e) {
        qDebug() << "insert project failed: " << e.what();
        return false;
    }
}

bool ProjectDto::updateProject(const QVariantMap& projectMap) {
    try {
        const auto project = mapToProject(projectMap);
        DBHelper::getStorage().update(project);
        return true;
    }
    catch (const std::exception& e) {
        qDebug() << "update project failed: " << e.what();
        return false;
    }
}

bool ProjectDto::removeProject(const int projectID) {
    try {
        DBHelper::getStorage().remove<Project>(projectID);
        return true;
    }
    catch (const std::exception& e) {
        qDebug() << "remove project failed: " << e.what();
        return false;
    }
}

QVariantList ProjectDto::getProjectList(const QString& projectName, const QString& startTime,
                                        const QString& endTime, int _limit, int _offset,
                                        const QString& _orderField, bool descending) {
    try {
        const auto orderField = _orderField == "projectName"
                                    ? &Project::projectName
                                    : &Project::createTime;
        const auto query = order_by(orderField);
        auto orderedQuery = descending ? query.desc() : query.asc();
        const QString _projectName = projectName.isEmpty() ? "%" : "%" + projectName + "%";
        const QString _startTime = startTime.isEmpty()
                                       ? QDateTime::currentDateTime().addYears(-100).toString("yyyy-MM-ddTHH:mm:ss.zzz")
                                       : startTime;
        const QString _endTime = startTime.isEmpty()
                                     ? QDateTime::currentDateTime().addYears(100).toString("yyyy-MM-ddTHH:mm:ss.zzz")
                                     : endTime;
        const auto projects = DBHelper::getStorage().get_all<Project>(
            where(like(&Project::projectName, _projectName.toStdString())
                  and c(&Project::createTime) >= _startTime.toStdString()
                  and c(&Project::createTime) <= _endTime.toStdString()),
            orderedQuery, limit(_limit, offset(_offset)));
        return projectsToVariantList(projects);
    }
    catch (const std::exception& e) {
        qDebug() << "get project list failed: " << e.what();
        return {};
    }
}

QVariantMap ProjectDto::projectToMap(const Project& project) {
    QVariantMap map;
    map.insert("id", project.id);
    map.insert("projectName", QString::fromStdString(project.projectName));
    map.insert("imageFolder", QString::fromStdString(project.imageFolder));
    map.insert("resultFolder", QString::fromStdString(project.resultFolder));
    map.insert("annotationType", project.annotationType);
    map.insert("outOfTarget", project.outOfTarget);
    map.insert("showOrder", project.showOrder);
    map.insert("current", project.current);
    map.insert("total", project.total);
    map.insert("createTime", QString::fromStdString(project.createTime));
    map.insert("updateTime", QString::fromStdString(project.updateTime));
    return map;
}

Project ProjectDto::mapToProject(const QVariantMap& projectMap) {
    Project project;
    project.id = projectMap.value("id").toInt();
    project.projectName = projectMap.value("projectName").toString().toStdString();
    project.imageFolder = projectMap.value("imageFolder").toString().toStdString();
    project.resultFolder = projectMap.value("resultFolder").toString().toStdString();
    project.annotationType = projectMap.value("annotationType").toInt();
    project.outOfTarget = projectMap.value("outOfTarget").toBool();
    project.showOrder = projectMap.value("showOrder").toBool();
    project.current = projectMap.value("current").toBool();
    project.total = projectMap.value("total").toBool();
    project.createTime = projectMap.value("createTime").toString().toStdString();
    project.updateTime = projectMap.value("updateTime").toString().toStdString();
    return project;
}

QVariantList ProjectDto::projectsToVariantList(const std::vector<Project>& projects) {
    QVariantList list;
    for (const auto& project : projects) {
        list.append(projectToMap(project));
    }
    return list;
}
