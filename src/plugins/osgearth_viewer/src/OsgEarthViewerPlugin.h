#ifndef OSGEARTH_VIEWER_PLUGIN_H
#define OSGEARTH_VIEWER_PLUGIN_H

#include "core/IPlugin.h"
#include <QObject>

class OsgEarthViewerPlugin : public QObject, public IPlugin
{
    Q_OBJECT
    Q_PLUGIN_METADATA(IID IPlugin_IID FILE "../osgearth_viewer.json")
    Q_INTERFACES(IPlugin)

public:
    explicit OsgEarthViewerPlugin(QObject* parent = nullptr);
    ~OsgEarthViewerPlugin() override;

    // IPlugin interface
    bool initialize() override;
    void shutdown() override;
    QUrl qmlUrl() const override;
    void registerQmlTypes(QQmlEngine* engine) override;
    QString name() const override;
    QString version() const override;
    QString description() const override;
    QString author() const override;
};

#endif // OSGEARTH_VIEWER_PLUGIN_H
