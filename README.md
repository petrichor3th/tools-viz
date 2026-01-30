# ToolsViz

[待补充]

## 项目简介

[待补充]

## 系统要求

- **操作系统**: Windows 10/11 (64-bit)
- **编译器**: Visual Studio 2019/2022 (MSVC v142/v143)
- **CMake**: >= 3.16
- **Git**: 用于拉取依赖源码

## 项目结构

```
ToolsViz/
├── CMakeLists.txt          # 主构建文件
├── cmake/
│   ├── Externals.cmake     # SuperBuild 入口
│   └── BuildMacros.cmake   # 构建辅助宏
├── superbuild/             # 第三方依赖构建配置
│   ├── Versions.cmake      # 版本集中管理
│   ├── Macros.cmake        # 通用构建宏
│   ├── deps/               # 依赖配置（按版本号命名）
│   │   ├── zlib-1.3.1.cmake
│   │   ├── curl-8.18.0.cmake
│   │   ├── libtiff-4.7.1.cmake
│   │   ├── sqlite-3.50.2.cmake
│   │   ├── proj-9.4.1.cmake
│   │   ├── gdal-3.12.1.cmake
│   │   ├── glew-2.3.1.cmake
│   │   ├── osg-3.6.5.cmake
│   │   └── osgearth-3.7.2.cmake
│   └── patches/            # 源码补丁
│       ├── osg-3.6.5-cpp17.cmake
│       └── osgearth-3.7.2-gdal-namespace.cmake
├── src/
│   ├── app/                # 主应用程序
│   ├── core/               # 核心库（插件管理）
│   └── plugins/            # 插件模块
│       └── osgearth_viewer/
└── docs/                   # 文档
    ├── Doxyfile            # Doxygen 配置
    └── build_docs.cmake    # 文档生成脚本
```

## 快速开始

### 1. 克隆项目

```bash
git clone <repository-url>
cd ToolsViz
```

### 2. 配置构建

```bash
# 创建构建目录
mkdir build && cd build

# 配置 (SuperBuild 模式，自动构建所有依赖)
cmake .. -G "Visual Studio 17 2022" -A x64 -DCMAKE_BUILD_TYPE=Release
```

### 3. 编译

```bash
# 使用 CMake 构建
cmake --build . --config Release --parallel

# 或使用 Visual Studio 打开 .sln 文件编译
```

## 构建选项

| 选项 | 默认值 | 描述 |
|------|--------|------|
| `USE_SUPERBUILD` | ON | 使用 SuperBuild 模式构建依赖 |
| `BUILD_OSGEARTH` | ON | 构建 osgEarth 依赖 |
| `CMAKE_BUILD_TYPE` | Release | 构建类型 (Debug/Release/RelWithDebInfo) |

### SuperBuild vs Direct Build

- **SuperBuild 模式** (`USE_SUPERBUILD=ON`): 自动从源码构建所有第三方依赖，首次编译耗时较长，但无需手动安装依赖。

- **Direct Build 模式** (`USE_SUPERBUILD=OFF`): 假定系统已安装所有依赖，编译速度快，适合 CI/CD 或已有依赖环境。

## 第三方依赖

SuperBuild 自动构建以下依赖：

| 库 | 版本 | 用途 |
|----|------|------|
| zlib | 1.3.1 | 通用压缩库 |
| libcurl | 8.18.0 | HTTP/网络传输 |
| libtiff | 4.7.1 | TIFF 图像支持 |
| SQLite3 | 3.50.2 | 数据库 (PROJ 依赖) |
| PROJ | 9.4.1 | 地理坐标投影 |
| GDAL | 3.12.1 | 地理空间数据抽象 |
| GLEW | 2.3.1 | OpenGL 扩展 |
| OpenSceneGraph | 3.6.5 | 3D 图形渲染 |
| osgEarth | 3.7.2 | 地理空间可视化引擎 |

## 生成 API 文档

需要安装 [Doxygen](https://www.doxygen.nl/)：

```bash
# Windows (使用 Chocolatey)
choco install doxygen.install

# 生成文档
cmake -P docs/build_docs.cmake
```

文档输出位置：`docs/api/html/index.html`

## 二次开发

### 插件开发

1. 在 `src/plugins/` 下创建新目录
2. 实现 `IPlugin` 接口
3. 创建 CMakeLists.txt
4. 在 `src/plugins/CMakeLists.txt` 中添加子目录

示例插件结构：

```cpp
// MyPlugin.h
#include <core/IPlugin.h>

class MyPlugin : public IPlugin {
public:
    QString name() const override { return "MyPlugin"; }
    QString version() const override { return "1.0.0"; }
    bool initialize() override;
    void shutdown() override;
};
```

### 核心 API

- `PluginManager`: 插件加载与管理
- `IPlugin`: 插件接口基类
- `PluginMetadata`: 插件元数据

详细 API 请参考生成的 Doxygen 文档。

## 常见问题

### Q: 构建时报 PROJ 找不到

确保 SQLite3 已正确构建，检查 `build/install/lib/sqlite3.lib` 是否存在。

### Q: OSG 编译报 std::byte 冲突

项目已包含自动补丁 (`superbuild/patches/osg-3.6.5-cpp17.cmake`)，会自动修复此问题。

### Q: 如何清理重新构建

```bash
# 删除构建目录
rm -rf build

# 重新配置
mkdir build && cd build
cmake .. -G "Visual Studio 17 2022" -A x64
```

## 许可证

[待补充]

## 联系方式

[待补充]
