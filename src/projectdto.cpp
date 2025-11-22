#include "src/projectdto.h"

ProjectDto::ProjectDto(QObject *parent) : QObject{parent} {}

size_t ProjectDto::getProjectCount(const QString &projectName,
                                   const QString &startTime,
                                   const QString &endTime) {
    try {
        const QString _projectName = buildLikePattern(projectName);
        const QString _startTime =
            startTime.isEmpty() ? getDefaultStartTime() : startTime;
        const QString _endTime =
            startTime.isEmpty() ? getDefaultEndTime() : endTime;
        const auto projects = DBHelper::getStorage().get_all<Project>(
            where(like(&Project::projectName, _projectName.toStdString()) and
                  c(&Project::createTime) >= _startTime.toStdString() and
                  c(&Project::createTime) <= _endTime.toStdString()));
        return projects.size();
    } catch (const std::exception &e) {
        qDebug() << "get project count failed: " << e.what();
        return 0;
    }
}


std::vector<Project> ProjectDto::getProjectList(const QString &projectName,
                                                const QString &startTime,
                                                const QString &endTime,
                                                int _limit, int _offset,
                                                const QString &_orderField,
                                                bool descending) {
    try {
        const auto orderField = _orderField == "projectName" ? &Project::projectName
                                                             : &Project::createTime;
        const auto query = order_by(orderField);
        auto orderedQuery = descending ? query.desc() : query.asc();
        const QString _projectName = buildLikePattern(projectName);
        const QString _startTime =
            startTime.isEmpty() ? getDefaultStartTime() : startTime;
        const QString _endTime =
            startTime.isEmpty() ? getDefaultEndTime() : endTime;
        const auto projects = DBHelper::getStorage().get_all<Project>(
            where(like(&Project::projectName, _projectName.toStdString()) and
                  c(&Project::createTime) >= _startTime.toStdString() and
                  c(&Project::createTime) <= _endTime.toStdString()),
            orderedQuery, limit(_limit, offset(_offset)));
        return projects;
    } catch (const std::exception &e) {
        qDebug() << "get project list failed: " << e.what();
        return {};
    }
}


Project ProjectDto::getProjectById(int projectId) {
    try {
        auto project = DBHelper::getStorage().get<Project>(projectId);
        return project;
    } catch (const std::exception &e) {
        qDebug() << "Get project by ID failed:" << e.what();
        return {};
    }
}

bool ProjectDto::existsProjectByName(const QString &projectName) {
    try {
        auto projects = DBHelper::getStorage().get_all<Project>(
            where(c(&Project::projectName) == projectName.toStdString()));
        return !projects.empty();
    } catch (const std::exception &e) {
        qDebug() << "Check project exists failed:" << e.what();
        return false;
    }
}

int ProjectDto::addProject(const Project &project) {
    try {
        Project _project = project;
        QString currentTime =
            QDateTime::currentDateTime().toString("yyyy-MM-ddTHH:mm:ss.zzz");
        _project.createTime = currentTime.toStdString();
        _project.updateTime = currentTime.toStdString();
        return DBHelper::getStorage().insert(_project);
    } catch (const std::exception &e) {
        qDebug() << "Add project failed:" << e.what();
        return -1;
    }
}

bool ProjectDto::updateProject(const Project &project) {
    try {
        Project _project = project;
        // 更新修改时间
        _project.updateTime = QDateTime::currentDateTime()
                                  .toString("yyyy-MM-ddTHH:mm:ss.zzz")
                                  .toStdString();
        DBHelper::getStorage().update(_project);
        return true;
    } catch (const std::exception &e) {
        qDebug() << "Update project failed:" << e.what();
        return false;
    }
}

bool ProjectDto::removeProject(int projectId) {
    try {
        DBHelper::getStorage().remove<Project>(projectId);
        return true;
    } catch (const std::exception &e) {
        qDebug() << "Remove project failed:" << e.what();
        return false;
    }
}

// 字段更新方法
bool ProjectDto::updateProjectName(int projectId, const QString &projectName) {
    try {
        DBHelper::getStorage().update_all(
            set(c(&Project::projectName) = projectName.toStdString(),
                c(&Project::updateTime)=QDateTime::currentDateTime()
                                              .toString("yyyy-MM-ddTHH:mm:ss.zzz")
                                              .toStdString()),
            where(c(&Project::id) == projectId));
        return true;
    } catch (const std::exception &e) {
        qDebug() << "Update project name failed:" << e.what();
        return false;
    }
}

