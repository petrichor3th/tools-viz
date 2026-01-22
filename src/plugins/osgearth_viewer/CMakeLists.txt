set(PLUGIN_SOURCES
    src/OsgEarthViewerPlugin.h
    src/OsgEarthViewerPlugin.cpp
    src/EarthWidget.h
    src/EarthWidget.cpp
)

set(PLUGIN_QML_FILES
    ${CMAKE_CURRENT_SOURCE_DIR}/qml/OsgEarthViewer.qml
)

add_tools_viz_plugin(osgearth_viewer
    SOURCES ${PLUGIN_SOURCES}
    QML_FILES ${PLUGIN_QML_FILES}
    EXTRA_LIBS
        ${OPENSCENEGRAPH_LIBRARIES}
        osgEarth::osgEarth
)

# 添加 osgEarth 包含目录
target_include_directories(osgearth_viewer PRIVATE
    ${OPENSCENEGRAPH_INCLUDE_DIRS}
)
