/*
 * SPDX-FileCopyrightText: 2020 George Florea Bănuș <georgefb899@gmail.com>
 * SPDX-FileCopyrightText: 2021 Wang Rui <wangrui@jingos.com>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.12
import QtQuick.Window 2.12
import mpv 1.0
import org.kde.plasma.core 2.0 as PlasmaCore

import org.kde.haruna 1.0

import QtQml 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtQuick.Shapes 1.12
import QtQml.Models 2.15
import org.kde.kirigami 2.15 as Kirigami
import org.kde.plasma.private.volume 0.1



MpvObject {
    id: root

    property int mx
    property int my
    property alias scrollPositionTimer: scrollPositionTimer
    property alias toastArea: toastArea
    property alias volumeOrBrightArea: volumeOrBrightArea
    property alias vobImage: vobImage
    property int brightnessValue

    property bool pressState: false
    property int beginX : -1
    property int beginY : -1
    property int lastX : -1
    property int lastY : -1
    property int moveDirection: 0
    property bool dealHorizontal: false
    property bool dealV: false
    property bool isBack: false
    property bool isLastStatus: false

    property bool timerStarted: true
    property bool showMouse: false

    signal setSubtitle(int id)
    signal setSecondarySubtitle(int id)
    signal setAudio(int id)

    width: parent.width
    height: parent.height - footer.height
    anchors.right: parent.right
    anchors.fill: parent
    volume: GeneralSettings.volume

    onReady: {
        if(playListModel.getPlaylistSize() > 0)
        {
            window.openFile(playListModel.getPath(playListModel.getPlayingVideo()), true, true)//第一个表示是否自动播放  第二个意义不明
        }else
        {
            window.openFile(GeneralSettings.lastPlayedFile, false, true)
        }
    }

    onEndOfFile: {
        const nextFileRow = playListModel.getPlayingVideo() + 1
        if (nextFileRow < playList.playlistView.count) {
            const nextFile = playListModel.getPath(nextFileRow)
            window.openFile(nextFile, true, false)
            playListModel.setPlayingVideo(nextFileRow)
        } else {
            isLastStatus = true
            mpv.setProperty("pause", true)
        }
    }

    onPauseChanged: 
    {
        if (!pause) {
            if(isLastStatus) {
                isLastStatus = false
                mpv.command(["loadfile", playListModel.getPath(playList.playlistView.count - 1)])
                playListModel.setPlayingVideo(playList.playlistView.count - 1)
            }
        } 
    }

    Timer {
        id: scrollPositionTimer
        interval: 50; running: true; repeat: true

        onTriggered: {
            setPlayListScrollPosition()
            scrollPositionTimer.stop()
        }
    }

    Timer {
        id: hideCursorTimer

        property int tx: mx
        property int ty: my
        property int timeNotMoved: 0

        interval: 50 
        running: timerStarted
        repeat: true

        onTriggered: {
            if (mx === tx && my === ty) {
                if (timeNotMoved >= 5000) {
                    app.hideCursor()
                    header.visible = false
                    footer.visible = false
                    toastArea.visible = false
                    volumeOrBrightArea.visible = false
                }
            } else if(showMouse){
                app.showCursor()
                header.visible = true
                footer.visible = true
                timeNotMoved = 0
            }
            tx = mx
            ty = my
            timeNotMoved += interval
        }
    }

    MouseArea {

        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
        x: 100 
        width:parent.width - 200 
        height: parent.height
        
        hoverEnabled: true

        onEntered: 
        {
            timerStarted = true
        }

        onExited: 
        {
            timerStarted = false
            hideCursorTimer.timeNotMoved = 0
        }

        onPressed: {
            pressState = true
            dealHorizontal = false
            dealV = false
            moveDirection = 0
            beginY = mouseY
            beginX = mouseX
            lastX = mouseX
            lastY = mouseY
            showMouse = false
        }

        onPositionChanged: {
            if(Math.abs(mouseX - beginX) < 10 && Math.abs(mouseY - beginY) < 10)//防止太过灵敏
            {
                return
            }
            showMouse = true
            if(pressState)
            {
                if(Math.abs(lastX - mouseX) < 5 && Math.abs(lastY - mouseY) < 5)
                {
                    return
                }
                var offsetX = 1
                var offsetY = 5
                var distanceX = mouseX - beginX
                var distanceY = -(mouseY - beginY)
                
                if (!dealV && Math.abs(distanceX) > offsetY && Math.abs(distanceX) - Math.abs(distanceY) > offsetX) {
                    if(isLastStatus)
                    {
                        return
                    }  
                    dealHorizontal = true
                    seekStarted = true
                    dealHorizontalMoveData(distanceX)
                    
                } else if(!dealHorizontal && Math.abs(distanceY) > offsetY){
                    dealV = true
                    if (beginX < root.width / 2) {
                        dealBrightness(distanceY)
                    } else {
                        dealVolume(distanceY)
                    }
                }
                lastX = mouseX
                lastY = mouseY
            }
        }


        onReleased: {
            if(seekStarted)
            {
                mpv.command(["seek", horizontalMoveData, "absolute"])
                seekStarted = false
            }    

            if(!dealHorizontal) 
            {
                showMouse = true
                footer.visible = !footer.visible
                header.visible = !header.visible
            }
            pressState = false
            beginX = -1
            beginY = -1
            toastArea.visible = false
            volumeOrBrightArea.visible = false
            dealHorizontal = false
            dealV = false
        }

        onMouseXChanged: {
        }

        onMouseYChanged: {
            my = mouseY
        }

        onWheel: {
            if (wheel.x < root.width / 2) {
                if(wheel.angleDelta.x == 0 && wheel.angleDelta.y != 0)
                {
                    dealBrightness(-wheel.angleDelta.y)
                }
            } else {
                if(wheel.angleDelta.x == 0 && wheel.angleDelta.y != 0)
                {
                    dealVolume(-wheel.angleDelta.y)
                }
            }
        }

        onDoubleClicked: {
            if (mouse.button === Qt.LeftButton) {
                mpv.setProperty("pause", !mpv.getProperty("pause"))
            } 
        }
    }

    Rectangle {
        id: toastArea
        color: "#99000000"
        width: 338 + 42 + 40
        height: 96
        radius: 24
        visible: false
        anchors.centerIn: parent

        Image {
            id:statusIcon
            width: 44
            height:44
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 40
            source: 
            {
                if(!isBack)
                {
                    "qrc:/image/video_forward.png"
                }else
                {
                    "qrc:/image/video_back.png"
                }
            }
        }
        Text {
            id:currentTimeText
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: statusIcon.right
            anchors.leftMargin: 14
            text: app.formatTime(horizontalMoveData)
            font.pointSize: theme.defaultFont.pointSize + 6//26
            style: Text.Gilroy
            color: 
            {
                "#ff43BDF4"
            }
        }

        Text {
            id:durationText
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: currentTimeText.right
            text: "/" + app.formatTime(mpv.duration)
            font.pointSize: theme.defaultFont.pointSize + 6//26
            style: Text.Gilroy
            color: 
            {
                "#ffffffff"
            }
        }
    }

    Rectangle {
        id: volumeOrBrightArea
        color: "#99000000"
        width: 338
        height: 96
        radius: 24
        visible: false
        anchors.centerIn: parent

        property int vob: 0

        Image {
            id:vobImage
            width: 44
            height:44
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 26
            source: 
            {
                if(volumeOrBrightArea.vob == 1)
                {
                    if(GeneralSettings.volume == 0)
                    {
                        "qrc:/image/vol_silent.png"
                    }else if(GeneralSettings.volume > 0 && GeneralSettings.volume < 50)
                    {
                        "qrc:/image/vol_low.png"
                    }else if(GeneralSettings.volume > 50)
                    {
                        "qrc:/image/vol_mid.png"
                    }
                }else
                {
                    "qrc:/image/bri.png"
                }
            }
        }

        Slider
        {
            id: progressBar
            width: 226
            z: parent.z + 1
            from: 
            {
                if(volumeOrBrightArea.vob == 2)
                {
                    1
                }else{
                    0
                }
            }
            to:{
                if(volumeOrBrightArea.vob == 2)
                {
                    maxBrightness
                }else{
                    100
                }
            } 
            value:
            {
                if(volumeOrBrightArea.vob == 1)
                {
                    GeneralSettings.volume
                }else
                {
                    brightnessValue
                }
            } 
            spacing: 0
            focus: true
            enabled: false
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: vobImage.right
            anchors.leftMargin: 16

            background: Rectangle
            {
                id: rect1
                width: progressBar.availableWidth
                height: 8
                color: "#4DEBEBF5"
                opacity: 0.4
                radius: 2
                anchors.verticalCenter: parent.verticalCenter

                Rectangle
                {
                    id: rect2
                    width: progressBar.visualPosition * parent.width
                    height: 8
                    color: "#FFFFFFFF"                  
                    radius: 2
                }
            }
        }
    }

    property int horizontalMoveData: 0
    property bool seekStarted: false
    function dealHorizontalMoveData(horizontal)
    {
        toastArea.visible = true
        if(horizontal > 0)
        {
            isBack = false
        }else if(horizontal < 0)
        {
            isBack = true
        }
        var delta = horizontal / root.width * 100
        delta = delta / 10
        if(delta > 0 && delta < 1)
        {
            delta = 1
        }
        if(horizontalMoveData + delta <= 0)
        {
            horizontalMoveData = 0
        }else if(horizontalMoveData + delta > mpv.duration)
        {
            horizontalMoveData = mpv.duration
        }else
        {
            horizontalMoveData += delta
        }

        footer.progressBar.value = horizontalMoveData
    }

    function setPlayListScrollPosition() {
       playList.playlistView.positionViewAtIndex(playListModel.playingVideo, ListView.Beginning)
    }

    property int maxBrightness: 0
    PlasmaCore.DataSource 
    {
        id: pmSource
        engine: "powermanagement"
        connectedSources: ["PowerDevil"]
        onSourceAdded: {
            if (source === "PowerDevil") {
                disconnectSource(source);
                connectSource(source);
            }
        }

        onDataChanged: {
            if(maxBrightness == 0)
            {
                maxBrightness = pmSource.data["PowerDevil"] ? pmSource.data["PowerDevil"]["Maximum Screen Brightness"] || 0 : 7500
            }
            disableBrightnessUpdate = true;
            brightnessValue = pmSource.data["PowerDevil"]["Screen Brightness"]
            disableBrightnessUpdate = false;
        }
    }

    function setBrightness()
    {
        var service = pmSource.serviceForSource("PowerDevil")
        var operation = service.operationDescription("setBrightness")
        operation.brightness = brightnessValue
        operation.silent = true
        service.startOperationCall(operation)
    }

    function dealBrightness(distanceY)
    {
        volumeOrBrightArea.visible = true
        volumeOrBrightArea.vob = 2

        var newBrightness = distanceY / root.height * maxBrightness;
        newBrightness += brightnessValue;

        if (newBrightness < 100) {
            newBrightness = 100;
        } else if (newBrightness > maxBrightness) {
            newBrightness = maxBrightness;
        }

        brightnessValue = newBrightness
        setBrightness()
    }

    function dealVolume(distanceY)
    {
        volumeOrBrightArea.visible = true
        volumeOrBrightArea.vob = 1
        var newVolume = distanceY / root.height * 100
        newVolume += mpv.volume
        if(newVolume < 0)
        {
            newVolume = 0
        }else if(newVolume > 100)
        {
            newVolume = 100
        }
        mpv.volume = newVolume
        GeneralSettings.volume = newVolume
    }

    property bool disableBrightnessUpdate: true
}