bool ProjectDto::updateImageFolder(int projectId, const QString &imageFolder) {
    try {
        DBHelper::getStorage().update_all(
            set(c(&Project::imageFolder)=imageFolder.toStdString(),
                c(&Project::updateTime)=QDateTime::currentDateTime()
                                              .toString("yyyy-MM-ddTHH:mm:ss.zzz")
                                              .toStdString()),
            where(c(&Project::id) == projectId));
        return true;
    } catch (const std::exception &e) {
        qDebug() << "Update image folder failed:" << e.what();
        return false;
    }
}

bool ProjectDto::updateResultFolder(int projectId,
                                    const QString &resultFolder) {
    // 类似上面的实现
    try {
        DBHelper::getStorage().update_all(
            set(c(&Project::resultFolder)= resultFolder.toStdString(),
                c(&Project::updateTime)=
                QDateTime::currentDateTime()
                    .toString("yyyy-MM-ddTHH:mm:ss.zzz")
                    .toStdString()),
            where(c(&Project::id) == projectId));
        return true;
    } catch (const std::exception &e) {
        qDebug() << "Update result folder failed:" << e.what();
        return false;
    }
}

bool ProjectDto::updateAnnotationType(int projectId, int annotationType) {
    try {
        DBHelper::getStorage().update_all(
            set(c(&Project::annotationType)= annotationType, c(&Project::updateTime)=
                                                              QDateTime::currentDateTime()
                                                                  .toString("yyyy-MM-ddTHH:mm:ss.zzz")
                                                                  .toStdString()),
            where(c(&Project::id) == projectId));
        return true;
    } catch (const std::exception &e) {
        qDebug() << "Update annotation type failed:" << e.what();
        return false;
    }
}

bool ProjectDto::updateOutOfTarget(int projectId, bool outOfTarget) {
    try {
        DBHelper::getStorage().update_all(
            set(c(&Project::outOfTarget)= outOfTarget, c(&Project::updateTime)=
                                                        QDateTime::currentDateTime()
                                                            .toString("yyyy-MM-ddTHH:mm:ss.zzz")
                                                            .toStdString()),
            where(c(&Project::id) == projectId));
        return true;
    } catch (const std::exception &e) {
        qDebug() << "Update out of target failed:" << e.what();
        return false;
    }
}

bool ProjectDto::updateShowOrder(int projectId, bool showOrder) {
    try {
        DBHelper::getStorage().update_all(
            set(c(&Project::showOrder)=showOrder, c(&Project::updateTime)=
                                                    QDateTime::currentDateTime()
                                                        .toString("yyyy-MM-ddTHH:mm:ss.zzz")
                                                        .toStdString()),
            where(c(&Project::id) == projectId));
        return true;
    } catch (const std::exception &e) {
        qDebug() << "Update show order failed:" << e.what();
        return false;
    }
}

bool ProjectDto::updateCurrent(int projectId, int current) {
    try {
        DBHelper::getStorage().update_all(
            set(c(&Project::current)= current, c(&Project::updateTime)=
                                                QDateTime::currentDateTime()
                                                    .toString("yyyy-MM-ddTHH:mm:ss.zzz")
                                                    .toStdString()),
            where(c(&Project::id) == projectId));
        return true;
    } catch (const std::exception &e) {
        qDebug() << "Update current failed:" << e.what();
        return false;
    }
}

bool ProjectDto::updateTotal(int projectId, int total) {
    try {
        DBHelper::getStorage().update_all(
            set(c(&Project::total)= total, c(&Project::updateTime)=
                                            QDateTime::currentDateTime()
                                                .toString("yyyy-MM-ddTHH:mm:ss.zzz")
                                                .toStdString()),
            where(c(&Project::id) == projectId));
        return true;
    } catch (const std::exception &e) {
        qDebug() << "Update total failed:" << e.what();
        return false;
    }
}

bool ProjectDto::updateUpdateTime(int projectId, const QString &updateTime) {
    try {
        DBHelper::getStorage().update_all(
            set(c(&Project::updateTime)= updateTime.toStdString()),
            where(c(&Project::id) == projectId));
        return true;
    } catch (const std::exception &e) {
        qDebug() << "Update update time failed:" << e.what();
        return false;
    }
}

// 私有辅助方法
QString ProjectDto::buildLikePattern(const QString &pattern) const {
    return pattern.isEmpty() ? "%" : "%" + pattern + "%";
}

QString ProjectDto::getDefaultStartTime() const {
    return QDateTime::currentDateTime().addYears(-100).toString(
        "yyyy-MM-ddTHH:mm:ss.zzz");
}

QString ProjectDto::getDefaultEndTime() const {
    return QDateTime::currentDateTime().addYears(100).toString(
        "yyyy-MM-ddTHH:mm:ss.zzz");
}
