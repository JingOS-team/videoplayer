/*
 * SPDX-FileCopyrightText: 2020 George Florea Bănuș <georgefb899@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtQml 2.12
import org.kde.kirigami 2.15 as Kirigami
import org.kde.haruna 1.0
import QtGraphicalEffects 1.12
import "Menus"

// ToolBar {
Rectangle{
    id: root

    property var audioTracks
    property var subtitleTracks
    property var currentname

    // position: ToolBar.Header
    // hoverEnabled: true

        width: parent.width
        height: 80
        anchors.top: parent.top
        color: "transparent"
        LinearGradient {            ///--[Mark]
            anchors.fill: parent
            start: Qt.point(0, 0)
            gradient: Gradient {
                GradientStop {  position: 0.0;    color: "#a0000000" }
                GradientStop {  position: 1.0;    color: "#00000000" }
            }
        }

    visible: true
    Kirigami.JIconButton
    {
        id: backImage
        width: 22 + 10
        height: width
        source: "qrc:/image/audio_back.png"
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: 11

        onClicked: {
            Qt.quit()
        }
    }

    Text {
        id:name
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: backImage.right
        anchors.leftMargin: 11
        text: currentname
        // font.pointSize: theme.defaultFont.pointSize - 3
        font.pixelSize: 17
        style: Text.Gilroy
        color: 
        {
            "#FFFFFFFF"
        }

        width: parent.width - backImage.width * 2
        elide: Text.ElideRight
    }
}
