#ifndef TOOLS_VIZ_PLUGIN_METADATA_H
#define TOOLS_VIZ_PLUGIN_METADATA_H

#include <core/core_global.h>
#include <QString>
#include <QJsonObject>

struct TOOLSVIZCORE_EXPORT PluginMetadata
{
    QString name;
    QString version;
    QString description;
    QString author;

    static PluginMetadata fromJson(const QJsonObject& json);
};

#endif // TOOLS_VIZ_PLUGIN_METADATA_H
