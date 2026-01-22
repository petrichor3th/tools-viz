#ifndef TOOLS_VIZ_MAIN_WINDOW_H
#define TOOLS_VIZ_MAIN_WINDOW_H

#include <QMainWindow>
#include <QMap>

class QMdiArea;
class QMdiSubWindow;
class QMenu;
class QAction;
class QQmlEngine;
class PluginManager;
class IPlugin;

class MainWindow : public QMainWindow
{
    Q_OBJECT

public:
    explicit MainWindow(QWidget* parent = nullptr);
    ~MainWindow();

private slots:
    void onPluginActionTriggered();
    void tileWindows();
    void cascadeWindows();
    void about();

private:
    void setupUi();
    void setupMenus();
    void loadPlugins();
    void createPluginMenus();
    QMdiSubWindow* createPluginWindow(IPlugin* plugin);

private:
    QMdiArea* m_mdiArea;
    QQmlEngine* m_qmlEngine;
    PluginManager* m_pluginManager;
    
    QMenu* m_fileMenu;
    QMenu* m_pluginsMenu;
    QMenu* m_windowMenu;
    QMenu* m_helpMenu;
    
    QMap<QAction*, IPlugin*> m_pluginActions;
};

#endif // TOOLS_VIZ_MAIN_WINDOW_H
