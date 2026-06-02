# 打卡记录 (Check-In App)

一款简约风格的日常打卡应用，帮助你养成好习惯、记录每一天的坚持与成长。

## 功能特性

- **日常打卡** — 支持每日/每周/每月/自定义频率的任务管理
- **日历视图** — 独立日历页面，直观查看打卡记录与打卡标记
- **智能首页** — 左右滑动切换日期，一键回到今天
- **统计分析** — 周/月/年维度的打卡次数、项目分布、连续打卡趋势
- **成就系统** — 铜/银/金/钻石四级成就，激励持续打卡
- **个性化设置** — 12种主题颜色可选，支持自定义背景图片
- **任务编辑** — 长按任务进入完整编辑页面，支持修改图标、颜色、频率
- **数据导出** — 支持导出为 CSV 或 JSON 格式
- **本地通知** — 可设置每日打卡提醒
- **深色模式** — 一键切换深色/浅色主题

## 技术栈

| 类别 | 技术 |
|------|------|
| 框架 | Flutter 3.2+ |
| 状态管理 | Riverpod |
| 本地数据库 | Hive |
| 日历组件 | table_calendar |
| 图表 | fl_chart |
| 动画 | flutter_animate |
| 通知 | flutter_local_notifications |

## 项目结构

```
lib/
├── main.dart                    # 入口
├── app.dart                     # 根组件与导航
├── core/
│   ├── theme/                   # 主题与颜色系统
│   ├── constants/               # 常量定义
│   └── utils/                   # 日期工具、导出工具
├── data/
│   ├── models/                  # Hive 数据模型
│   ├── repositories/            # 数据访问层
│   └── services/                # 通知服务
├── providers/                   # Riverpod 状态管理
└── ui/
    ├── screens/                 # 页面
    │   ├── home/                # 首页 + 任务编辑页
    │   ├── calendar/            # 日历页
    │   ├── stats/               # 统计页
    │   ├── achievements/        # 成就页
    │   ├── settings/            # 设置页
    │   ├── onboarding/          # 引导页
    │   └── splash/              # 启动页
    ├── widgets/                 # 可复用组件
    └── dialogs/                 # 弹窗组件
```

## 快速开始

### 环境要求

- Flutter SDK >= 3.2.0
- Dart SDK >= 3.2.0

### 安装运行

```bash
# 克隆仓库
git clone https://github.com/XX-XXJ/checkin_app.git
cd checkin_app

# 安装依赖
flutter pub get

# 运行应用
flutter run
```

### 构建发布版

```bash
# 构建 APK
flutter build apk --release --no-tree-shake-icons

# 构建 App Bundle
flutter build appbundle --release --no-tree-shake-icons
```

### 生成应用图标

```bash
dart run tool/generate_icon.dart
dart run flutter_launcher_icons
```

## v1.1.0 更新内容

- 首页移除日历嵌入，改为独立日历页面，解决滑动卡顿问题
- 新增日期左右切换与「回到今天」快捷按钮
- 新增个性化设置：主题颜色切换 + 自定义背景图片
- 长按任务进入完整编辑页面（支持修改图标/颜色/频率）
- 应用图标改为简约白底黑色对勾风格
- 启动页与新图标风格统一

## 许可证

MIT License

