# Cunning Document Scanner（智能文档扫描器）

Cunning Document Scanner 是一个基于 Flutter 的文档扫描应用程序，使您能够轻松地拍摄纸质文档的照片并将其转换为数字文件。此应用程序设计用于在 Android 和 iOS 设备上运行，最低 API 级别分别为 21 和 13。

## 主要功能

- 快速简便的文档扫描
- 将文档图像转换为数字文件
- 支持 Android 和 iOS 平台
- 最低要求：Android 上的 API 21，iOS 上的 iOS 13
- 在 Android 上限制可扫描文件的数量
- 在 Android 上允许从图库中选择图像
- 最先进的文档扫描器，具有自动裁剪功能

<img src="https://user-images.githubusercontent.com/1488063/167291601-c64db2d5-78ab-4781-bc7a-afe7eb93e083.png" height ="400"  alt=""/>
<img src="https://user-images.githubusercontent.com/1488063/167291821-3b66d0bb-b636-4911-a572-d2368dc95012.jpeg" height ="400"  alt=""/>
<img src="https://user-images.githubusercontent.com/1488063/167291827-fa0ae804-1b81-4ef4-8607-3b212c3ab1c0.jpeg" height ="400"  alt=""/>

## 项目设置

按照以下步骤在 Android 和 iOS 上设置您的 Flutter 项目。

### **Android 配置**

#### 最低版本配置
确保满足在 Android 设备上运行应用程序的最低版本要求。
在 `android/app/build.gradle` 文件中，验证 `minSdkVersion` 至少为 21：

```gradle
android {
    ...
    defaultConfig {
        ...
        minSdkVersion 21
        ...
    }
    ...
}
```

### **iOS 配置**

#### 最低版本配置
确保满足在 iOS 设备上运行应用程序的最低版本要求。
在 `ios/Podfile` 文件中，确保 iOS 平台版本至少为 13.0：

```ruby
platform :ios, '13.0'
```

