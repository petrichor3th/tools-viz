set(APP_SOURCES
    main.cpp
    MainWindow.cpp
    MainWindow.h
)

add_executable(ToolsViz WIN32 ${APP_SOURCES})

target_link_libraries(ToolsViz PRIVATE
    ToolsVizCore
    Qt6::Core
    Qt6::Widgets
    Qt6::Quick
    Qt6::QuickWidgets
)

target_include_directories(ToolsViz PRIVATE
    ${CMAKE_SOURCE_DIR}/core/include
)
