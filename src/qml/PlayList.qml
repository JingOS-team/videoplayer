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

import org.kde.kirigami 2.15 as Kirigami
import org.kde.haruna 1.0

Rectangle {
    id: root

    property alias playlistView: playlistView
    property bool canToggleWithMouse: PlaylistSettings.canToggleWithMouse
    property string position: PlaylistSettings.position
    property int rowHeight: PlaylistSettings.rowHeight
    property int bigFont: PlaylistSettings.bigFontFullscreen

    height: mpv.height
    width: (parent.width * 0.33) < 550 ? 550 : parent.width * 0.33
    x: position === "right" ? parent.width : -width
    y: 0
    state: "hidden"
    color: Kirigami.Theme.backgroundColor

    ListView {
        id: playlistView

        model: playListModel
        delegate: PlayListItem {}
        anchors.fill: parent
        anchors.rightMargin: scrollBar.visible ? scrollBar.width : 0
        boundsBehavior: Flickable.StopAtBounds

        z: 20
        ScrollBar.vertical: ScrollBar {
            id: scrollBar
            parent: playlistView.parent
            anchors.top: playlistView.top
            anchors.bottom: playlistView.bottom
            anchors.left: playlistView.right
            z: 25
        }
    }

    MouseArea {
        anchors.fill: parent
        onWheel: wheel.accepted = true
        hoverEnabled: false
    }

    ShaderEffectSource {
        id: shaderEffect
        anchors.fill: playlistView
        sourceItem: mpv
        sourceRect: position === "right"
                    ? Qt.rect(mpv.width - root.width, mpv.y, root.width, root.height)
                    : Qt.rect(0, 0, root.width, root.height)
    }

    FastBlur {
        anchors.fill: shaderEffect
        radius: 100
        source: shaderEffect
        z: 10
    }

    states: [
        State {
            name: "hidden"
            PropertyChanges { target: root; x: position === "right" ? parent.width : -width }
            PropertyChanges { target: root; visible: false }
        },
        State {
            name : "visible"
            PropertyChanges { target: root; x: position === "right" ? parent.width - root.width : mpv.x }
            PropertyChanges { target: root; visible: true }
        }
    ]

    transitions: [
        Transition {
            from: "visible"
            to: "hidden"

            SequentialAnimation {
                NumberAnimation {
                    target: root
                    property: "x"
                    duration: 120
                    easing.type: Easing.InQuad
                }
                PropertyAction {
                    target: root
                    property: "visible"
                    value: false
                }
            }
        },
        Transition {
            from: "hidden"
            to: "visible"

            SequentialAnimation {
                PropertyAction {
                    target: root
                    property: "visible"
                    value: true
                }
                NumberAnimation {
                    target: root
                    property: "x"
                    duration: 120
                    easing.type: Easing.OutQuad
                }
            }
        }
    ]
}
