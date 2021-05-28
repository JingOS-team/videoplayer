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
    property int preFullScreenVisibility
    property int officalWidth : 1920
    property int officalHeight: 1200

    property int  deviceWidth: 1920
    property int deviceHeight: 1200

    property real officalScale: /*deviceWidth / officalWidth*/0.8

    visible: true
    title: mpv.mediaTitle || qsTr("Haruna")
    width: deviceWidth
    minimumWidth: 640
    height: deviceHeight
    minimumHeight: 400
    color: Kirigami.Theme.backgroundColor

    onVisibilityChanged: {
        if (!window.isFullScreen()) {
            preFullScreenVisibility = visibility
        }
        window.showFullScreen()
    }

    onActiveChanged://是否需要切换到后台以后暂停
    {
        if(!Qt.application.active)
        {
            mpv.setProperty("pause", true)
        }
    }

//    header: Header { id: header }

//    menuBar: MenuBar {

//        hoverEnabled: true
//        implicitHeight: 24
////        visible: !window.isFullScreen() && GeneralSettings.showMenuBar
//        visible: false
//        background: Rectangle {
//            color: Kirigami.Theme.backgroundColor
//        }

//        FileMenu {}
//        ViewMenu {}
//        PlaybackMenu {}
//        SubtitlesMenu {}
//        AudioMenu {}
//        SettingsMenu {}
//    }

    // mark left bottom menu widget by J
    Menu {
        id: mpvContextMenu
        modal: true

        FileMenu {}
        ViewMenu {}
        PlaybackMenu {}
        SubtitlesMenu {}
        AudioMenu {}
        SettingsMenu {}
    }

    Actions { id: actions }

    SystemPalette { id: systemPalette; colorGroup: SystemPalette.Active }

    SettingsEditor { id: settingsEditor }

    MpvVideo {
        id: mpv
        Osd { id: osd }
    }

    // remove by J
    PlayList { id: playList }

    Header//顶部的视频名称
    {
        id: header
        width: parent.width
        height: officalScale * 160
        visible: true
        background:Rectangle
        {
            color:"#00000000"
        }
    }

    Footer {//底部的bar
        id: footer
        height: officalScale * 160
    }

    Component.onCompleted: 
    {
        // app.activateColorScheme(GeneralSettings.colorScheme)
    }

    function openFile(path, startPlayback, loadSiblings) {
        // console.log("video openFile path == " + path)

        // mpv.setProperty("ytdl-format", PlaybackSettings.ytdlFormat)


        mpv.command(["loadfile", path])
        mpv.setProperty("pause", !startPlayback)


        // var pathStr = path.toString();
        // var index = pathStr.lastIndexOf("/")
        // header.currentname = pathStr.substring(index + 1)
        // mpv.setProperty("currentname", pathStr.substring(index + 1))

        // console.log("video openFile name == " + pathStr.substring(index + 1))
        
        // if (loadSiblings) {
            // get video files from same folder as the opened file
            // playListModel.getVideos(path)
        // }

        GeneralSettings.lastPlayedFile = path
    }

    function isFullScreen() {
//        return window.visibility === Window.FullScreen
        return true
    }

}
