#include "projectlistmodel.h"

ProjectListModel::ProjectListModel(QObject *parent)
    : QAbstractListModel{parent}, projectDto_(new ProjectDto()) {}

int ProjectListModel::rowCount(const QModelIndex &parent) const {
    if (parent.isValid())
        return 0;
    return items_.size();
}

QVariant ProjectListModel::data(const QModelIndex &index, int role) const {
    if (!index.isValid() || index.row() >= items_.size())
        return QVariant();

    const ProjectItem &projectItem = items_.at(index.row());
    switch (role) {
    case IDROle:
        return projectItem.id;
    case ProjectNameRole:
        return projectItem.projectName;
    case ImageFolderRole:
        return projectItem.imageFolder;
    case ResultFolderRole:
        return projectItem.resultFolder;
    case AnnotationTypeRole:
        return projectItem.annotationType;
    case OutOfTargetRole:
        return projectItem.outOfTarget;
    case ShowOrderRole:
        return projectItem.showOrder;
    case CurrentRole:
        return projectItem.current;
    case TotalRole:
        return projectItem.total;
    case CreateTimeRole:
        return projectItem.createTime;
    case UpdateTimeRole:
        return projectItem.updateTime;
    default:
        return QVariant();
    }
}

bool ProjectListModel::setData(const QModelIndex &index, const QVariant &value,
                               int role) {
    if (!index.isValid() || index.row() < 0 || index.row() >= items_.size())
        return false;

    ProjectItem &item =
        items_[index.row()]; // 注意：这里应该是引用，这样才能修改原数据
    bool changed = false;

    switch (role) {
    case ProjectNameRole:
        if (value.canConvert<QString>() && item.projectName != value.toString()) {
            item.projectName = value.toString();
            changed = true;
            // 同步到数据库
            projectDto_->updateProjectName(item.id, value.toString());
        }
        break;
    case ImageFolderRole:
        if (value.canConvert<QString>() && item.imageFolder != value.toString()) {
            item.imageFolder = value.toString();
            changed = true;
            projectDto_->updateImageFolder(item.id, value.toString());
        }
        break;
    case ResultFolderRole:
        if (value.canConvert<QString>() && item.resultFolder != value.toString()) {
            item.resultFolder = value.toString();
            changed = true;
            projectDto_->updateResultFolder(item.id, value.toString());
        }
        break;
    case AnnotationTypeRole:
        if (value.canConvert<int>() && item.annotationType != value.toInt()) {
            item.annotationType = value.toInt();
            changed = true;
            projectDto_->updateAnnotationType(item.id, value.toInt());
        }
        break;
    case OutOfTargetRole:
        if (value.canConvert<bool>() && item.outOfTarget != value.toBool()) {
            item.outOfTarget = value.toBool();
            changed = true;
            projectDto_->updateOutOfTarget(item.id, value.toBool());
        }
        break;
    case ShowOrderRole:
        if (value.canConvert<bool>() && item.showOrder != value.toBool()) {
            item.showOrder = value.toBool();
            changed = true;
            projectDto_->updateShowOrder(item.id, value.toBool());
        }
        break;
    case CurrentRole:
        if (value.canConvert<int>() && item.current != value.toInt()) {
            item.current = value.toInt();
            changed = true;
            projectDto_->updateCurrent(item.id, value.toInt());
        }
        break;
    case TotalRole:
        if (value.canConvert<int>() && item.total != value.toInt()) {
            item.total = value.toInt();
            changed = true;
            projectDto_->updateTotal(item.id, value.toInt());
        }
        break;
    default:
        return false;
    }

    if (changed) {
        // 更新时间
        item.updateTime =
            QDateTime::currentDateTime().toString("yyyy-MM-dd HH:mm:ss");
        projectDto_->updateUpdateTime(item.id, item.updateTime);

        emit dataChanged(index, index, {role});
        return true;
    }
    return false;
}

