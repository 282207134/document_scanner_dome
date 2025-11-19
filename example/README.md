# Cunning Document Scanner 示例应用

这是一个展示如何使用 Cunning Document Scanner 插件的示例应用程序。

## 功能展示

1. **基本扫描**: 使用默认设置扫描文档
2. **Android 高级扫描**: 限制页数和允许图库导入
3. **iOS 高级扫描**: 使用 JPEG 格式和自定义压缩质量
4. **结果展示**: 显示所有扫描的文档图像

## 运行示例

### 1. 安装依赖

```bash
flutter pub get
```

### 2. 运行应用

在 Android 设备或模拟器上运行：
```bash
flutter run
```

在 iOS 设备或模拟器上运行：
```bash
flutter run
```

## 代码说明

### 基本扫描

```dart
final images = await CunningDocumentScanner.getPictures();
```

### Android 高级扫描

```dart
final images = await CunningDocumentScanner.getPictures(
  noOfPages: 5,
  isGalleryImportAllowed: true,
);
```

### iOS 高级扫描

```dart
final images = await CunningDocumentScanner.getPictures(
  iosScannerOptions: IosScannerOptions(
    imageFormat: IosImageFormat.jpg,
    jpgCompressionQuality: 0.7,
  ),
);
```

## 注意事项

1. 确保已正确配置 Android 和 iOS 的权限
2. 在真实设备上测试以获得最佳体验
3. 检查设备是否支持文档扫描功能

## 更多信息

查看主项目的 [README.md](../README.md) 和 [中文文档](../docs/README_ZH.md) 了解更多详细信息。
