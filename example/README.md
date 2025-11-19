# 示例应用

演示如何使用 Cunning Document Scanner 插件。

## 功能

1. **基本扫描** - 使用默认设置
2. **Android 高级扫描** - 多页扫描 + 图库导入
3. **iOS 高级扫描** - JPEG 格式 + 压缩质量

## 运行

```bash
flutter pub get
flutter run
```

## 代码示例

### 基本扫描
```dart
final images = await CunningDocumentScanner.getPictures();
```

### Android 高级
```dart
final images = await CunningDocumentScanner.getPictures(
  noOfPages: 5,
  isGalleryImportAllowed: true,
);
```

### iOS 高级
```dart
final images = await CunningDocumentScanner.getPictures(
  iosScannerOptions: IosScannerOptions(
    imageFormat: IosImageFormat.jpg,
    jpgCompressionQuality: 0.7,
  ),
);
```
