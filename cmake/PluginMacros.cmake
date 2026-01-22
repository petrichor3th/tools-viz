# 插件构建宏
# 用法: add_tools_viz_plugin(插件名 源文件...)

function(add_tools_viz_plugin PLUGIN_NAME)
    set(PLUGIN_SOURCES ${ARGN})
    
    add_library(${PLUGIN_NAME} MODULE ${PLUGIN_SOURCES})
    
    target_link_libraries(${PLUGIN_NAME} PRIVATE
        ToolsVizCore
        Qt6::Core
        Qt6::Widgets
        Qt6::Quick
    )
    
    target_include_directories(${PLUGIN_NAME} PRIVATE
        ${CMAKE_SOURCE_DIR}/core/include
    )
    
    # 设置输出目录到 plugins 子目录
    set_target_properties(${PLUGIN_NAME} PROPERTIES
        LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin/plugins
        RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin/plugins
    )

    # 设置文件夹结构
    set_target_properties(${PLUGIN_NAME} PROPERTIES FOLDER "Plugins")
    
    # Windows 下移除 lib 前缀
    if(WIN32)
        set_target_properties(${PLUGIN_NAME} PROPERTIES PREFIX "")
    endif()
endfunction()
