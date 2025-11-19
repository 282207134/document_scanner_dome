/// iOS 图像格式枚举
/// 
/// 定义文档扫描输出时支持的不同图像格式
enum IosImageFormat {
  /// JPEG 格式
  /// 
  /// 指示输出图像应格式化为 JPEG 图像。
  /// JPEG 是一种有损压缩格式，可以显著减小文件大小，
  /// 适用于不需要完美质量但需要较小文件大小的场景。
  jpg,

  /// PNG 格式
  /// 
  /// 指示输出图像应格式化为 PNG 图像。
  /// PNG 是一种无损压缩格式，可以保持图像的完整质量，
  /// 但文件大小通常比 JPEG 大。
  png,
}

/// iOS 文档扫描器选项
/// 
/// 此类用于修改 iOS 上文档扫描器的行为。
/// 
/// [imageFormat] 指定输出图像文件的格式。可用选项为
/// [IosImageFormat.jpg] 或 [IosImageFormat.png]。
/// 默认值为 [IosImageFormat.png]。
/// 
/// 如果 [imageFormat] 设置为 [IosImageFormat.jpg]，
/// 则可以使用 [jpgCompressionQuality] 来控制生成的 JPEG 图像的质量。
/// 值 0.0 表示最大压缩（或最低质量），
/// 值 1.0 表示最小压缩（或最佳质量）。
/// 默认值为 1.0。
/// 
/// 示例用法：
/// ```dart
/// // 使用 PNG 格式（默认）
/// final options1 = IosScannerOptions();
/// 
/// // 使用 JPEG 格式，质量为 80%
/// final options2 = IosScannerOptions(
///   imageFormat: IosImageFormat.jpg,
///   jpgCompressionQuality: 0.8,
/// );
/// 
/// // 使用 JPEG 格式，最高压缩（最小文件大小）
/// final options3 = IosScannerOptions(
///   imageFormat: IosImageFormat.jpg,
///   jpgCompressionQuality: 0.0,
/// );
/// ```
final class IosScannerOptions {
  /// 创建一个 [IosScannerOptions] 实例
  /// 
  /// [imageFormat]: 输出图像的格式，默认为 PNG
  /// [jpgCompressionQuality]: JPEG 压缩质量，范围 0.0-1.0，默认为 1.0
  const IosScannerOptions({
    this.imageFormat = IosImageFormat.png,
    this.jpgCompressionQuality = 1.0,
  });

  /// 输出图像的格式
  /// 
  /// 可以是 [IosImageFormat.jpg] 或 [IosImageFormat.png]
  final IosImageFormat imageFormat;

  /// 生成的 JPEG 图像的质量
  /// 
  /// 此值表示为从 0.0 到 1.0 的值。
  /// 
  /// - 值 0.0 表示最大压缩（或最低质量）
  /// - 值 1.0 表示最小压缩（或最佳质量）
  /// 
  /// [jpgCompressionQuality] 仅在 [imageFormat] 设置为
  /// [IosImageFormat.jpg] 时有效，否则将被忽略。
  final double jpgCompressionQuality;
}
