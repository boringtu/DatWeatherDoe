#!/bin/sh
set -eu;

# 以脚本所在目录为项目根目录，支持从其他目录启动
cd "$(dirname "$0")";

# 使用本地签名和独立的应用标识，保留自编译版的设置
xcodebuild -project DatWeatherDoe.xcodeproj -scheme DatWeatherDoe \
  -configuration Release -destination "platform=macOS,arch=$(uname -m)" \
  -derivedDataPath build \
  CODE_SIGN_IDENTITY=- DEVELOPMENT_TEAM= \
  PRODUCT_BUNDLE_IDENTIFIER=local.DatWeatherDoe.Custom \
  INFOPLIST_KEY_CFBundleDisplayName='DatWeatherDoe Custom' build;

# 仅在构建成功后显示可安装的应用路径
printf '\n应用已生成：%s\n' "$PWD/build/Build/Products/Release/DatWeatherDoe.app";
