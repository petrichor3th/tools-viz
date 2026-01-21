#include "core/PluginManager.h"
#include "core/IPlugin.h"

#include <QDir>
#include <QPluginLoader>
#include <QDebug>

PluginManager::PluginManager(QObject* parent)
    : QObject(parent)
{
}

PluginManager::~PluginManager()
{
    unloadAllPlugins();
}

void PluginManager::loadPlugins(const QString& pluginDir)
{
    QDir dir(pluginDir);
    if (!dir.exists()) {
        qWarning() << "Plugin directory does not exist:" << pluginDir;
        return;
    }

    // 根据平台设置插件文件过滤器
#ifdef Q_OS_WIN
    QStringList filters = {"*.dll"};
#elif defined(Q_OS_MAC)
    QStringList filters = {"*.dylib"};
#else
    QStringList filters = {"*.so"};
#endif

    dir.setNameFilters(filters);
    
    const QStringList files = dir.entryList(QDir::Files);
    for (const QString& fileName : files) {
        const QString filePath = dir.absoluteFilePath(fileName);
        
        QPluginLoader* loader = new QPluginLoader(filePath, this);
        QObject* instance = loader->instance();
        
        if (instance) {
            IPlugin* plugin = qobject_cast<IPlugin*>(instance);
            if (plugin) {
                if (plugin->initialize()) {
                    m_plugins.insert(plugin->name(), plugin);
                    m_loaders.append(loader);
                    qInfo() << "Loaded plugin:" << plugin->name() << "v" << plugin->version();
                    emit pluginLoaded(plugin->name());
                } else {
                    qWarning() << "Plugin initialization failed:" << plugin->name();
                    loader->unload();
                    delete loader;
                }
            } else {
                qWarning() << "Not a valid plugin:" << filePath;
                loader->unload();
                delete loader;
            }
        } else {
            QString error = loader->errorString();
            qWarning() << "Failed to load plugin:" << filePath << "-" << error;
            emit pluginLoadFailed(filePath, error);
            delete loader;
        }
    }
}

QList<IPlugin*> PluginManager::getAllPlugins() const
{
    return m_plugins.values();
}

IPlugin* PluginManager::getPlugin(const QString& name) const
{
    return m_plugins.value(name, nullptr);
}

void PluginManager::unloadAllPlugins()
{
    for (auto& plugin : m_plugins) {
        plugin->shutdown();
    }
    m_plugins.clear();

    for (QPluginLoader* loader : m_loaders) {
        loader->unload();
        delete loader;
    }
    m_loaders.clear();
}
