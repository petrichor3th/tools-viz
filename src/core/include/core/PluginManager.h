#ifndef TOOLS_VIZ_PLUGIN_MANAGER_H
#define TOOLS_VIZ_PLUGIN_MANAGER_H

#include <core/core_global.h>
#include <QObject>
#include <QMap>
#include <QList>

class IPlugin;
class QPluginLoader;

class TOOLSVIZCORE_EXPORT PluginManager : public QObject
{
    Q_OBJECT

public:
    explicit PluginManager(QObject* parent = nullptr);
    ~PluginManager();

    // 从指定目录加载所有插件
    void loadPlugins(const QString& pluginDir);

    // 获取所有已加载的插件
    QList<IPlugin*> getAllPlugins() const;

    // 根据名称获取插件
    IPlugin* getPlugin(const QString& name) const;

    // 卸载所有插件
    void unloadAllPlugins();

signals:
    void pluginLoaded(const QString& name);
    void pluginLoadFailed(const QString& path, const QString& error);

private:
    QMap<QString, IPlugin*> m_plugins;
    QList<QPluginLoader*> m_loaders;
};

#endif // TOOLS_VIZ_PLUGIN_MANAGER_H
