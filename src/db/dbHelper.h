//
// Created by aichao on 2025/10/15.
//

#pragma once
#include "src/db/schema/schema.h"

inline auto createStorage() {
    auto storage = make_storage("db.sqlite",
                                make_table("projects",
                                           make_column("id", &Project::id, primary_key().autoincrement()),
                                           make_column("project_name", &Project::projectName),
                                           make_column("image_folder", &Project::imageFolder),
                                           make_column("result_folder", &Project::resultFolder),
                                           make_column("annotation_type", &Project::annotationType),
                                           make_column("out_of_target", &Project::outOfTarget,default_value(false)),
                                           make_column("show_order", &Project::showOrder,default_value(false)),
                                           make_column("current", &Project::current, default_value(0)),
                                           make_column("total", &Project::total, default_value(0)),
                                           make_column("create_time", &Project::createTime),
                                           make_column("update_time", &Project::updateTime)
                                )
    );

    storage.sync_schema();
    return storage;
}

using Storage = decltype(createStorage());

class DBHelper {
public:
    static DBHelper& getInstance() {
        static DBHelper instance;
        return instance;
    }

    static Storage& getStorage() {
        static auto storage = createStorage();
        return storage;
    }

    static bool insertProject(const Project& project);

    static std::vector<Project> queryProjects();

    static std::vector<Project> queryProjectByID(int id);

    static bool updateProject(const Project& project);

private:
    DBHelper();
};
