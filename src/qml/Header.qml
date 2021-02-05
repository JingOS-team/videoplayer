/*
 * SPDX-FileCopyrightText: 2020 George Florea Bănuș <georgefb899@gmail.com>
 * SPDX-FileCopyrightText: 2021 Wang Rui <wangrui@jingos.com>
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

ToolBar {
    id: root

    property var audioTracks
    property var subtitleTracks
    property var currentname

    position: ToolBar.Header
    hoverEnabled: true
    visible: true
    Kirigami.JIconButton
    {
        id: backImage
        width: window.officalScale * 44 + 10
        height: width
        source: "qrc:/image/audio_back.png"
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: 21

        MouseArea{
            width: parent.width + 40
            height: parent.height + 40
            onClicked: {
                Qt.quit()
            }
        }
    }

    Text {
        id:name
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: backImage.right
        anchors.leftMargin: 21
        text: currentname
        font.pointSize: theme.defaultFont.pointSize + 6//26
        style: Text.Gilroy
        color: 
        {
            "#FFFFFFFF"
        }

        width: parent.width - backImage.width * 2
        elide: Text.ElideRight
    }
}
