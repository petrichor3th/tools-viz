#include "OsgEarthViewerPlugin.h"
#include "EarthWidget.h"
#include <QCoreApplication>
#include <QQmlEngine>
#include <QStandardPaths>
#include <QFile>
#include <QDebug>

#include <osgDB/Registry>
#include <osgEarth/Registry>

OsgEarthViewerPlugin::OsgEarthViewerPlugin(QObject* parent)
    : QObject(parent)
{
}

OsgEarthViewerPlugin::~OsgEarthViewerPlugin()
{
}

bool OsgEarthViewerPlugin::initialize()
{
    if (m_initialized) {
        return true;
    }

    // 1. 检查 osgEarth 库可用性
    try {
        osgEarth::Registry::instance();
        qInfo() << "OsgEarthViewerPlugin: osgEarth library loaded successfully";
    } catch (...) {
        qCritical() << "OsgEarthViewerPlugin: Failed to initialize osgEarth library";
        return false;
    }

    // 2. 配置数据目录
    m_dataDirectory = QCoreApplication::applicationDirPath() + "/data";
    osgDB::Registry::instance()->getDataFilePathList().push_back(
        m_dataDirectory.toStdString());
    qInfo() << "OsgEarthViewerPlugin: Data directory:" << m_dataDirectory;

    // 3. 查找默认地图文件
    QStringList searchPaths = {
        m_dataDirectory + "/maps/default.earth",
        QStandardPaths::writableLocation(QStandardPaths::AppDataLocation) + "/maps/default.earth"
    };

    for (const auto& path : searchPaths) {
        if (QFile::exists(path)) {
            m_defaultEarthFile = path;
            qInfo() << "OsgEarthViewerPlugin: Found default earth file:" << m_defaultEarthFile;
            break;
        }
    }

    if (m_defaultEarthFile.isEmpty()) {
        qInfo() << "OsgEarthViewerPlugin: No local earth file found, will use online map";
    }

    m_initialized = true;
    qInfo() << "OsgEarthViewerPlugin: Initialized successfully";
    return true;
}

void OsgEarthViewerPlugin::shutdown()
{
    if (!m_initialized) {
        return;
    }

    // 清理 OSG 缓存
    osgDB::Registry::instance()->clearObjectCache();

    // 重置状态
    m_defaultEarthFile.clear();
    m_dataDirectory.clear();
    m_initialized = false;

    qInfo() << "OsgEarthViewerPlugin: Shutdown completed";
}

QUrl OsgEarthViewerPlugin::qmlUrl() const
{
    QString pluginDir = QCoreApplication::applicationDirPath() + "/plugins";
    return QUrl::fromLocalFile(pluginDir + "/OsgEarthViewer.qml");
}

void OsgEarthViewerPlugin::registerQmlTypes(QQmlEngine* engine)
{
    Q_UNUSED(engine)
    qmlRegisterType<EarthWidget>("OsgEarth", 1, 0, "EarthWidget");
}

QString OsgEarthViewerPlugin::name() const
{
    return QStringLiteral("OSGEarth Viewer");
}

QString OsgEarthViewerPlugin::version() const
{
    return QStringLiteral("1.0.0");
}

QString OsgEarthViewerPlugin::description() const
{
    return QStringLiteral("3D Earth globe viewer with pan, zoom and rotate support");
}

QString OsgEarthViewerPlugin::author() const
{
    return QStringLiteral("Tools Viz Team");
}
