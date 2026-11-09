# [<img src="logo.png" width="20"/>](image.png) DatWeatherDoe

> **Note**
OpenWeatherMap API 2.5 support is ending in June 2024. The app uses WeatherAPI going forward with location support.

- Fetch weather using:
  - Location services
  - Latitude / Longitude
- Configurable polling interval
- Dark mode support
- Supports MacOS 13.0+

## Screenshots

![Screenshot 1](screenshot_1.png)\
![Screenshot 2](screenshot_2.png)

## Installation

### Homebrew Cask

`brew install --cask datweatherdoe`

### Manual

<https://github.com/inderdhir/DatWeatherDoe/releases/latest>

## Using Location Services

If using location, please make sure that the app has permission to access location services on macOS.

`System Preferences > Security & Privacy > Privacy > Location Services`

![Location services screenshot 1](location_services_1.png)
![Location services screenshot 2](location_services_2.png)

## 编译和安装此分支

需要安装 Xcode，并将其选为命令行开发工具。首次编译需要联网，Xcode 会自动下载依赖并缓存到项目的 `build/SourcePackages`。

在仓库根目录运行：

```sh
./build.sh
```

编译成功后，脚本会显示 `build/Build/Products/Release/DatWeatherDoe.app` 的完整路径。退出正在运行的旧版本，再将新生成的应用拖到 Finder 的「应用程序」文件夹。可以将它改名为 `DatWeatherDoe Custom.app`，方便和原版区分。

启动应用后，点开顶部菜单栏的天气图标，在 **WeatherAPI Key** 一栏粘贴密钥，然后点「完成」。密钥保存在本机应用设置中，编译时可留空。 [获取 WeatherAPI 密钥](https://www.weatherapi.com/docs/getting-started/)

## Donate

Buy me a coffee to support the development of this project.

[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/Y8Y211O253)

## Contributing

Please see CONTRIBUTING.md
