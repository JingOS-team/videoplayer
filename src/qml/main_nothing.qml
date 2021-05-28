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


    property int  deviceWidth: 1920
    property int deviceHeight: 1200

    property real officalScale: /*deviceWidth / officalWidth*/0.8

    visible: true
    width: deviceWidth
    height: deviceHeight
    // color: Kirigami.Theme.backgroundColor

    onVisibilityChanged: {
        window.showFullScreen()
    }
}
