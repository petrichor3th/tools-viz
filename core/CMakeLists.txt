set(CORE_SOURCES
    src/PluginManager.cpp
    src/PluginMetadata.cpp
)

set(CORE_HEADERS
    include/core/core_global.h
    include/core/IPlugin.h
    include/core/PluginManager.h
    include/core/PluginMetadata.h
)

add_library(ToolsVizCore SHARED ${CORE_SOURCES} ${CORE_HEADERS})

target_include_directories(ToolsVizCore
    PUBLIC
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
        $<INSTALL_INTERFACE:include>
)

target_link_libraries(ToolsVizCore PUBLIC Qt6::Core Qt6::Widgets Qt6::Quick Qt6::QuickWidgets)

# Windows 下导出符号
if(WIN32)
    target_compile_definitions(ToolsVizCore PRIVATE TOOLSVIZCORE_LIBRARY)
endif()
