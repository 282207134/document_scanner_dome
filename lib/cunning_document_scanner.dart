import 'dart:async';

import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

import 'ios_options.dart';

// 导出 iOS 选项类，使其可以从主库文件直接访问
export 'ios_options.dart';

/// Cunning Document Scanner（智能文档扫描器）
/// 
/// 这是一个用于 Flutter 的文档扫描器插件，支持在 iOS 和 Android 上
/// 自动扫描和裁剪文档。
/// 
/// 主要功能：
/// - 自动检测文档边缘
/// - 自动裁剪和透视校正
/// - 支持多页扫描（Android）
/// - 支持从相册导入（Android）
/// - 可配置的图像格式和质量（iOS）
/// 
/// 使用示例：
/// ```dart
/// // 基本用法
/// final images = await CunningDocumentScanner.getPictures();
/// 
/// // Android 高级用法
/// final images = await CunningDocumentScanner.getPictures(
///   noOfPages: 5,
///   isGalleryImportAllowed: true,
/// );
/// 
/// // iOS 高级用法
/// final images = await CunningDocumentScanner.getPictures(
///   iosScannerOptions: IosScannerOptions(
///     imageFormat: IosImageFormat.jpg,
///     jpgCompressionQuality: 0.8,
///   ),
/// );
/// ```
class CunningDocumentScanner {
  /// 方法通道
  /// 
  /// 用于与原生代码（Android Kotlin 和 iOS Swift）进行通信的通道。
  /// 通道名称必须与原生代码中的通道名称匹配。
  static const MethodChannel _channel =
      MethodChannel('cunning_document_scanner');

  /// 获取扫描的图片
  /// 
  /// 调用此方法启动文档扫描工作流程。
  /// 
  /// 该方法会：
  /// 1. 首先请求相机权限
  /// 2. 如果权限被授予，启动文档扫描器
  /// 3. 用户可以拍摄一个或多个文档照片
  /// 4. 系统会自动检测文档边缘并进行裁剪
  /// 5. 返回裁剪后的文档图像路径列表
  /// 
  /// 参数：
  /// 
  /// [noOfPages] - 最大可扫描页数（仅 Android）
  /// - 默认值：100
  /// - 用于限制用户可以扫描的文档页数
  /// - 在 iOS 上此参数被忽略
  /// 
  /// [isGalleryImportAllowed] - 是否允许从图库导入（仅 Android）
  /// - 默认值：false
  /// - 如果设置为 true，用户可以从设备图库中选择已有的图像进行扫描
  /// - 在 iOS 上此参数被忽略
  /// 
  /// [iosScannerOptions] - iOS 扫描器选项（仅 iOS）
  /// - 默认值：null（使用默认选项）
  /// - 用于配置 iOS 上的图像格式和压缩质量
  /// - 在 Android 上此参数被忽略
  /// 
  /// 返回值：
  /// 
  /// 返回一个 [Future]，包含扫描的图像文件路径列表。
  /// - 如果扫描成功，返回包含一个或多个图像路径的列表
  /// - 如果用户取消扫描，返回空列表
  /// - 如果发生错误，返回 null
  /// 
  /// 异常：
  /// 
  /// 如果相机权限被拒绝或永久拒绝，会抛出 [Exception]。
  /// 
  /// 使用示例：
  /// 
  /// ```dart
  /// try {
  ///   // 基本用法
  ///   final images = await CunningDocumentScanner.getPictures();
  ///   if (images != null && images.isNotEmpty) {
  ///     print('扫描成功，共 ${images.length} 张图片');
  ///     for (var imagePath in images) {
  ///       print('图片路径: $imagePath');
  ///     }
  ///   } else {
  ///     print('用户取消扫描');
  ///   }
  /// } catch (e) {
  ///   print('扫描失败: $e');
  /// }
  /// 
  /// // Android 高级用法：限制页数并允许从图库导入
  /// final androidImages = await CunningDocumentScanner.getPictures(
  ///   noOfPages: 3,
  ///   isGalleryImportAllowed: true,
  /// );
  /// 
  /// // iOS 高级用法：使用 JPEG 格式并设置压缩质量
  /// final iosImages = await CunningDocumentScanner.getPictures(
  ///   iosScannerOptions: IosScannerOptions(
  ///     imageFormat: IosImageFormat.jpg,
  ///     jpgCompressionQuality: 0.7,
  ///   ),
  /// );
  /// ```
  static Future<List<String>?> getPictures({
    int noOfPages = 100,
    bool isGalleryImportAllowed = false,
    IosScannerOptions? iosScannerOptions,
  }) async {
    // 请求相机权限
    // 这是一个异步操作，会弹出系统权限对话框
    Map<Permission, PermissionStatus> statuses = await [
      Permission.camera,
    ].request();

    // 检查权限状态
    // 如果权限被拒绝或永久拒绝，抛出异常
    if (statuses.containsValue(PermissionStatus.denied) ||
        statuses.containsValue(PermissionStatus.permanentlyDenied)) {
      throw Exception("Permission not granted");
    }

    // 调用原生方法 'getPictures'
    // 这会启动相应平台的文档扫描器
    final List<dynamic>? pictures = await _channel.invokeMethod('getPictures', {
      // Android 参数：最大页数
      'noOfPages': noOfPages,
      // Android 参数：是否允许从图库导入
      'isGalleryImportAllowed': isGalleryImportAllowed,
      // iOS 参数：扫描器选项
      // 只有在提供了 iosScannerOptions 时才添加此参数
      if (iosScannerOptions != null)
        'iosScannerOptions': {
          // 图像格式（jpg 或 png）
          'imageFormat': iosScannerOptions.imageFormat.name,
          // JPEG 压缩质量（0.0 - 1.0）
          'jpgCompressionQuality': iosScannerOptions.jpgCompressionQuality,
        }
    });

    // 将动态类型列表转换为字符串列表
    // 每个元素都是一个图像文件的路径
    return pictures?.map((e) => e as String).toList();
  }
}
