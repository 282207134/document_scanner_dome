import Flutter
import UIKit
import Vision
import VisionKit

/**
 * SwiftCunningDocumentScannerPlugin - 智能文档扫描器插件（iOS 实现）
 *
 * 这是 Flutter 插件的 iOS 端实现，使用 Apple 的 VisionKit 框架提供文档扫描功能。
 *
 * 主要功能：
 * - 使用 VNDocumentCameraViewController 进行文档扫描
 * - 自动检测文档边缘并裁剪
 * - 支持 PNG 和 JPEG 两种输出格式
 * - 可配置 JPEG 压缩质量
 *
 * 要求：iOS 13.0 或更高版本
 */
@available(iOS 13.0, *)
public class SwiftCunningDocumentScannerPlugin: NSObject, FlutterPlugin, VNDocumentCameraViewControllerDelegate {
  /// Flutter 结果回调通道
  /// 用于将扫描结果返回给 Flutter 端
  var resultChannel: FlutterResult?
  
  /// 文档相机视图控制器
  /// 用于呈现文档扫描界面
  var presentingController: VNDocumentCameraViewController?
  
  /// 扫描器选项
  /// 包含图像格式和压缩质量等配置
  var scannerOptions: CunningScannerOptions = CunningScannerOptions()

  /**
   * 注册插件
   *
   * 此方法由 Flutter Engine 调用，用于注册插件并设置方法通道。
   *
   * @param registrar Flutter 插件注册器
   */
  public static func register(with registrar: FlutterPluginRegistrar) {
    // 创建方法通道，通道名称必须与 Dart 端和 Android 端保持一致
    let channel = FlutterMethodChannel(name: "cunning_document_scanner", binaryMessenger: registrar.messenger())
    // 创建插件实例
    let instance = SwiftCunningDocumentScannerPlugin()
    // 将实例注册为方法调用委托
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  /**
   * 处理来自 Flutter 的方法调用
   *
   * 此方法接收从 Dart 端发起的方法调用，并执行相应的原生操作。
   *
   * @param call 包含方法名称和参数的调用对象
   * @param result 用于返回结果给 Flutter 的回调
   */
  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    if call.method == "getPictures" {
            // 从参数中解析扫描器选项
            scannerOptions = CunningScannerOptions.fromArguments(args: call.arguments)
            
            // 获取当前显示的视图控制器
            let presentedVC: UIViewController? = UIApplication.shared.keyWindow?.rootViewController
            
            // 保存结果回调，稍后在扫描完成时使用
            self.resultChannel = result
            
            // 检查设备是否支持文档相机
            if VNDocumentCameraViewController.isSupported {
                // 创建文档相机视图控制器
                self.presentingController = VNDocumentCameraViewController()
                // 设置委托为当前实例
                self.presentingController!.delegate = self
                // 呈现文档相机界面
                presentedVC?.present(self.presentingController!, animated: true)
            } else {
                // 设备不支持文档相机，返回错误
                result(FlutterError(code: "UNAVAILABLE", message: "Document camera is not available on this device", details: nil))
            }
        } else {
            // 未实现的方法
            result(FlutterMethodNotImplemented)
            return
        }
  }


    /**
     * 获取文档目录
     *
     * 此方法返回应用程序的文档目录 URL，用于保存扫描的文档图像。
     *
     * @return 文档目录的 URL
     */
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }

    /**
     * 文档扫描完成回调
     *
     * 当用户完成文档扫描并点击保存时调用此方法。
     * 此方法会：
     * 1. 遍历所有扫描的页面
     * 2. 根据配置的格式保存每个页面的图像
     * 3. 将文件路径列表返回给 Flutter
     *
     * @param controller 文档相机视图控制器
     * @param scan 包含所有扫描页面的扫描结果
     */
    public func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
        // 获取文档目录路径
        let tempDirPath = self.getDocumentsDirectory()
        
        // 获取当前日期时间并格式化
        let currentDateTime = Date()
        let df = DateFormatter()
        df.dateFormat = "yyyyMMdd-HHmmss"
        let formattedDate = df.string(from: currentDateTime)
        
        // 存储所有文件名的数组
        var filenames: [String] = []
        
        // 遍历所有扫描的页面
        for i in 0 ..< scan.pageCount {
            // 获取当前页面的图像
            let page = scan.imageOfPage(at: i)
            
            // 构造文件路径，文件名包含时间戳和页码
            let url = tempDirPath.appendingPathComponent(formattedDate + "-\(i).\(scannerOptions.imageFormat.rawValue)")
            
            // 根据配置的图像格式保存文件
            switch scannerOptions.imageFormat {
            case CunningScannerImageFormat.jpg:
                // 保存为 JPEG 格式，使用配置的压缩质量
                try? page.jpegData(compressionQuality: scannerOptions.jpgCompressionQuality)?.write(to: url)
                break
            case CunningScannerImageFormat.png:
                // 保存为 PNG 格式
                try? page.pngData()?.write(to: url)
                break
            }
            
            // 将文件路径添加到列表
            filenames.append(url.path)
        }
        
        // 将文件路径列表返回给 Flutter
        resultChannel?(filenames)
        
        // 关闭文档相机界面
        presentingController?.dismiss(animated: true)
    }

    /**
     * 文档扫描取消回调
     *
     * 当用户取消文档扫描时调用此方法。
     *
     * @param controller 文档相机视图控制器
     */
    public func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
        // 返回 nil 表示用户取消了扫描
        resultChannel?(nil)
        
        // 关闭文档相机界面
        presentingController?.dismiss(animated: true)
    }

    /**
     * 文档扫描失败回调
     *
     * 当文档扫描过程中发生错误时调用此方法。
     *
     * @param controller 文档相机视图控制器
     * @param error 发生的错误
     */
    public func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) {
        // 将错误信息返回给 Flutter
        resultChannel?(FlutterError(code: "ERROR", message: error.localizedDescription, details: nil))
        
        // 关闭文档相机界面
        presentingController?.dismiss(animated: true)
    }
}
