#include "OsgEarthViewerPlugin.h"
#include "EarthWidget.h"
#include <QCoreApplication>
#include <QQmlEngine>

OsgEarthViewerPlugin::OsgEarthViewerPlugin(QObject* parent)
    : QObject(parent)
{
}

OsgEarthViewerPlugin::~OsgEarthViewerPlugin()
{
}

bool OsgEarthViewerPlugin::initialize()
{
    return true;
}

void OsgEarthViewerPlugin::shutdown()
{
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
