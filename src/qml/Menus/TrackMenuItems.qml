/*
 * SPDX-FileCopyrightText: 2020 George Florea Bănuș <georgefb899@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQml 2.12

Instantiator {
    id: root

    property bool isFirst: true
    property var menu

    signal subtitleChanged(int id, int index)

    model: 0
    onObjectAdded: menu.addItem( object )
    onObjectRemoved: menu.removeItem( object )
    delegate: MenuItem {
        checkable: true
        checked: isFirst ? model.isFirstTrack : model.isSecondTrack
        text: model.text
        onTriggered: subtitleChanged(model.id, model.index)
    }
}
