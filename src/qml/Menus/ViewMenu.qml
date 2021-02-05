/*
 * SPDX-FileCopyrightText: 2020 George Florea Bănuș <georgefb899@gmail.com>
 * SPDX-FileCopyrightText: 2021 Wang Rui <wangrui@jingos.com>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.12
import QtQuick.Controls 2.12

Menu {
    id: root

    title: qsTr("&View")
    visible: false

    MenuItem {
        action: actions["toggleMenuBarAction"]
        text: menuBar.visible ? qsTr("Hide Menu Bar") : qsTr("Show Menu Bar")
    }
    MenuItem {
        action: actions["toggleHeaderAction"]
        text: header.visible ? qsTr("Hide Header") : qsTr("Show Header")
    }
}