QHash<int, QByteArray> ProjectListModel::roleNames() const {
    return {{IDROle, "id"},
            {ProjectNameRole, "projectName"},
            {ImageFolderRole, "imageFolder"},
            {ResultFolderRole, "resultFolder"},
            {AnnotationTypeRole, "annotationType"},
            {OutOfTargetRole, "outOfTarget"},
            {ShowOrderRole, "showOrder"},
            {CurrentRole, "current"},
            {TotalRole, "total"},
            {CreateTimeRole, "createTime"},
            {UpdateTimeRole, "updateTime"}};
}

void ProjectListModel::setPageSize(int pageSize) {
    if (pageSize_ != pageSize && pageSize > 0) {
        pageSize_ = pageSize;
        updatePaginationInfo();
        emit pageSizeChanged();
        refresh(); // 页面大小改变时重新加载
    }
}

void ProjectListModel::setCurrentPage(int currentPage) {
    if (currentPage_ != currentPage && isValidPage(currentPage)) {
        currentPage_ = currentPage;
        emit currentPageChanged();
        refresh(); // 页码改变时重新加载
    }
}

// 分页查询核心函数
void ProjectListModel::filterProjectListModel(const QString &projectName,
                                              const QString &startTime,
                                              const QString &endTime,
                                              const QString &orderField,
                                              bool descending) {
    // 保存过滤条件
    currentProjectName_ = projectName;
    currentStartTime_ = startTime;
    currentEndTime_ = endTime;
    currentOrderField_ = orderField.isEmpty() ? "id" : orderField;
    currentDescending_ = descending;

    // 重新计算分页信息
    totalCount_ = projectDto_->getProjectCount(projectName, startTime, endTime);
    updatePaginationInfo();

    // 加载当前页数据
    const int limit = pageSize_;
    const int offset = pageSize_ * (currentPage_ - 1);
    qDebug() << "projectName: " << projectName;
    qDebug() << "startTime: " << startTime;
    qDebug() << "endTime: " << endTime;
    qDebug() << "limit: " << limit;
    qDebug() << "offset: " << offset;

    auto projects = projectDto_->getProjectList(
        projectName, startTime, endTime, limit, offset, orderField, descending);
    qDebug() << "projects.size(): " << projects.size();

    beginResetModel();
    items_.clear();

    for (const Project &project : projects) {
        ProjectItem item;
        item.id = project.id;
        item.projectName = QString::fromStdString(project.projectName);
        item.imageFolder = QString::fromStdString(project.imageFolder);
        item.resultFolder = QString::fromStdString(project.resultFolder);
        item.annotationType = project.annotationType;
        item.outOfTarget = project.outOfTarget;
        item.showOrder = project.showOrder;
        item.current = project.current;
        item.total = project.total;
        item.createTime = QString::fromStdString(
            project.createTime); // 修复：这里应该是createTime
        item.updateTime = QString::fromStdString(
            project.updateTime); // 修复：这里应该是updateTime
        items_.append(item);
    }
    endResetModel();

    emit loadFinished(true);
}

// 分页导航函数
void ProjectListModel::refresh() {
    filterProjectListModel(currentProjectName_, currentStartTime_,
                           currentEndTime_, currentOrderField_,
                           currentDescending_);
}

void ProjectListModel::loadPage(int page) {
    if (isValidPage(page)) {
        setCurrentPage(page);
    }
}

void ProjectListModel::nextPage() {
    if (currentPage_ < totalPages_) {
        setCurrentPage(currentPage_ + 1);
    }
}

void ProjectListModel::prevPage() {
    if (currentPage_ > 1) {
        setCurrentPage(currentPage_ - 1);
    }
}

void ProjectListModel::firstPage() { setCurrentPage(1); }

void ProjectListModel::lastPage() { setCurrentPage(totalPages_); }

