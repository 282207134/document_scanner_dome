# API 使用指南

本指南详细介绍了 Cunning Document Scanner 的所有 API 接口和使用方法。

## 目录

- [核心 API](#核心-api)
- [类型定义](#类型定义)
- [使用示例](#使用示例)
- [错误处理](#错误处理)
- [平台差异](#平台差异)

## 核心 API

### CunningDocumentScanner.getPictures()

这是插件的主要方法，用于启动文档扫描流程。

#### 方法签名

```dart
static Future<List<String>?> getPictures({
  int noOfPages = 100,
  bool isGalleryImportAllowed = false,
  IosScannerOptions? iosScannerOptions,
})
```

#### 参数详解

##### noOfPages (int)
- **默认值**: 100
- **平台**: Android only
- **说明**: 限制用户可以扫描的最大页数
- **有效范围**: 1 到任意正整数
- **iOS 行为**: 此参数在 iOS 上被忽略

**示例**:
```dart
// 只允许扫描单页
await CunningDocumentScanner.getPictures(noOfPages: 1);

// 允许扫描最多 10 页
await CunningDocumentScanner.getPictures(noOfPages: 10);
```

##### isGalleryImportAllowed (bool)
- **默认值**: false
- **平台**: Android only
- **说明**: 是否允许用户从设备图库中选择图像
- **iOS 行为**: 此参数在 iOS 上被忽略

**示例**:
```dart
// 允许从图库导入
await CunningDocumentScanner.getPictures(
  isGalleryImportAllowed: true,
);

// 只允许相机拍摄
await CunningDocumentScanner.getPictures(
  isGalleryImportAllowed: false,
);
```

##### iosScannerOptions (IosScannerOptions?)
- **默认值**: null (使用默认设置)
- **平台**: iOS only
- **说明**: iOS 平台的扫描器配置选项
- **Android 行为**: 此参数在 Android 上被忽略

**示例**:
```dart
// 使用 PNG 格式
await CunningDocumentScanner.getPictures(
  iosScannerOptions: IosScannerOptions(
    imageFormat: IosImageFormat.png,
  ),
);

// 使用 JPEG 格式，70% 质量
await CunningDocumentScanner.getPictures(
  iosScannerOptions: IosScannerOptions(
    imageFormat: IosImageFormat.jpg,
    jpgCompressionQuality: 0.7,
  ),
);
```

#### 返回值

返回类型: `Future<List<String>?>`

可能的返回值：

1. **成功扫描**: `List<String>` - 包含一个或多个图像文件路径的列表
   ```dart
   // 示例返回值
   [
     '/data/user/0/com.example.app/cache/document_0.jpg',
     '/data/user/0/com.example.app/cache/document_1.jpg',
   ]
   ```

2. **用户取消**: `[]` (空列表) - 用户在扫描过程中取消操作
   ```dart
   final images = await CunningDocumentScanner.getPictures();
   if (images != null && images.isEmpty) {
     print('用户取消了扫描');
   }
   ```

3. **错误**: `null` - 发生错误或扫描失败
   ```dart
   final images = await CunningDocumentScanner.getPictures();
   if (images == null) {
     print('扫描失败');
   }
   ```

#### 异常

##### Exception: "Permission not granted"
当相机权限被拒绝时抛出。

```dart
try {
  final images = await CunningDocumentScanner.getPictures();
} catch (e) {
  if (e.toString().contains('Permission not granted')) {
    // 处理权限被拒绝的情况
    print('需要相机权限才能扫描文档');
  }
}
```

## 类型定义

### IosScannerOptions

iOS 平台的扫描器配置类。

#### 构造函数

```dart
const IosScannerOptions({
  this.imageFormat = IosImageFormat.png,
  this.jpgCompressionQuality = 1.0,
})
```

#### 属性

##### imageFormat (IosImageFormat)
- **默认值**: `IosImageFormat.png`
- **说明**: 输出图像的格式
- **可选值**:
  - `IosImageFormat.png`: PNG 格式（无损压缩）
  - `IosImageFormat.jpg`: JPEG 格式（有损压缩）

##### jpgCompressionQuality (double)
- **默认值**: 1.0
- **说明**: JPEG 压缩质量
- **有效范围**: 0.0 - 1.0
  - 0.0: 最高压缩率（最低质量，最小文件）
  - 1.0: 最低压缩率（最高质量，最大文件）
- **注意**: 仅当 `imageFormat` 为 `IosImageFormat.jpg` 时有效

#### 使用示例

```dart
// 默认设置（PNG 格式）
final options1 = IosScannerOptions();

// JPEG 格式，默认质量
final options2 = IosScannerOptions(
  imageFormat: IosImageFormat.jpg,
);

// JPEG 格式，自定义质量
final options3 = IosScannerOptions(
  imageFormat: IosImageFormat.jpg,
  jpgCompressionQuality: 0.8,
);
```

### IosImageFormat

图像格式枚举。

#### 枚举值

```dart
enum IosImageFormat {
  jpg,  // JPEG 格式
  png,  // PNG 格式
}
```

#### 特点比较

| 格式 | 压缩类型 | 文件大小 | 图像质量 | 适用场景 |
|------|----------|----------|----------|----------|
| PNG | 无损 | 大 | 最高 | 重要文档、需要完美质量 |
| JPEG | 有损 | 小 | 可调 | 一般文档、需要节省空间 |

## 使用示例

### 示例 1: 最简单的使用

```dart
import 'package:cunning_document_scanner/cunning_document_scanner.dart';

Future<void> scanDocument() async {
  final images = await CunningDocumentScanner.getPictures();
  
  if (images != null && images.isNotEmpty) {
    print('扫描成功，共 ${images.length} 张图片');
    for (var imagePath in images) {
      print('图片路径: $imagePath');
    }
  }
}
```

### 示例 2: 完整的错误处理

```dart
Future<void> scanWithErrorHandling() async {
  try {
    final images = await CunningDocumentScanner.getPictures();
    
    if (images != null && images.isNotEmpty) {
      // 扫描成功
      await processImages(images);
    } else if (images != null && images.isEmpty) {
      // 用户取消
      showMessage('扫描已取消');
    } else {
      // 扫描失败
      showMessage('扫描失败，请重试');
    }
  } on Exception catch (e) {
    // 处理异常
    if (e.toString().contains('Permission not granted')) {
      showPermissionDialog();
    } else {
      showError('发生错误: $e');
    }
  }
}
```

### 示例 3: Android 多页扫描

```dart
Future<void> scanMultiplePages() async {
  final images = await CunningDocumentScanner.getPictures(
    noOfPages: 5,  // 最多 5 页
    isGalleryImportAllowed: true,  // 允许图库导入
  );
  
  if (images != null && images.isNotEmpty) {
    print('扫描了 ${images.length} 页文档');
  }
}
```

### 示例 4: iOS 格式控制

```dart
// 高质量 PNG
Future<void> scanHighQuality() async {
  final images = await CunningDocumentScanner.getPictures(
    iosScannerOptions: IosScannerOptions(
      imageFormat: IosImageFormat.png,
    ),
  );
}

// 平衡质量和大小的 JPEG
Future<void> scanBalanced() async {
  final images = await CunningDocumentScanner.getPictures(
    iosScannerOptions: IosScannerOptions(
      imageFormat: IosImageFormat.jpg,
      jpgCompressionQuality: 0.7,
    ),
  );
}

// 最小文件大小的 JPEG
Future<void> scanCompressed() async {
  final images = await CunningDocumentScanner.getPictures(
    iosScannerOptions: IosScannerOptions(
      imageFormat: IosImageFormat.jpg,
      jpgCompressionQuality: 0.3,
    ),
  );
}
```

### 示例 5: 平台自适应

```dart
import 'dart:io';

Future<void> scanPlatformAdaptive() async {
  List<String>? images;
  
  if (Platform.isAndroid) {
    // Android: 允许多页和图库导入
    images = await CunningDocumentScanner.getPictures(
      noOfPages: 10,
      isGalleryImportAllowed: true,
    );
  } else if (Platform.isIOS) {
    // iOS: 使用 JPEG 格式节省空间
    images = await CunningDocumentScanner.getPictures(
      iosScannerOptions: IosScannerOptions(
        imageFormat: IosImageFormat.jpg,
        jpgCompressionQuality: 0.8,
      ),
    );
  }
  
  if (images != null && images.isNotEmpty) {
    await processImages(images);
  }
}
```

### 示例 6: 带进度指示的扫描

```dart
class DocumentScannerWidget extends StatefulWidget {
  @override
  _DocumentScannerWidgetState createState() => _DocumentScannerWidgetState();
}

class _DocumentScannerWidgetState extends State<DocumentScannerWidget> {
  bool _isScanning = false;
  List<String> _images = [];
  
  Future<void> _scan() async {
    setState(() {
      _isScanning = true;
    });
    
    try {
      final images = await CunningDocumentScanner.getPictures();
      
      if (images != null && images.isNotEmpty) {
        setState(() {
          _images = images;
        });
      }
    } finally {
      setState(() {
        _isScanning = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: _isScanning ? null : _scan,
          child: Text(_isScanning ? '扫描中...' : '开始扫描'),
        ),
        if (_isScanning)
          CircularProgressIndicator(),
        if (_images.isNotEmpty)
          Text('已扫描 ${_images.length} 张图片'),
      ],
    );
  }
}
```

## 错误处理

### 常见错误和处理方法

#### 1. 权限错误

```dart
try {
  final images = await CunningDocumentScanner.getPictures();
} catch (e) {
  if (e.toString().contains('Permission not granted')) {
    // 显示权限说明对话框
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('需要相机权限'),
        content: Text('请允许应用访问相机以扫描文档'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('知道了'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();  // 打开应用设置
            },
            child: Text('去设置'),
          ),
        ],
      ),
    );
  }
}
```

#### 2. 设备不支持

```dart
try {
  final images = await CunningDocumentScanner.getPictures();
} catch (e) {
  if (e.toString().contains('UNAVAILABLE')) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('设备不支持'),
        content: Text('您的设备不支持文档扫描功能'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('确定'),
          ),
        ],
      ),
    );
  }
}
```

#### 3. 通用错误处理

```dart
Future<List<String>?> scanWithRetry({int maxRetries = 3}) async {
  for (int i = 0; i < maxRetries; i++) {
    try {
      final images = await CunningDocumentScanner.getPictures();
      return images;
    } catch (e) {
      if (i == maxRetries - 1) {
        // 最后一次尝试也失败了
        print('扫描失败，已重试 $maxRetries 次');
        rethrow;
      }
      // 等待一秒后重试
      await Future.delayed(Duration(seconds: 1));
    }
  }
  return null;
}
```

## 平台差异

### Android vs iOS 功能对比

| 功能 | Android | iOS | 说明 |
|------|---------|-----|------|
| 多页扫描 | ✅ | ❌ | Android 支持一次扫描多页 |
| 图库导入 | ✅ | ❌ | Android 允许从图库选择图像 |
| 格式选择 | ❌ | ✅ | iOS 支持 PNG/JPEG 格式选择 |
| 质量控制 | ❌ | ✅ | iOS 支持 JPEG 压缩质量控制 |
| 自动边缘检测 | ✅ | ✅ | 两个平台都支持 |
| 自动裁剪 | ✅ | ✅ | 两个平台都支持 |

### 平台特定代码

```dart
import 'dart:io';

Future<void> scanDocument() async {
  if (Platform.isAndroid) {
    // Android 特定逻辑
    final images = await CunningDocumentScanner.getPictures(
      noOfPages: 5,
      isGalleryImportAllowed: true,
    );
  } else if (Platform.isIOS) {
    // iOS 特定逻辑
    final images = await CunningDocumentScanner.getPictures(
      iosScannerOptions: IosScannerOptions(
        imageFormat: IosImageFormat.jpg,
        jpgCompressionQuality: 0.8,
      ),
    );
  }
}
```

## 最佳实践

### 1. 始终处理所有可能的结果

```dart
Future<void> scan() async {
  try {
    final images = await CunningDocumentScanner.getPictures();
    
    if (images == null) {
      // 扫描失败
      handleError('扫描失败');
    } else if (images.isEmpty) {
      // 用户取消
      handleCancel();
    } else {
      // 扫描成功
      handleSuccess(images);
    }
  } catch (e) {
    // 异常处理
    handleException(e);
  }
}
```

### 2. 提供用户反馈

```dart
Future<void> scanWithFeedback(BuildContext context) async {
  // 显示加载指示器
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => Center(child: CircularProgressIndicator()),
  );
  
  try {
    final images = await CunningDocumentScanner.getPictures();
    Navigator.pop(context);  // 关闭加载指示器
    
    if (images != null && images.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('扫描成功！')),
      );
    }
  } catch (e) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('扫描失败: $e'),
        backgroundColor: Colors.red,
      ),
    );
  }
}
```

### 3. 根据使用场景选择合适的设置

```dart
// 场景 1: 重要文档（合同、证件等）
Future<void> scanImportantDocument() async {
  final images = await CunningDocumentScanner.getPictures(
    noOfPages: 1,  // 单页
    iosScannerOptions: IosScannerOptions(
      imageFormat: IosImageFormat.png,  // 最高质量
    ),
  );
}

// 场景 2: 日常文档（收据、笔记等）
Future<void> scanDailyDocument() async {
  final images = await CunningDocumentScanner.getPictures(
    noOfPages: 5,
    iosScannerOptions: IosScannerOptions(
      imageFormat: IosImageFormat.jpg,
      jpgCompressionQuality: 0.7,  // 平衡质量和大小
    ),
  );
}

// 场景 3: 批量扫描（归档、备份等）
Future<void> scanBatch() async {
  final images = await CunningDocumentScanner.getPictures(
    noOfPages: 50,
    iosScannerOptions: IosScannerOptions(
      imageFormat: IosImageFormat.jpg,
      jpgCompressionQuality: 0.5,  // 较小文件
    ),
  );
}
```

## 总结

本 API 指南涵盖了：

1. ✅ 所有 API 方法的详细说明
2. ✅ 参数的完整文档
3. ✅ 返回值和异常处理
4. ✅ 丰富的使用示例
5. ✅ 平台差异说明
6. ✅ 最佳实践建议

更多信息请参考：
- [主文档](../README.md)
- [中文完整文档](./README_ZH.md)
- [示例代码](../example)
