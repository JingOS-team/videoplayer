/*
 * SPDX-FileCopyrightText: 2020 George Florea Bănuș <georgefb899@gmail.com>
 * SPDX-FileCopyrightText: 2021 Wang Rui <wangrui@jingos.com>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#include "_debug.h"
#include "application.h"
#include "lockmanager.h"
#include "mpvobject.h"
#include "tracksmodel.h"
#include "subtitlesfoldersmodel.h"
#include "playlist/playlistitem.h"
#include "playlist/playlistmodel.h"
#include "worker.h"

#include <QApplication>
#include <QCommandLineParser>
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickItem>
#include <QQuickStyle>
#include <QQuickView>
#include <QThread>
#include <QDBusConnection>
#include <QDBusError>
#include <KAboutData>
#include <KI18n/KLocalizedString>

#include "player.h"
#include <QFileInfo>
#include <QSurfaceFormat>

#define SERVICE_NAME            "org.kde.haruna.qtdbus.playvideo"

int main(int argc, char *argv[])
{

    QApplication::setApplicationName("haruna");
    QApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QApplication::setAttribute(Qt::AA_UseHighDpiPixmaps);
    QApplication::setOrganizationName("kde");
    QApplication::setOrganizationDomain("kde.org");
    QApplication::setWindowIcon(QIcon::fromTheme("org.kde.haruna"));
    QApplication app(argc, argv);
    app.setOrganizationDomain("kde.org");
    QQuickStyle::setStyle(QStringLiteral("org.kde.desktop"));
    QQuickStyle::setFallbackStyle(QStringLiteral("fusion"));


    KAboutData aboutData(
        QStringLiteral("haruna"),
        i18n("JingOS Media Player"),
        QStringLiteral("0.2.2"),
        i18n("A simple meida player."),
        KAboutLicense::GPL_V3,
        i18n("(c) 2020"),
        i18n("TO DO..."),
        QStringLiteral("http://kde.org/haruna"),
        QStringLiteral("georgefb899@gmail.com"));
    KAboutData::setApplicationData(aboutData);

    QCommandLineParser parser;
    aboutData.setupCommandLine(&parser);
    parser.addPositionalArgument(QStringLiteral("file"), i18n("File to open"));
    parser.process(app);
    aboutData.processCommandLine(&parser);

    // Qt sets the locale in the QGuiApplication constructor, but libmpv
    // requires the LC_NUMERIC category to be set to "C", so change it back.
    std::setlocale(LC_NUMERIC, "C");

    qmlRegisterType<MpvObject>("mpv", 1, 0, "MpvObject");
    qRegisterMetaType<QAction*>();
    qRegisterMetaType<TracksModel*>();

    std::unique_ptr<Application> myApp = std::make_unique<Application>();

    PlayListModel playListModel;
    auto worker = Worker::instance();
    auto thread = new QThread();
    worker->moveToThread(thread);
    QObject::connect(thread, &QThread::finished,
                     worker, &Worker::deleteLater);
    QObject::connect(thread, &QThread::finished,
                     thread, &QThread::deleteLater);
    thread->start();

    QQmlApplicationEngine engine;
    const QUrl url(QStringLiteral("qrc:/qml/main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated, &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl) {
            QCoreApplication::exit(-1);
        }
    }, Qt::QueuedConnection);

    engine.rootContext()->setContextProperty("playListModel", &playListModel);
    qmlRegisterUncreatableType<PlayListModel>("PlayListModel", 1, 0, "PlayListModel",
            QStringLiteral("PlayListModel should not be created in QML"));

    engine.rootContext()->setContextProperty(QStringLiteral("app"), myApp.get());
    qmlRegisterUncreatableType<Application>("Application", 1, 0, "Application",
                                            QStringLiteral("Application should not be created in QML"));

    myApp.get()->setupQmlSettingsTypes();

    engine.load(url);


    auto player = new Player(engine, playListModel);
    player->setDate(argc, argv);
    auto myThread = new QThread();
    player->moveToThread(myThread);
    QObject::connect(myThread, &QThread::started,
                     player,  &Player::start);
    myThread->start();

    return QApplication::exec();
}

