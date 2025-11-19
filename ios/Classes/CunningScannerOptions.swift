//
//  ScannerOptions.swift
//  cunning_document_scanner
//
//  Created by Maurits van Beusekom on 15/10/2024.
//  扫描器选项配置类

import Foundation

/**
 * 图像格式枚举
 *
 * 定义扫描文档时支持的输出图像格式。
 */
enum CunningScannerImageFormat: String {
    /// JPEG 格式 - 有损压缩，文件较小
    case jpg
    /// PNG 格式 - 无损压缩，质量最高
    case png
}

/**
 * 扫描器选项结构体
 *
 * 用于配置 iOS 文档扫描器的行为，包括输出图像格式和压缩质量。
 */
struct CunningScannerOptions {
    /// 输出图像格式
    let imageFormat: CunningScannerImageFormat
    
    /// JPEG 压缩质量（0.0 - 1.0）
    /// - 0.0: 最高压缩率（最低质量，最小文件）
    /// - 1.0: 最低压缩率（最高质量，最大文件）
    let jpgCompressionQuality: Double
    
    /**
     * 默认初始化方法
     *
     * 创建默认配置的扫描器选项：
     * - 图像格式：PNG
     * - JPEG 压缩质量：1.0（最高质量）
     */
    init() {
        self.imageFormat = CunningScannerImageFormat.png
        self.jpgCompressionQuality = 1.0
    }
    
    /**
     * 指定图像格式的初始化方法
     *
     * 创建指定图像格式的扫描器选项，JPEG 压缩质量默认为 1.0。
     *
     * @param imageFormat 输出图像格式
     */
    init(imageFormat: CunningScannerImageFormat) {
        self.imageFormat = imageFormat
        self.jpgCompressionQuality = 1.0
    }
    
    /**
     * 完整参数的初始化方法
     *
     * 创建完全自定义的扫描器选项。
     *
     * @param imageFormat 输出图像格式
     * @param jpgCompressionQuality JPEG 压缩质量（0.0 - 1.0）
     */
    init(imageFormat: CunningScannerImageFormat, jpgCompressionQuality: Double) {
        self.imageFormat = imageFormat
        self.jpgCompressionQuality = jpgCompressionQuality
    }
    
    /**
     * 从 Flutter 传递的参数创建扫描器选项
     *
     * 此静态方法解析来自 Flutter 的参数，并创建相应的扫描器选项对象。
     * 如果参数为空或格式不正确，则返回默认配置。
     *
     * @param args 来自 Flutter 的参数（可能为 nil）
     * @return 解析后的扫描器选项对象
     */
    static func fromArguments(args: Any?) -> CunningScannerOptions {
        // 如果参数为空，返回默认配置
        if (args == nil) {
            return CunningScannerOptions()
        }
        
        // 尝试将参数转换为字典
        let arguments = args as? Dictionary<String, Any>
    
        // 如果转换失败或不包含 iOS 扫描器选项，返回默认配置
        if arguments == nil || arguments!.keys.contains("iosScannerOptions") == false {
            return CunningScannerOptions()
        }
        
        // 提取 iOS 扫描器选项字典
        let scannerOptionsDict = arguments!["iosScannerOptions"] as! Dictionary<String, Any>
        
        // 提取图像格式，默认为 "png"
        let imageFormat: String = (scannerOptionsDict["imageFormat"] as? String) ?? "png"
        
        // 提取 JPEG 压缩质量，默认为 1.0
        let jpgCompressionQuality: Double = (scannerOptionsDict["jpgCompressionQuality"] as? Double) ?? 1.0
            
        // 创建并返回扫描器选项对象
        return CunningScannerOptions(imageFormat: CunningScannerImageFormat(rawValue: imageFormat) ?? CunningScannerImageFormat.png, jpgCompressionQuality: jpgCompressionQuality)
    }
}
