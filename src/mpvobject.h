/*
 * SPDX-FileCopyrightText: 2020 George Florea Bănuș <georgefb899@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#ifndef MPVOBJECT_H
#define MPVOBJECT_H

#include <QtQuick/QQuickFramebufferObject>

// #include <mpv/client.h>
#include <mpv/render_gl.h>
#include "qthelper.h"

class MpvRenderer;
class Track;
class TracksModel;

class MpvObject : public QQuickFramebufferObject
{
    Q_OBJECT
    Q_PROPERTY(QString mediaTitle
               READ mediaTitle
               NOTIFY mediaTitleChanged)

    Q_PROPERTY(double position
               READ position
               WRITE setPosition
               NOTIFY positionChanged)

    Q_PROPERTY(double duration
               READ duration
               NOTIFY durationChanged)

    Q_PROPERTY(double remaining
               READ remaining
               NOTIFY remainingChanged)

    Q_PROPERTY(bool pause
               READ pause
               NOTIFY pauseChanged)

    Q_PROPERTY(int volume
               READ volume
               WRITE setVolume
               NOTIFY volumeChanged)

    Q_PROPERTY(int chapter
               READ chapter
               WRITE setChapter
               NOTIFY chapterChanged)

    Q_PROPERTY(int audioId
               READ audioId
               WRITE setAudioId
               NOTIFY audioIdChanged)

    Q_PROPERTY(int subtitleId
               READ subtitleId
               WRITE setSubtitleId
               NOTIFY subtitleIdChanged)

    Q_PROPERTY(int secondarySubtitleId
               READ secondarySubtitleId
               WRITE setSecondarySubtitleId
               NOTIFY secondarySubtitleIdChanged)

    Q_PROPERTY(int contrast
               READ contrast
               WRITE setContrast
               NOTIFY contrastChanged)

    Q_PROPERTY(int brightness
               READ brightness
               WRITE setBrightness
               NOTIFY brightnessChanged)

    Q_PROPERTY(int gamma
               READ gamma
               WRITE setGamma
               NOTIFY gammaChanged)

    Q_PROPERTY(int saturation
               READ saturation
               WRITE setSaturation
               NOTIFY saturationChanged)

    Q_PROPERTY(double watchPercentage
               MEMBER m_watchPercentage
               READ watchPercentage
               WRITE setWatchPercentage
               NOTIFY watchPercentageChanged)


    QString mediaTitle();

    double position();
    void setPosition(double value);

    double remaining();
    double duration();
    bool pause();
    
    int volume();
    void setVolume(int value);

    int chapter();
    void setChapter(int value);

    int audioId();
    void setAudioId(int value);

    int subtitleId();
    void setSubtitleId(int value);

    int secondarySubtitleId();
    void setSecondarySubtitleId(int value);

    int contrast();
    void setContrast(int value);

    int brightness();
    void setBrightness(int value);

    int gamma();
    void setGamma(int value);

    int saturation();
    void setSaturation(int value);

    double watchPercentage();
    void setWatchPercentage(double value);


    mpv_handle *mpv;
    mpv_render_context *mpv_gl;

    friend class MpvRenderer;
public:
    MpvObject(QQuickItem * parent = 0);
    virtual ~MpvObject();
    virtual Renderer *createRenderer() const;

public slots:
    static void on_mpv_events(void *ctx);
    void eventHandler();
    int setProperty(const QString &name, const QVariant &value);
    QVariant getProperty(const QString &name);
    QVariant command(const QVariant &params);
    TracksModel *audioTracksModel() const;
    TracksModel *subtitleTracksModel() const;

signals:
    void mediaTitleChanged();
    void positionChanged();
    void durationChanged();
    void remainingChanged();
    void volumeChanged();
    void pauseChanged();
    void chapterChanged();
    void audioIdChanged();
    void subtitleIdChanged();
    void secondarySubtitleIdChanged();
    void contrastChanged();
    void brightnessChanged();
    void gammaChanged();
    void saturationChanged();
    void fileLoaded();
    void endOfFile();
    void watchPercentageChanged();
    void ready();

private:
    TracksModel *m_audioTracksModel;
    TracksModel *m_subtitleTracksModel;
    QMap<int, Track*> m_subtitleTracks;
    QMap<int, Track*> m_audioTracks;
    QList<int> m_secondsWatched;
    double m_watchPercentage;

    void loadTracks();
};

class MpvRenderer : public QQuickFramebufferObject::Renderer
{
public:
    MpvRenderer(MpvObject *new_obj);
    ~MpvRenderer() = default;

    MpvObject *obj;

    // This function is called when a new FBO is needed.
    // This happens on the initial frame.
    QOpenGLFramebufferObject * createFramebufferObject(const QSize &size);

    void render();
};

#endif // MPVOBJECT_H
