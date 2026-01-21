#ifndef TOOLS_VIZ_EXAMPLE_PLUGIN_H
#define TOOLS_VIZ_EXAMPLE_PLUGIN_H

#include "core/IPlugin.h"
#include <QObject>

class ExamplePlugin : public QObject, public IPlugin
{
    Q_OBJECT
    Q_PLUGIN_METADATA(IID IPlugin_IID FILE "../example-plugin.json")
    Q_INTERFACES(IPlugin)

public:
    explicit ExamplePlugin(QObject* parent = nullptr);
    ~ExamplePlugin() override;

    // IPlugin interface
    bool initialize() override;
    void shutdown() override;
    QUrl qmlUrl() const override;
    QString name() const override;
    QString version() const override;
    QString description() const override;
    QString author() const override;
};

#endif // TOOLS_VIZ_EXAMPLE_PLUGIN_H
