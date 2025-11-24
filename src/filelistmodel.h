#pragma once

#include <QAbstractListModel>
#include <QFileInfoList>
#include <QQmlEngine>
class FileListModel : public QAbstractListModel
{
    Q_OBJECT
    QML_ELEMENT
    Q_PROPERTY(QString folderPath READ folderPath WRITE setFolderPath NOTIFY folderPathChanged)

public:

    struct FileInfoItem
    {
        QString baseName;
        QString fileName;
        QString filePath;
        bool isDir;
        int64_t fileSize;
        QString fileExtension;
        bool isAnnotated;
    };

    enum Roles {
        BaseNameRole = Qt::UserRole + 1,
        FileNameRole,
        FilePathRole,
        IsDirRole,
        FileSizeRole,
        FileExtensionRole,
        IsAnnotatedRole
    };

    explicit FileListModel(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    QString folderPath() const;
    void setFolderPath(const QString &path);

    Q_INVOKABLE QString getResultFilePath(int index);
    Q_INVOKABLE void setAnnotated(int index, bool annotated);
    Q_INVOKABLE void refresh();
    Q_INVOKABLE QString getFullPath(int index) const;
    Q_INVOKABLE int getAnnotatedNum() const ;


signals:
    void folderPathChanged();

private:
    QString folderPath_ ;
    QVector<FileInfoItem> items_;
};
