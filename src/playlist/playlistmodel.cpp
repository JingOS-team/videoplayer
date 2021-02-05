/*
 * SPDX-FileCopyrightText: 2020 George Florea Bănuș <georgefb899@gmail.com>
 * SPDX-FileCopyrightText: 2021 Wang Rui <wangrui@jingos.com>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#include "playlistmodel.h"
#include "playlistitem.h"
#include "_debug.h"
#include "worker.h"

#include <QCollator>
#include <QDirIterator>
#include <QFileInfo>
#include <QMimeDatabase>
#include <QUrl>

#include <QDBusConnection>
#include <QDBusReply>
#include <QDBusInterface>

PlayListModel::PlayListModel(QObject *parent)
    : QAbstractListModel(parent)
{
    connect(this, &PlayListModel::videoAdded,
            Worker::instance(), &Worker::getVideoDuration);
    connect(Worker::instance(), &Worker::videoDuration, this, [ = ](int i, const QString &d) {
        m_playList[i]->setDuration(d);
        dataChanged(index(i, 0), index(i, 0));
    });
}

int PlayListModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid())
        return 0;

    return m_playList.size();
}

QVariant PlayListModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || m_playList.empty())
        return QVariant();

    auto playListItem = m_playList.at(index.row()).get();
    switch (role) {
    case DisplayRole:
        return QVariant(playListItem->fileName());
    case PathRole:
        return QVariant(playListItem->filePath());
    case DurationRole:
        return QVariant(playListItem->duration());
    case PlayingRole:
        return QVariant(playListItem->isPlaying());
    case FolderPathRole:
        return QVariant(playListItem->folderPath());
    }

    return QVariant();
}

QHash<int, QByteArray> PlayListModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[DisplayRole] = "name";
    roles[PathRole] = "path";
    roles[FolderPathRole] = "folderPath";
    roles[DurationRole] = "duration";
    roles[PlayingRole] = "isPlaying";
    return roles;
}

void PlayListModel::getVideos(QStringList videoFiles)
{
    beginResetModel();
    m_playList.clear();
    endResetModel();
    m_playingVideo = -1;

    beginInsertRows(QModelIndex(), 0, videoFiles.count() - 1);
    for (int i = 0; i < videoFiles.count(); ++i) {
        QFileInfo fileInfo(videoFiles.at(i));
        auto video = std::make_shared<PlayListItem>();
        video->setFileName(fileInfo.fileName());
        video->setIndex(i);
        video->setFilePath(fileInfo.absoluteFilePath());
        video->setFolderPath(fileInfo.absolutePath());
        video->setIsPlaying(false);
        m_playList.emplace(i, video);
        emit videoAdded(i, video->filePath());
    }
    endInsertRows();
}

Playlist PlayListModel::items() const
{
    return m_playList;
}

int PlayListModel::getPlayingVideo() const
{
    return m_playingVideo;
}

int PlayListModel::getPlaylistSize() const
{
    return m_playList.size();
}

QString PlayListModel::getPath(int i)
{
    return m_playList[i]->filePath();
}


#define SERVICE_NAME            "org.kde.media.jingos.media"
void PlayListModel::setPlayingVideo(int playingVideo)
{
    if (m_playingVideo != -1) 
    {
        m_playList[m_playingVideo]->setIsPlaying(false);
        emit dataChanged(index(m_playingVideo, 0), index(m_playingVideo, 0));
        m_playList[playingVideo]->setIsPlaying(true);
        emit dataChanged(index(playingVideo, 0), index(playingVideo, 0));
    } else 
    {
        m_playList[playingVideo]->setIsPlaying(true);
    }
    m_playingVideo = playingVideo;
    emit playingVideoChanged();

    if (type != 1) 
    {
        return;
    }

    if (!QDBusConnection::sessionBus().isConnected()) 
    {
        return;
    }

    QDBusInterface iface(SERVICE_NAME, "/services/jingos_dbus/jingosdbus", "", QDBusConnection::sessionBus());
    if (iface.isValid()) 
    {
        QDBusReply<QString> reply = iface.call("updateLately", playingVideo);
        if (reply.isValid()) 
        {
            return;
        }
    }
}