#### 权限配置
1. 在应用程序的 Info.plist 文件中添加一个字符串属性，其键为 [NSCameraUsageDescription](https://developer.apple.com/documentation/bundleresources/information_property_list/nscamerausagedescription)，值为应用程序需要相机访问权限的原因描述。

   ```xml
   <key>NSCameraUsageDescription</key>
   <string>需要相机权限以扫描文档</string>
   ```

2. cunning_document_scanner 使用的 [permission_handler](https://pub.dev/packages/permission_handler) 依赖项使用[宏](https://github.com/Baseflow/flutter-permission-handler/blob/master/permission_handler_apple/ios/Classes/PermissionHandlerEnums.h)来控制是否启用权限。将以下内容添加到您的 `Podfile` 文件中：

   ```ruby
   post_install do |installer|
     installer.pods_project.targets.each do |target|
       ... # 这里是 Flutter 自动生成的一些配置

       # permission_handler 配置开始
       target.build_configurations.each do |config|

         # 您可以在此处启用所需的权限。例如，要启用相机权限，
         # 只需删除前面的 `#` 字符，使其如下所示：
         #
         # ## dart: PermissionGroup.camera
         # 'PERMISSION_CAMERA=1'
         #
         # 预处理器定义可以在以下位置找到：
         # https://github.com/Baseflow/flutter-permission-handler/blob/master/permission_handler_apple/ios/Classes/PermissionHandlerEnums.h
         config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= [
           '$(inherited)',

           ## dart: PermissionGroup.camera
           'PERMISSION_CAMERA=1',
         ]

       end
       # permission_handler 配置结束
     end
   end
   ```

## 如何使用？

获取图像列表的最简单方法是：

```dart
final imagesPath = await CunningDocumentScanner.getPictures();
```

### Android 特定功能

Android 中有一些功能允许您调整扫描器，这些功能在 iOS 中将被忽略：

```dart
final imagesPath = await CunningDocumentScanner.getPictures(
  noOfPages: 1, // 将页数限制为 1
  isGalleryImportAllowed: true, // 允许用户从图库中选择图像
);
```

### iOS 特定功能

在 iOS 上，可以配置应该使用哪种图像格式来保存文档扫描。可用选项是 PNG（默认）或 JPEG。在某些情况下，JPEG 格式可以大幅减小最终扫描的文件大小。如果您选择使用 JPEG，还可以指定压缩质量，其中 0.0 是最高压缩（最低质量），1.0（默认）是最低压缩（最高质量）。示例用法：

```dart
// 返回 JPEG 格式的图像，压缩质量为 50%
final imagesPath = await CunningDocumentScanner.getPictures(
  iosScannerOptions: IosScannerOptions(
    imageFormat: IosImageFormat.jpg,
    jpgCompressionQuality: 0.5,
  ),
);
```

## 安装

在开始之前，请确保您的系统上已安装 Flutter 和 Dart。您可以参考 [Flutter 安装指南](https://flutter.dev/docs/get-started/install)了解更多信息。

1. 克隆此仓库：

   ```bash
   git clone https://github.com/jachzen/cunning_document_scanner.git
   ```

2. 导航到项目目录：

   ```bash
   cd cunning_document_scanner
   ```

3. 安装依赖项：

   ```bash
   flutter pub get
   ```

4. 运行应用程序：

   ```bash
   flutter run
   ```

## 贡献

欢迎贡献。如果您想为 Cunning Document Scanner 的开发做出贡献，请按照以下步骤操作：

1. Fork 仓库
2. 为您的贡献创建一个分支：`git checkout -b your_feature`
3. 进行更改并提交：`git commit -m '添加新功能'`
4. 推送分支：`git push origin your_feature`
5. 在 GitHub 上打开一个拉取请求

## 问题和支持

如果您遇到任何问题或有疑问，请打开一个 [issue](https://github.com/jachzen/cunning_document_scanner/issues)。我们随时为您提供帮助。

## 许可证

此项目根据 MIT 许可证授权。有关详细信息，请参阅 [LICENSE](LICENSE) 文件。

## API 文档

### CunningDocumentScanner 类

主要的文档扫描器类，提供文档扫描功能。

#### getPictures 方法

启动文档扫描流程并返回扫描的图像路径列表。

**参数：**

- `noOfPages` (int, 可选): 最大可扫描页数，默认为 100（仅 Android）
- `isGalleryImportAllowed` (bool, 可选): 是否允许从图库导入图像，默认为 false（仅 Android）
- `iosScannerOptions` (IosScannerOptions, 可选): iOS 扫描器选项（仅 iOS）

**返回值：**

- `Future<List<String>?>`: 返回扫描图像的文件路径列表，如果用户取消则返回 null

**异常：**

- 如果相机权限未授予，将抛出异常

**示例：**

```dart
// 基本用法
final images = await CunningDocumentScanner.getPictures();

// Android 高级用法
final images = await CunningDocumentScanner.getPictures(
  noOfPages: 5,
  isGalleryImportAllowed: true,
);

// iOS 高级用法
final images = await CunningDocumentScanner.getPictures(
  iosScannerOptions: IosScannerOptions(
    imageFormat: IosImageFormat.jpg,
    jpgCompressionQuality: 0.8,
  ),
);
```

### IosScannerOptions 类

iOS 扫描器的配置选项。

**属性：**

- `imageFormat` (IosImageFormat): 输出图像格式，默认为 PNG
- `jpgCompressionQuality` (double): JPEG 压缩质量，范围 0.0-1.0，默认为 1.0

### IosImageFormat 枚举

定义支持的图像格式。

**值：**

- `jpg`: JPEG 格式
- `png`: PNG 格式

## 常见问题

### Q: 如何处理权限被拒绝的情况？

A: 您可以使用 try-catch 块来捕获权限异常：

```dart
try {
  final images = await CunningDocumentScanner.getPictures();
  if (images != null && images.isNotEmpty) {
    // 处理扫描的图像
  }
} catch (e) {
  // 处理权限被拒绝或其他错误
  print('扫描失败: $e');
}
```

### Q: 如何限制扫描页数？

A: 在 Android 上，使用 `noOfPages` 参数：

```dart
final images = await CunningDocumentScanner.getPictures(noOfPages: 1);
```

### Q: 如何优化图像文件大小？

A: 在 iOS 上，使用 JPEG 格式并调整压缩质量：

```dart
final images = await CunningDocumentScanner.getPictures(
  iosScannerOptions: IosScannerOptions(
    imageFormat: IosImageFormat.jpg,
    jpgCompressionQuality: 0.5, // 50% 质量
  ),
);
```

## 技术架构

### 平台实现

- **Android**: 使用 Google ML Kit 的文档扫描器 API，带有后备实现
- **iOS**: 使用 VisionKit 的 VNDocumentCameraViewController

### 通信机制

使用 Flutter 的 MethodChannel 在 Dart 和原生代码之间进行通信。

### 权限处理

使用 permission_handler 包统一处理 Android 和 iOS 的相机权限。
