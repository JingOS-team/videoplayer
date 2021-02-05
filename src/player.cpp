/*
 * SPDX-FileCopyrightText: 2021 Wang Rui <wangrui@jingos.com>
 * SPDX-License-Identifier: LGPL-2.1-or-later
 */

#include <QObject>
#include "player.h"
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QCoreApplication>
#include <KWindowSystem>
#include <KWindowInfo>
#include "playlist/playlistmodel.h"

Player::Player(const QQmlApplicationEngine &engine, PlayListModel &playListModel)
    : m_engine(engine), m_playListModel(playListModel)
{

}
void Player::playVideo(QString path) 
{
}

void Player::setDate(int &argc, char **argv)
{
    m_argc = argc;
    m_argv = argv;
}

void Player::start()
{
    if (m_argc == 2)
    {
        m_playListModel.type = 0;
        QStringList videoFiles;
        videoFiles.append(QString(m_argv[1]));
        m_playListModel.getVideos(videoFiles);
        m_playListModel.setPlayingVideo(0);

    } else if (m_argc > 3)
    {
        m_playListModel.type = QString(m_argv[1]).toInt();

        QStringList videoFiles;

        if (m_playListModel.type == 0) //从photo中过来的参数 按照之前的协议 带着file//没有处理 我们这里处理下 不用photo再改了
        {
            videoFiles.append(QString(m_argv[3]).mid(7));
        } else
        {
            for (int i = 3; i < m_argc; i++)
            {
                videoFiles.append(m_argv[i]);
            }
        }
        m_playListModel.getVideos(videoFiles);

        int playIndex = QString(m_argv[2]).toInt();
        m_playListModel.setPlayingVideo(playIndex);
    }
}