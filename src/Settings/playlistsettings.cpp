/*
 * SPDX-FileCopyrightText: 2020 George Florea Bănuș <georgefb899@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#include "playlistsettings.h"

PlaylistSettings::PlaylistSettings(QObject *parent)
    : Settings(parent)
{
    CONFIG_GROUP = QStringLiteral("Playlist");
    m_defaultSettings = {
        {"CanToggleWithMouse", QVariant(true)},
        {"ShowRowNumber",      QVariant(true)},
        {"Position",           QVariant(QStringLiteral("right"))},
        {"RowHeight",          QVariant(10)},
        {"BigFontFullscreen",  QVariant(true)},
        {"Repeat",             QVariant(true)},
    };
}

QString PlaylistSettings::position()
{
    return get("Position").toString();
}

void PlaylistSettings::setPosition(const QString &value)
{
    if (value == position()) {
        return;
    }
    set("Position", value);
    emit positionChanged();
}

int PlaylistSettings::rowHeight()
{
    return get("RowHeight").toInt();
}

void PlaylistSettings::setRowHeight(int value)
{
    if (value == rowHeight()) {
        return;
    }
    set("RowHeight", QString::number(value));
    emit rowHeightChanged();
}

bool PlaylistSettings::showRowNumber()
{
    return get("ShowRowNumber").toBool();
}

void PlaylistSettings::setShowRowNumber(bool value)
{
    if (value == showRowNumber()) {
        return;
    }
    set("ShowRowNumber", QVariant(value).toString());
    emit showRowNumberChanged();
}

bool PlaylistSettings::canToggleWithMouse()
{
    return get("CanToggleWithMouse").toBool();
}

void PlaylistSettings::setCanToggleWithMouse(bool value)
{
    if (value == canToggleWithMouse()) {
        return;
    }
    set("CanToggleWithMouse", QVariant(value).toString());
    emit canToggleWithMouseChanged();
}

bool PlaylistSettings::bigFontFullscreen()
{
    return get("BigFontFullscreen").toBool();
}

void PlaylistSettings::setBigFontFullscreen(bool value)
{
    if (value == bigFontFullscreen()) {
        return;
    }
    set("BigFontFullscreen", QVariant(value).toString());
    emit bigFontFullscreenChanged();
}

bool PlaylistSettings::repeat()
{
    return get("Repeat").toBool();
}

void PlaylistSettings::setRepeat(bool value)
{
    if (value == repeat()) {
        return;
    }
    set("Repeat", QVariant(value).toString());
    emit repeatChanged();
}
