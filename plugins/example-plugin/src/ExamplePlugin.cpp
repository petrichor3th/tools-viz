#include "ExamplePlugin.h"
#include <QDir>
#include <QCoreApplication>

ExamplePlugin::ExamplePlugin(QObject* parent)
    : QObject(parent)
{
}

ExamplePlugin::~ExamplePlugin()
{
}

bool ExamplePlugin::initialize()
{
    return true;
}

void ExamplePlugin::shutdown()
{
}

QUrl ExamplePlugin::qmlUrl() const
{
    // QML文件位于插件目录下
    QString pluginDir = QCoreApplication::applicationDirPath() + "/plugins";
    return QUrl::fromLocalFile(pluginDir + "/ExamplePlugin.qml");
}

QString ExamplePlugin::name() const
{
    return QStringLiteral("Example Plugin");
}

QString ExamplePlugin::version() const
{
    return QStringLiteral("1.0.0");
}

QString ExamplePlugin::description() const
{
    return QStringLiteral("A simple text editor example plugin with QML UI");
}

QString ExamplePlugin::author() const
{
    return QStringLiteral("Tools Viz Team");
}
