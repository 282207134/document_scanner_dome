# Cunning Document Scanner 中文文档

## 目录

1. [简介](#简介)
2. [系统要求](#系统要求)
3. [安装配置](#安装配置)
4. [快速开始](#快速开始)
5. [详细用法](#详细用法)
6. [API 参考](#api-参考)
7. [平台特定功能](#平台特定功能)
8. [常见问题](#常见问题)
9. [故障排除](#故障排除)
10. [最佳实践](#最佳实践)

## 简介

Cunning Document Scanner 是一个功能强大的 Flutter 文档扫描插件，提供跨平台的文档扫描能力。它使用原生平台的文档扫描 API，在 Android 上使用 Google ML Kit，在 iOS 上使用 VisionKit，确保最佳的性能和用户体验。

### 主要特性

- **自动边缘检测**：智能识别文档边界
- **自动裁剪**：自动裁剪并校正透视
- **多页扫描**：支持连续扫描多个页面（Android）
- **图库导入**：允许从相册选择图像（Android）
- **灵活的输出格式**：支持 PNG 和 JPEG 格式（iOS）
- **质量控制**：可配置的压缩质量（iOS）
- **权限管理**：自动处理相机权限

## 系统要求

### Flutter 环境
- Flutter SDK: >= 2.5.0
- Dart SDK: >= 3.0.0

### Android
- 最低 SDK 版本: API 21 (Android 5.0 Lollipop)
- 目标 SDK 版本: API 33+
- Google Play Services (用于 ML Kit)

### iOS
- 最低系统版本: iOS 13.0
- Xcode: 12.0+
- CocoaPods

## 安装配置

### 1. 添加依赖

在您的 `pubspec.yaml` 文件中添加：

```yaml
dependencies:
  cunning_document_scanner: ^1.3.1
```

然后运行：

```bash
flutter pub get
```

### 2. Android 配置

#### 2.1 更新 build.gradle

在 `android/app/build.gradle` 中设置最低 SDK 版本：

```gradle
android {
    defaultConfig {
        minSdkVersion 21  // 必须至少为 21
        targetSdkVersion 33
    }
}
```

#### 2.2 添加相机权限

在 `android/app/src/main/AndroidManifest.xml` 中添加：

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- 相机权限 -->
    <uses-permission android:name="android.permission.CAMERA" />
    
    <!-- 可选：如果需要从图库导入 -->
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
    
    <application>
        ...
    </application>
</manifest>
```

### 3. iOS 配置

#### 3.1 更新 Podfile

在 `ios/Podfile` 中设置最低 iOS 版本：

```ruby
platform :ios, '13.0'
```

#### 3.2 配置相机权限

在 `ios/Runner/Info.plist` 中添加相机使用说明：

```xml
<dict>
    ...
    <key>NSCameraUsageDescription</key>
    <string>需要使用相机来扫描文档</string>
    ...
</dict>
```

#### 3.3 配置权限处理器

在 `ios/Podfile` 中添加权限宏定义：

```ruby
post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
    
    # 添加权限配置
    target.build_configurations.each do |config|
      config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= [
        '$(inherited)',
        
        ## 启用相机权限
        'PERMISSION_CAMERA=1',
      ]
    end
  end
end
```

## 快速开始

### 基本示例

```dart
import 'package:flutter/material.dart';
import 'package:cunning_document_scanner/cunning_document_scanner.dart';

class DocumentScannerDemo extends StatefulWidget {
  @override
  _DocumentScannerDemoState createState() => _DocumentScannerDemoState();
}

class _DocumentScannerDemoState extends State<DocumentScannerDemo> {
  List<String> _scannedImages = [];

  Future<void> _scanDocument() async {
    try {
      // 启动文档扫描
      final images = await CunningDocumentScanner.getPictures();
      
      if (images != null && images.isNotEmpty) {
        setState(() {
          _scannedImages = images;
        });
        
        // 显示成功消息
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('成功扫描 ${images.length} 张图片')),
        );
      } else {
        // 用户取消了扫描
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('扫描已取消')),
        );
      }
    } catch (e) {
      // 处理错误（例如权限被拒绝）
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('扫描失败: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('文档扫描器示例'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _scanDocument,
              child: Text('扫描文档'),
            ),
            SizedBox(height: 20),
            Text('已扫描图片数量: ${_scannedImages.length}'),
          ],
        ),
      ),
    );
  }
}
```

## 详细用法

### Android 高级用法

#### 限制页数

```dart
// 只允许扫描 1 页
final images = await CunningDocumentScanner.getPictures(
  noOfPages: 1,
);

// 允许扫描最多 5 页
final images = await CunningDocumentScanner.getPictures(
  noOfPages: 5,
);
```

#### 允许从图库导入

```dart
final images = await CunningDocumentScanner.getPictures(
  noOfPages: 10,
  isGalleryImportAllowed: true,  // 用户可以从图库选择图像
);
```

#### 完整 Android 配置

```dart
final images = await CunningDocumentScanner.getPictures(
  noOfPages: 3,                   // 最多 3 页
  isGalleryImportAllowed: true,   // 允许图库导入
);
```

### iOS 高级用法

#### 使用 PNG 格式（默认）

```dart
final images = await CunningDocumentScanner.getPictures(
  iosScannerOptions: IosScannerOptions(
    imageFormat: IosImageFormat.png,
  ),
);
```

#### 使用 JPEG 格式并设置质量

```dart
// 高质量 JPEG（80% 质量）
final images = await CunningDocumentScanner.getPictures(
  iosScannerOptions: IosScannerOptions(
    imageFormat: IosImageFormat.jpg,
    jpgCompressionQuality: 0.8,
  ),
);

// 中等质量 JPEG（50% 质量，文件更小）
final images = await CunningDocumentScanner.getPictures(
  iosScannerOptions: IosScannerOptions(
    imageFormat: IosImageFormat.jpg,
    jpgCompressionQuality: 0.5,
  ),
);

// 低质量 JPEG（20% 质量，文件最小）
final images = await CunningDocumentScanner.getPictures(
  iosScannerOptions: IosScannerOptions(
    imageFormat: IosImageFormat.jpg,
    jpgCompressionQuality: 0.2,
  ),
);
```

### 显示扫描结果

```dart
import 'dart:io';

class ScannedImagesView extends StatelessWidget {
  final List<String> imagePaths;

  ScannedImagesView({required this.imagePaths});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('扫描结果 (${imagePaths.length} 张)'),
      ),
      body: ListView.builder(
        itemCount: imagePaths.length,
        itemBuilder: (context, index) {
          return Card(
            margin: EdgeInsets.all(8),
            child: Column(
              children: [
                Image.file(
                  File(imagePaths[index]),
                  fit: BoxFit.cover,
                ),
                Padding(
                  padding: EdgeInsets.all(8),
                  child: Text('第 ${index + 1} 页'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
```

## API 参考

### CunningDocumentScanner 类

#### getPictures 方法

启动文档扫描流程。

**签名：**
```dart
static Future<List<String>?> getPictures({
  int noOfPages = 100,
  bool isGalleryImportAllowed = false,
  IosScannerOptions? iosScannerOptions,
})
```

**参数：**

| 参数 | 类型 | 默认值 | 平台 | 说明 |
|------|------|--------|------|------|
| `noOfPages` | `int` | `100` | Android | 最大可扫描页数 |
| `isGalleryImportAllowed` | `bool` | `false` | Android | 是否允许从图库导入 |
| `iosScannerOptions` | `IosScannerOptions?` | `null` | iOS | iOS 扫描器选项 |

**返回值：**

- `Future<List<String>?>`: 扫描的图像文件路径列表
  - 成功: 返回包含图像路径的列表
  - 取消: 返回空列表 `[]`
  - 失败: 返回 `null`

**异常：**

- `Exception`: 如果相机权限被拒绝

### IosScannerOptions 类

iOS 扫描器配置选项。

**构造函数：**
```dart
const IosScannerOptions({
  this.imageFormat = IosImageFormat.png,
  this.jpgCompressionQuality = 1.0,
})
```

**属性：**

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `imageFormat` | `IosImageFormat` | `IosImageFormat.png` | 输出图像格式 |
| `jpgCompressionQuality` | `double` | `1.0` | JPEG 压缩质量 (0.0-1.0) |

### IosImageFormat 枚举

定义支持的图像格式。

**值：**

| 值 | 说明 |
|----|------|
| `jpg` | JPEG 格式 - 有损压缩，文件较小 |
| `png` | PNG 格式 - 无损压缩，质量最高 |

## 平台特定功能

### Android 特定

#### 多页扫描
Android 支持在一次扫描会话中扫描多个页面。

```dart
final images = await CunningDocumentScanner.getPictures(
  noOfPages: 10,  // 最多扫描 10 页
);
```

#### 图库导入
Android 允许用户从设备图库中选择已有的图像进行处理。

```dart
final images = await CunningDocumentScanner.getPictures(
  isGalleryImportAllowed: true,
);
```

#### 后备扫描器
如果设备不支持 Google ML Kit，插件会自动使用后备实现。

### iOS 特定

#### 图像格式选择
iOS 支持 PNG 和 JPEG 两种输出格式。

```dart
// PNG - 无损，文件大
final pngImages = await CunningDocumentScanner.getPictures(
  iosScannerOptions: IosScannerOptions(
    imageFormat: IosImageFormat.png,
  ),
);

// JPEG - 有损，文件小
final jpgImages = await CunningDocumentScanner.getPictures(
  iosScannerOptions: IosScannerOptions(
    imageFormat: IosImageFormat.jpg,
  ),
);
```

#### JPEG 质量控制
当使用 JPEG 格式时，可以精确控制压缩质量。

```dart
// 质量对比
final highQuality = await CunningDocumentScanner.getPictures(
  iosScannerOptions: IosScannerOptions(
    imageFormat: IosImageFormat.jpg,
    jpgCompressionQuality: 0.9,  // 高质量，文件较大
  ),
);

final lowQuality = await CunningDocumentScanner.getPictures(
  iosScannerOptions: IosScannerOptions(
    imageFormat: IosImageFormat.jpg,
    jpgCompressionQuality: 0.3,  // 低质量，文件很小
  ),
);
```

## 常见问题

### Q1: 如何处理权限被拒绝？

**A:** 使用 try-catch 捕获异常并向用户说明：

```dart
try {
  final images = await CunningDocumentScanner.getPictures();
  // 处理结果
} catch (e) {
  if (e.toString().contains('Permission not granted')) {
    // 显示权限说明对话框
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('需要相机权限'),
        content: Text('请在设置中允许应用访问相机以扫描文档。'),
        actions: [
          TextButton(
            onPressed: () {
              // 打开应用设置
              openAppSettings();
            },
            child: Text('去设置'),
          ),
        ],
      ),
    );
  }
}
```

### Q2: 如何选择合适的图像格式？

**A:** 根据使用场景选择：

- **PNG**: 适用于需要保持最高质量的场景，如合同、身份证等重要文档
- **JPEG (高质量 0.8-1.0)**: 适用于一般文档，平衡质量和文件大小
- **JPEG (中等质量 0.5-0.7)**: 适用于临时文档或需要节省存储空间
- **JPEG (低质量 0.2-0.4)**: 适用于仅需要文字识别的场景

### Q3: 扫描结果为 null 是什么原因？

**A:** 可能的原因：

1. 权限被拒绝
2. 设备不支持文档扫描
3. 系统服务不可用

建议在使用前检查并处理这些情况。

### Q4: 如何实现批量扫描？

**A:** Android 平台原生支持，iOS 需要多次调用：

```dart
// Android: 一次扫描多页
final androidImages = await CunningDocumentScanner.getPictures(
  noOfPages: 10,
);

// iOS: 需要循环调用
List<String> iosImages = [];
for (int i = 0; i < maxPages; i++) {
  final images = await CunningDocumentScanner.getPictures();
  if (images == null || images.isEmpty) break;
  iosImages.addAll(images);
}
```

## 故障排除

### Android 问题

#### 问题 1: Google ML Kit 不可用

**症状**: 扫描器无法启动或显示错误

**解决方案**:
1. 确保设备已安装 Google Play Services
2. 更新 Google Play Services 到最新版本
3. 插件会自动回退到自定义扫描器实现

#### 问题 2: 权限请求失败

**症状**: 应用崩溃或无法访问相机

**解决方案**:
```gradle
// 在 build.gradle 中确保：
android {
    defaultConfig {
        minSdkVersion 21  // 至少 21
    }
}
```

### iOS 问题

#### 问题 1: 编译错误

**症状**: Xcode 编译失败

**解决方案**:
```bash
cd ios
rm -rf Pods Podfile.lock
pod install
cd ..
flutter clean
flutter pub get
```

#### 问题 2: 权限说明未显示

**症状**: 相机权限对话框不显示自定义说明

**解决方案**: 确保 Info.plist 中正确添加了 NSCameraUsageDescription

## 最佳实践

### 1. 错误处理

始终使用 try-catch 处理可能的错误：

```dart
Future<void> scanDocument() async {
  try {
    final images = await CunningDocumentScanner.getPictures();
    if (images != null && images.isNotEmpty) {
      // 处理成功情况
      processImages(images);
    } else {
      // 用户取消
      showMessage('扫描已取消');
    }
  } on Exception catch (e) {
    // 处理异常
    if (e.toString().contains('Permission not granted')) {
      showPermissionDialog();
    } else {
      showErrorDialog('扫描失败: $e');
    }
  }
}
```

### 2. 用户体验优化

显示加载指示器和进度：

```dart
Future<void> scanWithProgress() async {
  // 显示加载指示器
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => Center(
      child: CircularProgressIndicator(),
    ),
  );

  try {
    final images = await CunningDocumentScanner.getPictures();
    
    // 关闭加载指示器
    Navigator.pop(context);
    
    // 处理结果
    if (images != null && images.isNotEmpty) {
      navigateToResults(images);
    }
  } catch (e) {
    Navigator.pop(context);
    showError(e);
  }
}
```

### 3. 文件管理

及时清理不需要的扫描文件：

```dart
import 'dart:io';

Future<void> cleanupOldScans() async {
  final directory = await getApplicationDocumentsDirectory();
  final files = directory.listSync();
  
  for (var file in files) {
    if (file is File && 
        (file.path.endsWith('.jpg') || file.path.endsWith('.png'))) {
      // 删除 7 天前的文件
      final stats = file.statSync();
      if (DateTime.now().difference(stats.modified).inDays > 7) {
        await file.delete();
      }
    }
  }
}
```

### 4. 平台适配

根据平台提供不同的用户提示：

```dart
String getScanTip() {
  if (Platform.isAndroid) {
    return '您可以一次扫描多个页面，也可以从图库选择图像';
  } else if (Platform.isIOS) {
    return '点击快门按钮拍摄文档，支持自动边缘检测';
  }
  return '点击扫描按钮开始';
}
```

### 5. 性能优化

对于大量扫描，使用图像压缩：

```dart
// iOS: 使用适当的压缩质量
final images = await CunningDocumentScanner.getPictures(
  iosScannerOptions: IosScannerOptions(
    imageFormat: IosImageFormat.jpg,
    jpgCompressionQuality: 0.7,  // 平衡质量和大小
  ),
);

// 处理扫描结果时，可以进一步压缩
Future<File> compressImage(String path) async {
  final image = img.decodeImage(File(path).readAsBytesSync());
  final compressed = img.encodeJpg(image!, quality: 85);
  return File(path)..writeAsBytesSync(compressed);
}
```

## 总结

Cunning Document Scanner 是一个功能完善、易于使用的文档扫描解决方案。通过本文档，您应该能够：

1. ✅ 正确配置 Android 和 iOS 平台
2. ✅ 实现基本的文档扫描功能
3. ✅ 使用平台特定的高级功能
4. ✅ 处理常见问题和错误
5. ✅ 优化用户体验和性能

如有更多问题，请访问 [GitHub Issues](https://github.com/jachzen/cunning_document_scanner/issues)。
