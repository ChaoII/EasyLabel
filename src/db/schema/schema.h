//
// Created by aichao on 2025/10/15.
//

#pragma once

#include <string>
#include <sqlite_orm/sqlite_orm.h> //NOLINT
using namespace sqlite_orm;

struct Project {
    int id;
    std::string projectName;
    std::string imageFolder;
    std::string resultFolder;
    int annotationType;
    bool outOfTarget;
    bool showOrder;
    int current;
    int total;
    std::string createTime;
    std::string updateTime;
};
