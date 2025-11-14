#include "filelistmodel.h"
#include <QDir>
#include <QFile>

FileListModel::FileListModel(QObject *parent) : QAbstractListModel(parent) {}

int FileListModel::rowCount(const QModelIndex &parent) const {
    return parent.isValid() ? 0 : fileInfoList_.size();
}

QVariant FileListModel::data(const QModelIndex &index, int role) const {
    if (!index.isValid() || index.row() >= fileInfoList_.size())
        return QVariant();

    const FileInfoItem &fileInfo = fileInfoList_.at(index.row());
    switch (role) {
    case BaseNameRole:
        return fileInfo.baseName;
    case FileNameRole:
        return fileInfo.fileName;
    case FilePathRole:
        return fileInfo.filePath;
    case IsDirRole:
        return fileInfo.isDir;
    case FileSizeRole:
        return fileInfo.isDir ? 0 : fileInfo.fileSize;
    case FileExtensionRole:
        return fileInfo.fileExtension;
    case IsAnnotatedRole:
        return fileInfo.isAnnotated;
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
        fileInfoList_.clear();
        beginResetModel();
        QStringList filterList = {"*.jpg" ,"*.jpeg" , "*.png" , "*.bmp" , "*.gif"};
        auto fileInfos = dir.entryInfoList(filterList, QDir::AllEntries | QDir::NoDotAndDotDot);
        for(auto &fileInfo: std::as_const(fileInfos)){
            fileInfoList_.append({
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
    QString AnnotationBaseFileName = fileInfoList_[index].baseName + ".json";
    return AnnotationBaseFileName;
}


void FileListModel::setAnnotated(int index, bool annotated){
    if (index < 0 || index >= fileInfoList_.size() || fileInfoList_.at(index).isAnnotated == annotated)
        return;
    fileInfoList_[index].isAnnotated = annotated;
    QModelIndex modelIndex = createIndex(index, 0);
    emit dataChanged(modelIndex, modelIndex, {IsAnnotatedRole});
}

void FileListModel::refresh() {
    setFolderPath(folderPath_);
}

QString FileListModel::getFullPath(int index) const {
    if (index < 0 || index >= fileInfoList_.size())
        return QString();
    return fileInfoList_.at(index).filePath;
}
