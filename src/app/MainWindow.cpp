#include "MainWindow.h"
#include "core/PluginManager.h"
#include "core/IPlugin.h"

#include <QMdiArea>
#include <QMdiSubWindow>
#include <QMenuBar>
#include <QMenu>
#include <QAction>
#include <QStatusBar>
#include <QApplication>
#include <QMessageBox>
#include <QDir>
#include <QQmlEngine>
#include <QQuickWidget>

MainWindow::MainWindow(QWidget* parent)
    : QMainWindow(parent)
    , m_mdiArea(new QMdiArea(this))
    , m_qmlEngine(new QQmlEngine(this))
    , m_pluginManager(new PluginManager(this))
{
    setupUi();
    setupMenus();
    loadPlugins();
    createPluginMenus();
}

MainWindow::~MainWindow()
{
}

void MainWindow::setupUi()
{
    setWindowTitle(tr("Tools Viz"));
    resize(1200, 800);

    m_mdiArea->setHorizontalScrollBarPolicy(Qt::ScrollBarAsNeeded);
    m_mdiArea->setVerticalScrollBarPolicy(Qt::ScrollBarAsNeeded);
    m_mdiArea->setViewMode(QMdiArea::SubWindowView);
    setCentralWidget(m_mdiArea);

    statusBar()->showMessage(tr("Ready"));
}

void MainWindow::setupMenus()
{
    // 文件菜单
    m_fileMenu = menuBar()->addMenu(tr("&File"));
    QAction* exitAction = m_fileMenu->addAction(tr("E&xit"));
    connect(exitAction, &QAction::triggered, this, &QWidget::close);

    // 插件菜单
    m_pluginsMenu = menuBar()->addMenu(tr("&Plugins"));

    // 窗口菜单
    m_windowMenu = menuBar()->addMenu(tr("&Window"));
    QAction* tileAction = m_windowMenu->addAction(tr("&Tile"));
    connect(tileAction, &QAction::triggered, this, &MainWindow::tileWindows);
    QAction* cascadeAction = m_windowMenu->addAction(tr("&Cascade"));
    connect(cascadeAction, &QAction::triggered, this, &MainWindow::cascadeWindows);

    // 帮助菜单
    m_helpMenu = menuBar()->addMenu(tr("&Help"));
    QAction* aboutAction = m_helpMenu->addAction(tr("&About"));
    connect(aboutAction, &QAction::triggered, this, &MainWindow::about);
}

void MainWindow::loadPlugins()
{
    // 查找插件目录（相对于可执行文件）
    QString pluginDir = QApplication::applicationDirPath() + "/plugins";
    
    connect(m_pluginManager, &PluginManager::pluginLoaded, this, [this](const QString& name) {
        statusBar()->showMessage(tr("Loaded plugin: %1").arg(name), 3000);
    });
    
    connect(m_pluginManager, &PluginManager::pluginLoadFailed, this, [this](const QString& path, const QString& error) {
        statusBar()->showMessage(tr("Failed to load: %1").arg(path), 5000);
    });

    m_pluginManager->loadPlugins(pluginDir);
    
    // 让插件注册QML类型
    for (IPlugin* plugin : m_pluginManager->getAllPlugins()) {
        plugin->registerQmlTypes(m_qmlEngine);
    }
}

void MainWindow::createPluginMenus()
{
    const QList<IPlugin*> plugins = m_pluginManager->getAllPlugins();
    
    if (plugins.isEmpty()) {
        QAction* emptyAction = m_pluginsMenu->addAction(tr("(No plugins loaded)"));
        emptyAction->setEnabled(false);
        return;
    }

    for (IPlugin* plugin : plugins) {
        QAction* action = m_pluginsMenu->addAction(plugin->name());
        action->setToolTip(plugin->description());
        m_pluginActions.insert(action, plugin);
        connect(action, &QAction::triggered, this, &MainWindow::onPluginActionTriggered);
    }
}

void MainWindow::onPluginActionTriggered()
{
    QAction* action = qobject_cast<QAction*>(sender());
    if (!action) return;

    IPlugin* plugin = m_pluginActions.value(action, nullptr);
    if (!plugin) return;

    createPluginWindow(plugin);
}

QMdiSubWindow* MainWindow::createPluginWindow(IPlugin* plugin)
{
    QUrl qmlUrl = plugin->qmlUrl();
    if (!qmlUrl.isValid()) {
        QMessageBox::warning(this, tr("Error"), 
            tr("Invalid QML URL for plugin: %1").arg(plugin->name()));
        return nullptr;
    }

    // 创建QQuickWidget加载QML
    QQuickWidget* quickWidget = new QQuickWidget(m_qmlEngine, m_mdiArea);
    quickWidget->setResizeMode(QQuickWidget::SizeRootObjectToView);
    quickWidget->setSource(qmlUrl);
    
    // 检查QML加载错误
    if (quickWidget->status() == QQuickWidget::Error) {
        QString errors;
        for (const QQmlError& error : quickWidget->errors()) {
            errors += error.toString() + "\n";
        }
        QMessageBox::warning(this, tr("QML Error"), 
            tr("Failed to load QML for plugin %1:\n%2").arg(plugin->name(), errors));
        delete quickWidget;
        return nullptr;
    }

    QMdiSubWindow* subWindow = m_mdiArea->addSubWindow(quickWidget);
    subWindow->setWindowTitle(plugin->name());
    subWindow->resize(600, 400);
    subWindow->show();

    return subWindow;
}

void MainWindow::tileWindows()
{
    m_mdiArea->tileSubWindows();
}

void MainWindow::cascadeWindows()
{
    m_mdiArea->cascadeSubWindows();
}

void MainWindow::about()
{
    QMessageBox::about(this, tr("About Tools Viz"),
        tr("<h2>Tools Viz</h2>"
           "<p>Version 1.0.0</p>"
           "<p>A plugin-based tools visualization framework.</p>"
           "<p>Built with Qt %1</p>").arg(qVersion()));
}
