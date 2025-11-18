#include "filelistmodel.h"
#include <QDir>
#include <QFile>

FileListModel::FileListModel(QObject *parent) : QAbstractListModel(parent) {}

int FileListModel::rowCount(const QModelIndex &parent) const {
    return parent.isValid() ? 0 : items_.size();
}

QVariant FileListModel::data(const QModelIndex &index, int role) const {
    if (!index.isValid() || index.row() >= items_.size())
        return QVariant();

    const FileInfoItem &item = items_.at(index.row());
    switch (role) {
    case BaseNameRole:
        return item.baseName;
    case FileNameRole:
        return item.fileName;
    case FilePathRole:
        return item.filePath;
    case IsDirRole:
        return item.isDir;
    case FileSizeRole:
        return item.isDir ? 0 : item.fileSize;
    case FileExtensionRole:
        return item.fileExtension;
    case IsAnnotatedRole:
        return item.isAnnotated;
    default:
        return QVariant();
    }
}

QHash<int, QByteArray> FileListModel::roleNames() const {
    QHash<int, QByteArray> roles;
    roles[BaseNameRole]= "baseName";
    roles[FileNameRole]= "fileName";
    roles[FilePathRole]= "filePath";
    roles[IsDirRole]= "isDir";
    roles[FileSizeRole]= "fileSize";
    roles[FileExtensionRole]= "fileExtension";
    roles[IsAnnotatedRole]= "isAnnotation";
    return roles;
}

QString FileListModel::folderPath() const {
    return folderPath_;
}

void FileListModel::setFolderPath(const QString &path) {
    if (folderPath_ == path)
        return;
    folderPath_ = path;
    QDir dir(path);
    if (dir.exists()) {
        items_.clear();
        beginResetModel();
        QStringList filterList = {"*.jpg" ,"*.jpeg" , "*.png" , "*.bmp" , "*.gif"};
        auto fileInfos = dir.entryInfoList(filterList, QDir::AllEntries | QDir::NoDotAndDotDot);
        for(auto &fileInfo: std::as_const(fileInfos)){
            items_.append({
                fileInfo.baseName(),
                fileInfo.fileName(),
                fileInfo.filePath(),
                fileInfo.isDir(),
                fileInfo.size(),
                fileInfo.suffix(),
                false
            });
        }
        endResetModel();
    }
    emit folderPathChanged();
}


QString FileListModel::getResultFilePath(int index){
    if (index < 0 || index >= items_.size())
        return "";
    QString AnnotationBaseFileName = items_[index].baseName + ".json";
    return AnnotationBaseFileName;
}


void FileListModel::setAnnotated(int index, bool annotated){
    if (index < 0 || index >= items_.size() || items_.at(index).isAnnotated == annotated)
        return;
    items_[index].isAnnotated = annotated;
    QModelIndex modelIndex = createIndex(index, 0);
    emit dataChanged(modelIndex, modelIndex, {IsAnnotatedRole});
}

void FileListModel::refresh() {
    setFolderPath(folderPath_);
}

QString FileListModel::getFullPath(int index) const {
    if (index < 0 || index >= items_.size())
        return QString();
    return items_.at(index).filePath;
}


