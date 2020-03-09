/*
 * SPDX-FileCopyrightText: 2020 George Florea Bănuș <georgefb899@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQml 2.13
import QtQuick 2.13
import QtQuick.Controls 2.13

Menu {
    id: root

    title: qsTr("&Audio")

    Menu {
        id: audioMenu

        title: qsTr("&Primary Track")

        Instantiator {
            id: audioMenuInstantiator
            model: 0
            onObjectAdded: audioMenu.insertItem( index, object )
            onObjectRemoved: audioMenu.removeItem( object )
            delegate: MenuItem {
                id: audioMenuItem
                checkable: true
                checked: model.isFirstTrack
                text: model.text
                onTriggered: {
                    mpv.setAudio(model.id)
                    mpv.audioTracksModel().updateFirstTrack(model.index)
                }
            }
        }
        Connections {
            target: mpv
            onFileLoaded: {
                audioMenuInstantiator.model = mpv.audioTracksModel()
            }
        }
    }

    MenuSeparator {}

    MenuItem { action: actions["muteAction"] }
    MenuItem { action: actions["volumeUpAction"] }
    MenuItem { action: actions["volumeDownAction"] }
}
