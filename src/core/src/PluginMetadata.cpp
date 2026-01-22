#include "core/PluginMetadata.h"

PluginMetadata PluginMetadata::fromJson(const QJsonObject& json)
{
    PluginMetadata meta;
    meta.name = json.value("name").toString();
    meta.version = json.value("version").toString();
    meta.description = json.value("description").toString();
    meta.author = json.value("author").toString();
    return meta;
}
