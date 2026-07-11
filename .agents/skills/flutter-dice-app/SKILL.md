---
name: flutter-dice-app
description: 用于当前 dice_roller Flutter 项目。实现页面、Widget、状态、路由、掷骰逻辑、概率模式、历史记录、测试、构建和打包时使用。
---

# Flutter 掷骰子 App

## 项目描述

这是一个离线、单机、无需账号的 Flutter 掷骰子 App。首版只做标准六面骰 D6，支持 1 到 6 颗骰子、掷骰动画、总点数、本次运行内最近 20 条历史记录、设置页和概率模式。

## 能干什么

- 按设计文档实现 App 页面、组件、路由、状态和测试。
- 写或改 `DiceResultGenerator`、`DiceGameStore`、数据模型、页面和 Widget。
- 实现公平随机和概率模式。
- 实现历史记录、清空确认、设置页、动画开关、减少动画适配。
- 补齐 `flutter analyze` 和 `flutter test` 需要的修复。
- 按下面的打包流程生成 Android 或 iOS 构建产物。

## 不能干什么

- 不添加登录、账号、联网、云同步、数据上报、遥测。
- 不添加历史或设置持久化，除非用户明确要求。
- 不添加 D4、D8、D10、D12、D20、多人、积分、胜负规则。
- 不把概率模式伪装成公平随机。
- 不把随机生成逻辑写进页面或 Widget。
- 不在动画过程中重复生成最终结果。
- 不吞异常后假装成功。
- 不引入设计文档之外的依赖，除非先说明原因并得到确认。
- 不做大范围重构，不改无关代码。

## 代码约束

- `DiceResultGenerator` 只负责生成点数，不依赖 UI、Signals、路由或动画。
- `DiceGameStore` 负责 App 生命周期内共享状态和一次掷骰事务。
- `DiceScreen` 可以持有动画控制器，但不能负责正式随机逻辑。
- `HistoryScreen` 只展示历史和触发清空。
- `SettingsScreen` 只修改设置，不直接生成结果。
- 概率配置、掷骰记录等模型使用不可变数据。
- 骰子数量只允许 1 到 6；目标点数只允许 1 到 6；概率只允许 0 到 100。
- `prepareRoll()` 生成一次最终结果并暂存；`commitRoll()` 发布结果并写入一条历史；`cancelRoll()` 丢弃暂存结果且不写历史。
- 历史记录最新优先，最多 20 条，关闭 App 后自然丢失。
- 修改骰子数量、目标点数或目标概率后，清空当前结果，不清空历史。

## 代码风格

- 能用 `StatelessWidget` 就不用 `StatefulWidget`。
- 只有动画、控制器、生命周期、本地临时 UI 状态需要 `StatefulWidget`。
- Widget 构造函数加 `const`。
- 必填参数用 `required`。
- 字段尽量用 `final`。
- 小组件拆出来，页面不要塞满所有 UI 细节。
- `build()` 里不要做随机、写历史、复杂计算或副作用。
- 优先使用命名参数，避免长位置参数。
- 使用 Material 3 和 Flutter Material 图标。
- 图标按钮要有 `tooltip`，重要结果要有语义文本。
- `flutter_screenutil` 只用于间距、圆角、图标、骰子尺寸等数值适配；不要机械地给所有文字套 `.sp`。
- 页面布局用 `LayoutBuilder` 和约束处理小屏、常规手机、宽屏，不靠整体缩放糊弄。

Widget 示例：

```dart
class DiceTotalLabel extends StatelessWidget {
  const DiceTotalLabel({
    super.key,
    required this.total,
  });

  final int total;

  @override
  Widget build(BuildContext context) {
    return Text('合计 $total');
  }
}
```

## 推荐目录结构

```text
lib/
├── main.dart
├── app.dart
├── router/app_router.dart
├── state/dice_game_store.dart
├── models/dice_probability_config.dart
├── models/roll_record.dart
├── services/dice_result_generator.dart
├── screens/dice_screen.dart
├── screens/history_screen.dart
├── screens/settings_screen.dart
└── widgets/
    ├── dice_board.dart
    └── dice_face.dart
```

测试目录按功能拆分：

```text
test/
├── services/dice_result_generator_test.dart
├── state/dice_game_store_test.dart
└── screens/
    ├── navigation_test.dart
    ├── dice_screen_test.dart
    ├── history_screen_test.dart
    └── settings_screen_test.dart
```

## 依赖约束

设计文档要求的依赖是：

- `signals_flutter`
- `go_router`
- `flutter_screenutil`

添加依赖时优先用：

```bash
flutter pub add signals_flutter go_router flutter_screenutil
```

不要手写猜测版本号。当前项目是 App，不发布到 pub.dev，保留 `publish_to: 'none'`。

## 验证

改代码后至少跑：

- `flutter analyze`
- `flutter test`

改格式时跑：

```bash
dart format lib test
```

如果改动影响布局，还要检查小屏、常规手机和宽屏，确认没有溢出、遮挡或按钮不可点。

## 打包

打包前先跑：

```bash
flutter pub get
dart format lib test
flutter analyze
flutter test
```

Android APK：

```bash
flutter build apk --release
```

产物通常在：

```text
build/app/outputs/flutter-apk/app-release.apk
```

Android App Bundle：

```bash
flutter build appbundle --release
```

产物通常在：

```text
build/app/outputs/bundle/release/app-release.aab
```

iOS Release：

```bash
flutter build ios --release
```

iOS 打包需要 macOS、Xcode、签名证书和 Provisioning Profile。没有签名信息时，不要乱改 `ios/` 签名配置；先向用户确认证书、Bundle ID 和发布方式。
