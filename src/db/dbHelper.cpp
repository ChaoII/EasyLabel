//
// Created by aichao on 2025/10/15.
//

#include "src/db/dbHelper.h"
#include <QDebug>


DBHelper::DBHelper() {
    getStorage().sync_schema();
}

bool DBHelper::insertProject(const Project& project) {
    try {
        getStorage().insert(project);
        getStorage().sync_schema();
        return true;
    }
    catch (const std::exception& e) {
        qDebug() << "insert project failed: " << e.what();
        return false;
    }
}

std::vector<Project> DBHelper::queryProjects() {
    try {
        return getStorage().get_all<Project>();;
    }
    catch (const std::exception& e) {
        qDebug() << "query project failed: " << e.what();
        return {};
    }
}

std::vector<Project> DBHelper::queryProjectByID(const int id) {
    try {
        auto projects = getStorage().get_all<Project>(where(c(&Project::id) == id));
        return projects;
    }
    catch (const std::exception& e) {
        qDebug() << "query project failed, id is: " << id << "error :" << e.what();
        return {};
    }
}

bool DBHelper::updateProject(const Project& project) {
    try {
        getStorage().update(project);
        return true;
    }
    catch (const std::exception& e) {
        qDebug() << "update project failed: " << e.what();
        return false;
    }
}

