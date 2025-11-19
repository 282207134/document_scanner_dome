# Cunning Document Scanner - 智能文档扫描器

一个功能强大的 Flutter 文档扫描插件，提供跨平台的文档扫描能力。

## 功能特性

- 📷 **自动边缘检测** - 智能识别文档边界
- ✂️ **自动裁剪** - 自动裁剪并校正透视
- 📄 **多页扫描** - 支持连续扫描多页（Android）
- 🖼️ **图库导入** - 允许从相册选择图像（Android）
- 💾 **格式控制** - 支持 PNG/JPEG 格式（iOS）
- 🎛️ **质量调节** - 可配置压缩质量（iOS）

## 系统要求

- **Flutter**: >= 2.5.0
- **Dart**: >= 3.0.0  
- **Android**: API 21+ (Android 5.0+)
- **iOS**: 13.0+

## 快速开始

### 1. 添加依赖

```yaml
dependencies:
  cunning_document_scanner: ^1.3.1
```

### 2. Android 配置

在 `android/app/build.gradle` 中：

```gradle
android {
    defaultConfig {
        minSdkVersion 21
    }
}
```

在 `android/app/src/main/AndroidManifest.xml` 中：

```xml
<uses-permission android:name="android.permission.CAMERA" />
```

### 3. iOS 配置

在 `ios/Podfile` 中：

```ruby
platform :ios, '13.0'

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= [
        '$(inherited)',
        'PERMISSION_CAMERA=1',
      ]
    end
  end
end
```

在 `ios/Runner/Info.plist` 中：

```xml
<key>NSCameraUsageDescription</key>
<string>需要使用相机来扫描文档</string>
```

## 使用方法

### 基本用法

```dart
import 'package:cunning_document_scanner/cunning_document_scanner.dart';

// 扫描文档
final images = await CunningDocumentScanner.getPictures();

if (images != null && images.isNotEmpty) {
  print('扫描成功，共 ${images.length} 张图片');
  for (var imagePath in images) {
    print('图片路径: $imagePath');
  }
}
```

### Android 高级用法

```dart
// 限制页数和允许图库导入
final images = await CunningDocumentScanner.getPictures(
  noOfPages: 5,              // 最多 5 页
  isGalleryImportAllowed: true,  // 允许从图库选择
);
```

### iOS 高级用法

```dart
// 使用 JPEG 格式并设置压缩质量
final images = await CunningDocumentScanner.getPictures(
  iosScannerOptions: IosScannerOptions(
    imageFormat: IosImageFormat.jpg,
    jpgCompressionQuality: 0.7,  // 70% 质量
  ),
);
```

## API 参考

### CunningDocumentScanner.getPictures()

启动文档扫描流程。

**参数：**

| 参数 | 类型 | 默认值 | 平台 | 说明 |
|------|------|--------|------|------|
| `noOfPages` | `int` | `100` | Android | 最大可扫描页数 |
| `isGalleryImportAllowed` | `bool` | `false` | Android | 是否允许从图库导入 |
| `iosScannerOptions` | `IosScannerOptions?` | `null` | iOS | iOS 扫描器选项 |

**返回值：**
- `List<String>` - 扫描成功，返回图像路径列表
- `[]` - 用户取消扫描
- `null` - 扫描失败

**异常：**
- `Exception` - 权限被拒绝时抛出

### IosScannerOptions

iOS 扫描器配置选项。

```dart
IosScannerOptions({
  IosImageFormat imageFormat = IosImageFormat.png,  // 图像格式
  double jpgCompressionQuality = 1.0,  // JPEG 压缩质量 (0.0-1.0)
})
```

### IosImageFormat

图像格式枚举：
- `IosImageFormat.jpg` - JPEG 格式
- `IosImageFormat.png` - PNG 格式

## 常见问题

### Q: 如何处理权限被拒绝？

```dart
try {
  final images = await CunningDocumentScanner.getPictures();
} catch (e) {
  if (e.toString().contains('Permission not granted')) {
    // 显示权限说明对话框
    showPermissionDialog();
  }
}
```

### Q: 如何选择合适的图像格式？

- **PNG**: 适用于重要文档（合同、证件等）
- **JPEG (0.8-1.0)**: 适用于一般文档
- **JPEG (0.5-0.7)**: 适用于临时文档
- **JPEG (0.2-0.4)**: 适用于文字识别场景

## 完整示例

查看 [example](example/) 目录获取完整的示例应用程序。

## 技术架构

```
Flutter (Dart)
    ↓
MethodChannel
    ↓
┌─────────────────┬──────────────────┐
│  Android        │     iOS          │
│  (Kotlin)       │   (Swift)        │
├─────────────────┼──────────────────┤
│ Google ML Kit   │   VisionKit      │
│ + 后备扫描器    │   (VNDocument)   │
└─────────────────┴──────────────────┘
```

## 许可证

MIT License - 详见 [LICENSE](LICENSE) 文件

## 致谢

基于 [jachzen/cunning_document_scanner](https://github.com/jachzen/cunning_document_scanner) 创建
