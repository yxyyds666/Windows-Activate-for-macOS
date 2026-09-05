#!/usr/bin/env bash
#
# 把 SwiftPM 产物打包成可以双击运行的 .app。
#
#   ./Scripts/build-app.sh              # 当前架构，release
#   ./Scripts/build-app.sh --universal  # arm64 + x86_64
#   ./Scripts/build-app.sh --debug      # debug 配置
#
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_NAME="WindowsActivate"
CONFIGURATION="release"
ARCH_FLAGS=()

for argument in "$@"; do
    case "$argument" in
        --universal) ARCH_FLAGS=(--arch arm64 --arch x86_64) ;;
        --debug) CONFIGURATION="debug" ;;
        *) echo "未知参数：$argument" >&2; exit 1 ;;
    esac
done

cd "$ROOT"

echo "==> 编译（${CONFIGURATION}）"
# ${arr[@]+...} 是为了兼容 bash 3.2：空数组在 set -u 下直接展开会报错。
swift build -c "$CONFIGURATION" ${ARCH_FLAGS[@]+"${ARCH_FLAGS[@]}"}
BIN_PATH="$(swift build -c "$CONFIGURATION" ${ARCH_FLAGS[@]+"${ARCH_FLAGS[@]}"} --show-bin-path)"

ICON="$ROOT/Resources/AppIcon.icns"
if [[ ! -f "$ICON" ]]; then
    echo "==> 生成应用图标"
    ICONSET="$(mktemp -d)/AppIcon.iconset"
    mkdir -p "$ICONSET"
    swift "$ROOT/Scripts/make-icon.swift" "$ICONSET" > /dev/null
    iconutil -c icns "$ICONSET" -o "$ICON"
fi

APP="$ROOT/dist/$APP_NAME.app"
echo "==> 组装 $APP"
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
cp "$BIN_PATH/$APP_NAME" "$APP/Contents/MacOS/$APP_NAME"
cp "$ROOT/Resources/Info.plist" "$APP/Contents/Info.plist"
cp "$ICON" "$APP/Contents/Resources/AppIcon.icns"
printf 'APPL????' > "$APP/Contents/PkgInfo"

# 临时签名：SMAppService（开机自启）要求 .app 至少是签过名的。
if codesign --force --sign - "$APP" 2>/dev/null; then
    echo "==> 已完成临时签名"
else
    echo "==> 警告：临时签名失败，开机自启可能不可用" >&2
fi

echo
echo "打包完成：$APP"
echo "运行：open \"$APP\"     安装：cp -R \"$APP\" /Applications/"
