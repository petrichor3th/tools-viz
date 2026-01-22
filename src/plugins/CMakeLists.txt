# ==============================================================================
# ToolsViz 插件
# ==============================================================================

# OSGEarth 三维地球浏览插件（仅在找到 osgEarth 时构建）
if(osgEarth_FOUND AND OPENSCENEGRAPH_FOUND)
    message(STATUS "Building osgearth_viewer plugin")
    add_subdirectory(osgearth_viewer)
else()
    message(STATUS "osgEarth not found, skipping osgearth_viewer plugin")
endif()
