/*
 * SPDX-FileCopyrightText: 2020 George Florea Bănuș <georgefb899@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQml 2.12
import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtQuick.Shapes 1.12
import QtQml.Models 2.15
import org.kde.kirigami 2.11 as Kirigami

import org.kde.haruna 1.0

Slider {

    property var chapters
    property bool seekStarted: false

    from: 0
    to: mpv.duration
    enabled: !mpv.isLastStatus


    implicitWidth: 1024 
    implicitHeight: 10 + 30

    leftPadding: 0
    rightPadding: 0

    handle: Rectangle {
        id: handleRect
        visible: true
        x: 
        {
            if(mpv.isLastStatus)
            {
                availableWidth - width
            }else{
                leftPadding + visualPosition
                            * (availableWidth - width)
            }
        }
        y: - height /2 + 4 + 15
        width: 23
        height: 20
        anchors.verticalCenter:parent.verticalCenter
        color: 
        {
            "#FFF6F6F6"
        }
        radius: 6

        Rectangle
        {
            width: parent.width
            height: parent.height - 3
            color: 
            {
                "#FFFFFFFF"
            }
            radius: 6
            anchors.top: parent.top
        }
    } 

    background: Rectangle {
        id: progressBarBackground
        width: availableWidth
        height: 5
        color: "#4DEBEBF5"//整个进度条默认颜色
        radius: 2
        // anchors.top: parent.top
        // anchors.topMargin: 15
        anchors.verticalCenter:parent.verticalCenter

        Rectangle {//已经播放的颜色
            width: visualPosition * parent.width
            height: 5
            radius: 2
            color: "#ff43BDF4"
        }
    }

    onToChanged: value = mpv.duration
    onPressedChanged: {
        if (pressed) {
            seekStarted = true
            mpv.timerStarted = false
        } else {
            mpv.command(["seek", value, "absolute"])
            seekStarted = false
            mpv.timerStarted = true
            mpv.showMouse = false
        }
    }

    Connections {
        target: mpv
        onFileLoaded: 
        {
            chapters = mpv.getProperty("chapter-list")
        }
        onChapterChanged: {
            chaptersMenu.checkedItem = mpv.chapter
        }
        onPositionChanged: {
            if (!seekStarted && !mpv.seekStarted) {
                value = mpv.position
                mpv.horizontalMoveData = mpv.position
            }
        }
    }
}
