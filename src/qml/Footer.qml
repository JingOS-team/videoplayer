/*
 * SPDX-FileCopyrightText: 2020 George Florea Bănuș <georgefb899@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtGraphicalEffects 1.12
import org.kde.haruna 1.0
import org.kde.kirigami 2.15 as Kirigami

ToolBar {
    property alias progressBar: progressBar
    property alias footerRow: footerRow
    property alias timeInfo: timeInfo
    // property alias volume: volume

    property bool unableClickPrew: 
    {
        if(playListModel.getPlaylistSize() == 0)
        {
            true
        }else if(playListModel.getPlaylistSize() > 0)
        {
            if(playListModel.getPlayingVideo() == 0)
            {
                true
            }else
            {
                false
            }
        }
    }
    property bool unableClickNext: 
    {
        if(playListModel.getPlaylistSize() == 0)
        {
            true
        }else if(playListModel.getPlaylistSize() > 0)
        {
            if(playListModel.getPlayingVideo() == playListModel.getPlaylistSize() - 1)
            {
                true
            }else
            {
                false
            }
        }
    }

    Connections {
        target: playListModel
        onPlayingVideoChanged: {
            if(playListModel.getPlaylistSize() == 1)
            {
                unableClickPrew = true
                unableClickNext = true
            }else
            if(playListModel.getPlayingVideo() == 0)//当前播放的是第一个
            {
                unableClickPrew = true
                unableClickNext = false
            }else if(playListModel.getPlayingVideo() == playListModel.getPlaylistSize() - 1)//当前播放的是最后一个
            {
                unableClickPrew = false
                unableClickNext = true
            }else
            {
                unableClickPrew = false
                unableClickNext = false
            }
        }
    }

    y: mpv.height
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.bottom: mpv.bottom
    position: ToolBar.Footer
    hoverEnabled: true
    visible: true

    background: Rectangle {
        anchors.fill: parent

        color: "transparent"
        LinearGradient {            ///--[Mark]
             anchors.fill: parent
             start: Qt.point(0, 0)
             gradient: Gradient {
                 GradientStop {  position: 0.0;    color: "#00000000" }
                 GradientStop {  position: 1.0;    color: "#a0000000" }
             }
        }
    }

    RowLayout {
        id: footerRow
        anchors.fill: parent

        Kirigami.JIconButton {
            width: 30 + 10
            height: width
            source: mpv.pause ? "qrc:/image/audio_play.png" : "qrc:/image/audio_pause.png"
            Layout.alignment: Qt.AlignVCenter |Qt.AlignLeft
            Layout.leftMargin: 35

                onClicked: {
                    mpv.setProperty("pause", !mpv.getProperty("pause"))
                }
        }

        Kirigami.JIconButton {//上一个
            width: 22 + 10
            height: width
            hoverEnabled: !unableClickPrew
            source: 
            {
                if(unableClickPrew)
                {
                    "qrc:/image/audio_prew_unableclick.png"
                }else
                {
                    "qrc:/image/audio_prew.png"
                }
            }
            Layout.leftMargin: 35
            Layout.alignment: Qt.AlignVCenter
                onClicked: {

                    if(unableClickPrew)
                    {
                        return
                    }

                    const previousIndex = playListModel.getPlayingVideo() - 1
                    const previousFile = playListModel.getPath(previousIndex)
                    window.openFile(previousFile, true, false)
                    playListModel.setPlayingVideo(previousIndex)
                    mpv.isLastStatus = false
                }
        }

        Kirigami.JIconButton {//下一个
            width: 22 + 10
            height: width
            hoverEnabled: !unableClickNext
            Layout.leftMargin: 35
            source:
            {
                if(unableClickNext)
                {
                    "qrc:/image/audio_next_unableclick.png"
                }else
                {
                    "qrc:/image/audio_next.png"
                }
            }
            Layout.alignment: Qt.AlignVCenter

                onClicked: {
                    if(unableClickNext)
                    {
                        return
                    }
                    const nextPlayIndex = playListModel.getPlayingVideo() + 1
                    const nextFile = playListModel.getPath(nextPlayIndex)
                    window.openFile(nextFile, true, false)
                    playListModel.setPlayingVideo(nextPlayIndex)
                }
        }

        Label {
            id: postionstimeInfo

            text: positionTimeInfoTextMetrics.text
            font.pointSize: positionTimeInfoTextMetrics.font.pointSize
            horizontalAlignment: Qt.AlignHCenter
            Layout.leftMargin: 45
            Layout.preferredWidth: 86 * window.officalScale
            color: "#fff"

            TextMetrics {
                id: positionTimeInfoTextMetrics

                text: app.formatTime(mpv.position)
                font.pixelSize: 11
            }
        }

        HProgressBar {
            id: progressBar
            Layout.alignment: Qt.AlignVCenter
            Layout.leftMargin: 13
            Layout.rightMargin: 13
            Layout.fillWidth: true
        }

        Label {//时长
            id: timeInfo
            color: "#fff"
            text: timeInfoTextMetrics.text
            font.pointSize: timeInfoTextMetrics.font.pointSize
            horizontalAlignment: Qt.AlignHCenter
            Layout.leftMargin: 10
            Layout.preferredWidth: 86 * window.officalScale

            TextMetrics {
                id: timeInfoTextMetrics

                text: app.formatTime(mpv.duration)
                // font.pointSize: 22 * window.officalScale
                font.pixelSize: 11
            }

            ToolTip {
                text: qsTr("Remaining: ") + app.formatTime(mpv.remaining)
                visible: timeInfoMouseArea.containsMouse
                timeout: -1
            }

            MouseArea {
                id: timeInfoMouseArea
                anchors.fill: parent
                hoverEnabled: false
            }
        }

        ToolButton {
            id: mute
            action: actions.muteAction
            text: ""
            focusPolicy: Qt.NoFocus
            visible: false

            ToolTip {
                text: actions.muteAction.text
            }
        }

        Image {
            visible: false
            width: window.officalScale * 20
            height: width
            sourceSize.width: width
            sourceSize.height: height
            source: "qrc:/image/audio_like.png"
            anchors.verticalCenter : parent.verticalCenter
            Layout.leftMargin: 70
            MouseArea{
                anchors.fill: parent
                onClicked: {
                                    if (mpvContextMenu.visible) {
                                        return
                                    }

                                    mpvContextMenu.visible = !mpvContextMenu.visible
                                    const menuHeight = mpvContextMenu.count * mpvContextMenu.itemAt(0).height
                                    mpvContextMenu.popup(footer, mpv.width, -menuHeight)
                }
            }
        }

        Image {
            width: window.officalScale * 20
            height: width
            sourceSize.width: width
            sourceSize.height: height
            source: "qrc:/image/audio_vol.png"
            anchors.verticalCenter : parent.verticalCenter
            Layout.leftMargin: 70
            visible: false
            MouseArea{
                anchors.fill: parent
                onClicked: {
                    mpv.setProperty("mute", !mpv.getProperty("mute"))
                    if (mpv.getProperty("mute")) {
                        text = qsTr("Unmute")
                        icon.name = "player-volume-muted"
                    } else {
                        text = qaction.text
                        icon.name = qaction.iconName()
                    }
                }
            }
        }

        Rectangle {
            id: marginArea
            width: 50 * window.officalScale
        }

        // VolumeSlider { id: volume
        //     visible: false
        // }
    }
}
