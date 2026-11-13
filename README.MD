# Laterial SDDM Theme

[![License: GPL v3+](https://img.shields.io/badge/license-GPL--3.0--or--later-blue.svg)](LICENSE)

Laterial 是面向 KDE Plasma 6 / SDDM Qt 6 的 Material 3 Expressive 登录主题。它只依赖 Qt Quick 6，不依赖 Plasma 桌面 QML 组件，因此能在 greeter 的独立进程中运行。

## 正式版安装包

运行 `bash tools/package.sh` 会生成可直接交给 Plasma 6“登录屏幕 (SDDM)”加载的正式版文件：

- `release/Laterial-1.0.0.tar.gz`
- `release/Laterial-1.0.0.zip`
- `release/laterial/`：未归档、可直接部署到 `/usr/share/sddm/themes/laterial`
- `release/SHA256SUMS`

在“系统设置 → 登录屏幕 (SDDM)”中选择“从文件安装”，然后选择任一归档。归档顶层只有 `laterial/`，并包含 Plasma 6 要求的 `metadata.desktop`。

## 功能

- 居中、限宽的登录面板；360×640 等窄屏会切换紧凑尺寸。
- 12 小时制时钟，格式为 `9:18 p.m.`，白色文字与柔和阴影。
- 用户名和密码浮动标签。默认用户名优先读取 `defaultUser`，留空时使用 SDDM 上次登录用户。
- 浮动标签通过输入框边框留白显示，不使用额外矩形背景。
- 密码始终以 `*` 掩码；`显示密码` / `隐藏密码` 只改变当前内存中的显示状态。
- `显示密码` / `隐藏密码` 使用无背景的文字按钮，不增加额外面板色块。
- 登录按钮具备禁用、加载、失败提示和按压/涟漪状态。
- 当用户名有效时允许空密码登录，以兼容无密码账户和免密 PAM 配置。
- 按钮已移除按压缩放动画，保留状态层、涟漪和焦点动画。
- 所有涟漪使用控件自身的圆角遮罩，动画期间不会出现直角裁剪残影。
- Material Symbols 图标路径内嵌在 QML 中，并自动跟随主题色。
- 桌面环境直接读取 SDDM `sessionModel`，列出系统发现的全部 X11 / Wayland 会话；优先上次会话，否则选择首个可用会话。
- 桌面环境列表展开时右侧箭头旋转 180°，收起时恢复。
- 箭头在按钮点击时立即开始旋转，不等待列表完全展开。
- 桌面环境列表使用不透明 surface，并带淡入与轻微缩放展开/收起动画。
- 关机、重启、休眠使用 SDDM 电源接口；不可用的能力会禁用并显示提示。
- 壁纸 `cover` 居中裁切缩放；支持 `contain` 与 `stretch`。
- 莫奈取色或手动 MD 配色；手动模式支持角色级和控件级覆盖。
- 壁纸保持清晰，仅在圆角面板区域内进行 GPU 毛玻璃；不支持的 GPU 环境自动使用半透明 surface。
- Tab、Enter、Esc、焦点状态和无动画降级均已覆盖。

## 目录

```text
Laterial-sddm-theme/
├── Main.qml
├── components/        # M3E 控件、主题色、背景与大时钟
├── js/                # 色彩生成与壁纸取样
├── assets/            # 原创默认壁纸 SVG
├── tools/package.sh   # 正式安装包生成
├── metadata.desktop
└── theme.conf
```

## 在 Plasma 6 中使用

安装时把整个主题目录放到 SDDM 主题目录。以下命令需要你自行执行；本次开发没有安装主题，也没有修改系统现有的 SDDM 主题或配置。

```bash
sudo install -d /usr/share/sddm/themes/laterial
sudo cp -a Laterial-sddm-theme/. /usr/share/sddm/themes/laterial/
```

随后打开 Plasma 系统设置中的“登录屏幕 (SDDM)”：

1. 选择 `Laterial` 主题。
2. 直接用该页面更换背景图片。
3. 背景路径会由 KCM 写入主题旁的 `theme.conf.user` 的 `[General] background`，Laterial 在下次 greeter 启动时读取。

KCM 切图后无需修改 `theme.conf`。`theme.conf.user` 由 Plasma 管理，不要把它纳入主题源码。

## 颜色配置

配置文件是 [theme.conf](theme.conf)。SDDM 将 INI 分组路径暴露为 `General/...`、`Colors/...`、`Overrides/...` 键。

### 莫奈取色

```ini
[General]
colorMode=monet
colorScheme=dark
```

`monet` 会从壁纸低采样求出主色并生成 Material 深色或浅色角色集。此模式严格忽略 `manualScheme`、全部 `[Colors]` 和全部 `[Overrides]`。

壁纸解码和大图载入较慢时，界面会先以安全的 M3 baseline 色启动，取色完成后切换到壁纸色。

### 手动 MD 配色

```ini
[General]
colorMode=manual
manualScheme=LightGreen
colorScheme=dark
```

支持的名称不区分大小写：

`Red`、`Pink`、`Purple`、`DeepPurple`、`Indigo`、`Blue`、`LightBlue`、`Cyan`、`Teal`、`Green`、`LightGreen`、`Lime`、`Yellow`、`Amber`、`Orange`、`DeepOrange`、`Brown`、`BlueGrey`、`Grey`。

指定预设后，未覆盖控件使用该方案默认角色色。只填写需要的角色即可，其余颜色保持不变：

```ini
[Colors]
primary=#5F8D4E
surface=#111814
error=#FFB4AB
```

也可以使用完全自定义的种子色：

```ini
[General]
colorMode=manual
manualScheme=custom
customPrimary=#D97706
```

### 控件级覆盖

`[Colors]` 按 Material 角色覆盖；`[Overrides]` 只覆盖指定控件，优先级最高。莫奈模式仍会忽略全部覆盖。

```ini
[Overrides]
loginButton.background=#FFD54F
loginButton.text=#201A00
dialog.surface=#CC14201A
input.focus=#A6E36F
session.background=#CC1A2A21
session.popupBackground=#1A2A21
power.background=#B3202B23
clock.text=#FFFFFF
error.text=#FFB4AB
```

颜色支持 `#RGB`、`#RRGGBB`、`#AARRGGBB` 以及 `rgb(...)` / `rgba(...)`。无效值自动回退到当前角色默认色。`theme.conf` 中提供了完整覆盖键清单。

## 背景、模糊和性能

```ini
[General]
background=assets/default-wallpaper.svg
backgroundFillMode=cover
blurEnabled=true
panelBlurStrength=80
animationsEnabled=true
```

- `background` 可写主题相对路径或绝对路径；文件名会被原样解析，因此以 `@` 开头的文件也可以正常加载。
- `backgroundFillMode=cover` 是默认值，使用 `PreserveAspectCrop` 居中裁切；另有 `contain` 和 `stretch`。
- `panelBlurStrength` 范围是 `0–100`，表示面板局部毛玻璃强度；默认 `80`。
- 壁纸本身不做全局模糊。面板后方区域以当前面板分辨率捕获并一次性模糊，不会让整张壁纸发糊或出现低采样锯齿。
- `GraphicsInfo.Software` 或 `blurEnabled=false` 时，自动保留清晰壁纸与半透明 surface，不影响文字可读性和输入。
- `animationsEnabled=false` 会关闭入场、涟漪、状态层和等待动画。

## 交互

- `Tab`：用户名 → 密码 → 显示密码 → 登录 → 桌面环境 → 关机 → 重启 → 休眠 → 用户名。
- 会话列表支持滚轮、滚动条、方向键、Home / End、Enter / 空格选择和 Esc 收起。
- 用户名中按 `Enter` 聚焦密码；密码中按 `Enter` 登录。
- 密码可以为空；输入用户名后可直接点击“登录”或按 `Enter`。
- `Esc` 关闭会话列表、恢复密码掩码、清除非敏感提示；不会退出或注销登录界面。
- 登录失败不会显示 PAM 的敏感细节，只显示“用户名或密码不正确”，并清空密码。
- 密码不会写入日志、`theme.conf` 或 `theme.conf.user`。
- 登录请求会携带当前选择会话的索引；电源按钮分别调用 SDDM 的 `powerOff()`、`reboot()` 和 `hibernate()`。
- 独立 demo 中的电源按钮只显示模拟反馈，不会真正关闭或重启电脑。

## 系统要求

- KDE Plasma 6
- SDDM 0.21 或兼容版本
- Qt 6 / Qt Quick Controls 2
- `QtQuick.Effects`

重新打包还需要 `sddm-greeter-qt6`、`tar`、`bsdtar`。

## 本地打包

```bash
cd Laterial-sddm-theme
bash tools/package.sh
```

打包脚本会检查元数据、运行一次 `sddm-greeter-qt6 --test-mode` 加载检查，然后生成 `release/` 下的 KDE 主题归档。它不会修改系统当前主题。

## 兼容性说明

- 目标为 KDE Plasma 6、SDDM 0.21 / Qt 6 及 `QtQuick.Effects`。
- 不依赖 Breeze、Kirigami 或 Plasma Controls，因此主题安装位置变化不会破坏组件导入。
- 默认时钟固定符合需求的 12 小时 `a.m.` / `p.m.` 格式；`clockFormat=12h` 为兼容配置保留。
- 桌面环境名称由 SDDM `sessionModel` 提供；若系统只暴露一个会话，选择器仍显示该会话，但菜单中没有冗余项。

## 恢复默认登录主题

如果新主题导致登录界面不可用，可在 TTY 中把 `/etc/sddm.conf.d/kde_settings.conf` 的 `[Theme] Current` 改为 `breeze`，然后重启系统或执行：

```bash
sudo systemctl restart sddm
```

在可正常登录的 Plasma 桌面中，也可以直接通过“系统设置 → 登录屏幕 (SDDM)”切换回 Breeze。

## 安全与隐私

- 主题不会记录密码，不会把密码写入配置文件或日志。
- `theme.conf.user` 是本机 KCM 配置，不属于正式安装包。
- 本地测试壁纸和测试截图不会包含在正式安装包中。

## License

Copyright (C) 2026 limou233

本项目的 QML、JavaScript、脚本、文档及原创默认壁纸资源采用 **GNU General Public License v3.0 or later**（`GPL-3.0-or-later`）授权。

你可以按照自由软件基金会发布的 GNU 通用公共许可证第 3 版或后续版本重新分发和修改本项目。完整许可证文本见 [LICENSE](LICENSE)。

本项目不提供任何担保；完整免责声明和授权条款以许可证正文为准。

Material Symbols 图标路径来自 Google Material Symbols 项目，遵循其上游 Apache License 2.0；这些路径已内嵌在 QML 源码中。
