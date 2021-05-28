/*
 * SPDX-FileCopyrightText: 2020 George Florea Bănuș <georgefb899@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Window 2.12
import QtQuick.Layouts 1.12
import QtGraphicalEffects 1.12
import Qt.labs.platform 1.0 as Platform

import org.kde.kirigami 2.15 as Kirigami
import org.kde.haruna 1.0

import mpv 1.0
import "Menus"
import "Settings"

Kirigami.ApplicationWindow {
    id: window

    property var configure: app.action("configure")

    property int  deviceWidth: 1920
    property int deviceHeight: 1200

    property real officalScale: /*deviceWidth / officalWidth*/0.5

    visible: true
    title: mpv.mediaTitle || qsTr("Haruna")
    width: deviceWidth
    minimumWidth: 640
    height: deviceHeight
    minimumHeight: 400
    color: Kirigami.Theme.backgroundColor

    onVisibilityChanged: {
        if(window.visibility == 0)
        {
            mpv.setProperty("pause", true)
        }else
        {
            window.showFullScreen() 
        }
    }

    onActiveChanged://是否需要切换到后台以后暂停
    {
        if(!Qt.application.active)
        {
            mpv.setProperty("pause", true)
        }
    }


    property Action playPauseAction: Action {//监听空格
        id: playPauseAction
        text: qsTr("Play/Pause")
        icon.name: "media-playback-pause"
        shortcut: "Space"

        onTriggered:
        {
            mpv.setProperty("pause", !mpv.getProperty("pause"))
        }
    }

    MpvVideo {
        id: mpv
        Osd { id: osd }
    }

    PlayList { id: playList }

    Header//顶部的视频名称
    {
        id: header
        width: parent.width
        height: 80
        visible: true

        // background: Rectangle {
        //     anchors.fill: parent
        //     color: "transparent"
        //     LinearGradient {            ///--[Mark]
        //         anchors.fill: parent
        //         start: Qt.point(0, 0)
        //         gradient: Gradient {
        //             GradientStop {  position: 0.0;    color: "#a0000000" }
        //             GradientStop {  position: 1.0;    color: "#00000000" }
        //         }
        //     }
        // }
    }

    Footer {//底部的bar
        id: footer
        height: 80
    }


    function openFile(path, startPlayback, loadSiblings) {
        mpv.command(["loadfile", path])
        mpv.setProperty("pause", !startPlayback)

        var pathStr = path.toString();
        var index = pathStr.lastIndexOf("/")
        header.currentname = pathStr.substring(index + 1)
        mpv.setProperty("currentname", pathStr.substring(index + 1))

        GeneralSettings.lastPlayedFile = path
    }
}
