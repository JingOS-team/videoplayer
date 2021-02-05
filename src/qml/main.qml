/*
 * SPDX-FileCopyrightText: 2020 George Florea Bănuș <georgefb899@gmail.com>
 * SPDX-FileCopyrightText: 2021 Wang Rui <wangrui@jingos.com>
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
    property real officalScale: 0.8

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

    onActiveChanged:
    {
        if(!Qt.application.active)
        {
            mpv.setProperty("pause", true)
        }
    }


    property Action playPauseAction: Action {
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

    Header
    {
        id: header
        width: parent.width
        height: officalScale * 160
        visible: true

        background: Rectangle {
            anchors.fill: parent
            color: "transparent"
            LinearGradient {            
                anchors.fill: parent
                start: Qt.point(0, 0)
                gradient: Gradient {
                    GradientStop {  position: 0.0;    color: "#a0000000" }
                    GradientStop {  position: 1.0;    color: "#00000000" }
                }
            }
        }
    }

    Footer {
        id: footer
        height: officalScale * 160
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
