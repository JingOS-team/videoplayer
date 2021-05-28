/*
 * SPDX-FileCopyrightText: 2020 George Florea Bănuș <georgefb899@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.0
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import org.kde.kirigami 2.15 as Kirigami
import org.kde.haruna 1.0

Item {
    id: root

    property bool hasHelp: true
    property string helpFile: ":/VideoSettings.html"

    anchors.fill: parent

    ColumnLayout {
        width: parent.width

        RowLayout {
            Label {
                text: qsTr("Screenshots")
            }
            Rectangle {
                height: 1
                color: Kirigami.Theme.alternateBackgroundColor
                Layout.fillWidth: true
            }
        }

        // ------------------------------------
        // Screenshot Format
        // ------------------------------------
        RowLayout {

            Label { text: qsTr("Format") }

            ComboBox {
                id: screenshotFormat
                textRole: "key"
                model: ListModel {
                    id: leftButtonModel
                    ListElement { key: "PNG"; }
                    ListElement { key: "JPG"; }
                    ListElement { key: "WebP"; }
                }

                onActivated: {
                    VideoSettings.screenshotFormat = model.get(index).key
                    mpv.setProperty("screenshot-format", VideoSettings.screenshotFormat)
                }

                Component.onCompleted: {
                    if (VideoSettings.screenshotFormat === "PNG") {
                        currentIndex = 0
                    }
                    if (VideoSettings.screenshotFormat === "JPG") {
                        currentIndex = 1
                    }
                    if (VideoSettings.screenshotFormat === "WebP") {
                        currentIndex = 2
                    }
                }
            }
        }

        // ------------------------------------
        // Screenshot template
        // ------------------------------------
        ColumnLayout {

            Label {
                text: qsTr("Template")
            }

            TextField {
                text: VideoSettings.screenshotTemplate
                onEditingFinished: {
                    VideoSettings.screenshotTemplate = text
                    mpv.setProperty("screenshot-template", VideoSettings.screenshotTemplate)
                }
                Layout.fillWidth: true
            }
        }
    }
}