int ProjectListModel::getProjectCount(const QString &projectName,
                                      const QString &startTime,
                                      const QString &endTime) {
    totalCount_ = projectDto_->getProjectCount(projectName, startTime, endTime);
    updatePaginationInfo();
    return totalCount_;
}

bool ProjectListModel::addItem(const QString &projectName,
                               const QString &imageFolder,
                               const QString &resultFolder,
                               int annotationType) {
    // 创建新项目
    Project newProject;
    newProject.projectName = projectName.toStdString();
    newProject.imageFolder = imageFolder.toStdString();
    newProject.resultFolder = resultFolder.toStdString();
    newProject.annotationType = annotationType;

    int newId = projectDto_->addProject(newProject);
    if (newId > 0) {
        // 重新加载数据（可以优化为只插入单条数据）
        refresh();
        return true;
    }
    return false;
}

bool ProjectListModel::removeItem(int projectId) {
    int index = findIndexById(projectId);
    if (index < 0)
        return false;

    if (projectDto_->removeProject(projectId)) {
        beginRemoveRows(QModelIndex(), index, index);
        items_.removeAt(index);
        endRemoveRows();

        // 更新总数
        totalCount_ = projectDto_->getProjectCount(
            currentProjectName_, currentStartTime_, currentEndTime_);
        updatePaginationInfo();

        // 如果当前页没有数据了，且不是第一页，则跳转到上一页
        if (items_.isEmpty() && currentPage_ > 1) {
            setCurrentPage(currentPage_ - 1);
        } else {
            emit totalCountChanged();
        }
        return true;
    }
    return false;
}

bool ProjectListModel::updateItem(int projectId, const QVariantMap &updates) {
    int index = findIndexById(projectId);
    if (index < 0)
        return false;

    QModelIndex modelIndex = createIndex(index, 0);
    bool success = true;

    for (auto it = updates.begin(); it != updates.end(); ++it) {
        if (!setProperty(index, it.key(), it.value())) {
            success = false;
        }
    }
    return success;
}

// 辅助函数实现
bool ProjectListModel::setProperty(int index, const QString &property,
                                   const QVariant &value) {
    if (index < 0 || index >= items_.size())
        return false;

    QModelIndex modelIndex = createIndex(index, 0);
    if (property == "projectName")
        return setData(modelIndex, value, ProjectNameRole);
    if (property == "imageFolder")
        return setData(modelIndex, value, ImageFolderRole);
    if (property == "resultFolder")
        return setData(modelIndex, value, ResultFolderRole);
    if (property == "annotationType")
        return setData(modelIndex, value, AnnotationTypeRole);
    if (property == "outOfTarget")
        return setData(modelIndex, value, OutOfTargetRole);
    if (property == "showOrder")
        return setData(modelIndex, value, ShowOrderRole);
    if (property == "current")
        return setData(modelIndex, value, CurrentRole);
    if (property == "total")
        return setData(modelIndex, value, TotalRole);

    return false;
}

bool ProjectListModel::setPropertyById(int projectId, const QString &property,
                                       const QVariant &value) {
    int index = findIndexById(projectId);
    return setProperty(index, property, value);
}

int ProjectListModel::findIndexById(int projectId) {
    for (int i = 0; i < items_.size(); ++i) {
        if (items_[i].id == projectId) {
            return i;
        }
    }
    return -1;
}

// 私有辅助函数
void ProjectListModel::updatePaginationInfo() {
    totalPages_ = (totalCount_ + pageSize_ - 1) / pageSize_; // 向上取整
    if (totalPages_ < 1)
        totalPages_ = 1;

    // 确保当前页在有效范围内
    if (currentPage_ > totalPages_) {
        currentPage_ = totalPages_;
        emit currentPageChanged();
    }
    emit totalCountChanged();
    emit totalPagesChanged();
}

bool ProjectListModel::isValidPage(int page) const {
    return page >= 1 && page <= totalPages_;
}
