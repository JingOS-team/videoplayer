/*
 * SPDX-FileCopyrightText: 2021 Wang Rui <wangrui@jingos.com>
 * SPDX-License-Identifier: LGPL-2.1-or-later
 */

#ifndef __HARUHA_PLAYER__
#define __HARUHA_PLAYER__

#include <QQmlApplicationEngine>
#include "playlist/playlistmodel.h"
class Player : public QObject
{
    Q_OBJECT
public:
    Player(const QQmlApplicationEngine &engine, PlayListModel &playListModel);

    void setDate(int &argc, char **argv);

public slots:
    Q_SCRIPTABLE void playVideo(QString path);
    void start();

private:
    const QQmlApplicationEngine &m_engine;
    PlayListModel &m_playListModel;
    int m_argc;
    char **m_argv;

};
#endif