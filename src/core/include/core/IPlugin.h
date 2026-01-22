#ifndef TOOLS_VIZ_IPLUGIN_H
#define TOOLS_VIZ_IPLUGIN_H

#include <QtPlugin>
#include <QString>
#include <QUrl>

class QQmlEngine;

class IPlugin
{
public:
    virtual ~IPlugin() = default;

    // 生命周期
    virtual bool initialize() = 0;
    virtual void shutdown() = 0;

    // QML界面
    // 返回插件主界面的QML文件URL
    virtual QUrl qmlUrl() const = 0;
    
    // 注册QML类型（可选，用于向QML暴露C++类型）
    virtual void registerQmlTypes(QQmlEngine* engine) { Q_UNUSED(engine); }

    // 元数据
    virtual QString name() const = 0;
    virtual QString version() const = 0;
    virtual QString description() const = 0;
    virtual QString author() const = 0;
};

#define IPlugin_IID "com.toolsviz.IPlugin/1.0"
Q_DECLARE_INTERFACE(IPlugin, IPlugin_IID)

#endif // TOOLS_VIZ_IPLUGIN_H
