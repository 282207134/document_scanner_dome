package biz.cunning.cunning_document_scanner

import android.app.Activity
import android.content.ActivityNotFoundException
import android.content.Intent
import android.content.IntentSender
import androidx.core.app.ActivityCompat
import biz.cunning.cunning_document_scanner.fallback.DocumentScannerActivity
import biz.cunning.cunning_document_scanner.fallback.constants.DocumentScannerExtra
import com.google.mlkit.common.MlKitException
import com.google.mlkit.vision.documentscanner.GmsDocumentScannerOptions
import com.google.mlkit.vision.documentscanner.GmsDocumentScannerOptions.RESULT_FORMAT_JPEG
import com.google.mlkit.vision.documentscanner.GmsDocumentScannerOptions.SCANNER_MODE_FULL
import com.google.mlkit.vision.documentscanner.GmsDocumentScanning
import com.google.mlkit.vision.documentscanner.GmsDocumentScanningResult
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry

/**
 * CunningDocumentScannerPlugin - 智能文档扫描器插件
 * 
 * 这是 Flutter 插件的 Android 端实现，负责处理文档扫描功能。
 * 
 * 主要功能：
 * - 使用 Google ML Kit 文档扫描器 API 进行文档扫描
 * - 如果 ML Kit 不可用，使用后备实现（自定义扫描器）
 * - 处理与 Flutter 端的通信
 * - 管理 Activity 生命周期和权限
 * 
 * 实现的接口：
 * - FlutterPlugin: Flutter 插件接口
 * - MethodCallHandler: 处理来自 Flutter 的方法调用
 * - ActivityAware: 感知 Activity 的生命周期变化
 */
class CunningDocumentScannerPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
    // Activity 结果监听器委托
    private var delegate: PluginRegistry.ActivityResultListener? = null
    
    // Activity 插件绑定
    private var binding: ActivityPluginBinding? = null
    
    // 待处理的 Flutter 结果回调
    private var pendingResult: Result? = null
    
    // 当前 Activity 实例
    private lateinit var activity: Activity
    
    // Google ML Kit 文档扫描 Activity 的请求码
    private val START_DOCUMENT_ACTIVITY: Int = 0x362738
    
    // 后备文档扫描 Activity 的请求码
    private val START_DOCUMENT_FB_ACTIVITY: Int = 0x362737

    /**
     * 方法通道
     * 
     * 用于在 Flutter 和原生 Android 之间进行通信的通道。
     * 当 Flutter Engine 附加到 Activity 时注册此插件，
     * 当 Flutter Engine 从 Activity 分离时注销此插件。
     */
    private lateinit var channel: MethodChannel

    /**
     * 当插件附加到 Flutter Engine 时调用
     * 
     * 此方法在 Flutter Engine 启动时被调用，用于初始化方法通道。
     * 
     * @param flutterPluginBinding 包含与 Flutter Engine 通信所需的资源
     */
    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        // 创建方法通道，通道名称必须与 Dart 端保持一致
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "cunning_document_scanner")
        // 设置方法调用处理器为当前类
        channel.setMethodCallHandler(this)
    }

    /**
     * 处理来自 Flutter 的方法调用
     * 
     * 此方法接收从 Dart 端发起的方法调用，并执行相应的原生操作。
     * 
     * @param call 包含方法名称和参数的调用对象
     * @param result 用于返回结果给 Flutter 的回调
     */
    override fun onMethodCall(call: MethodCall, result: Result) {
        if (call.method == "getPictures") {
            // 获取最大页数参数，默认为 50
            val noOfPages = call.argument<Int>("noOfPages") ?: 50;
            // 获取是否允许从图库导入参数，默认为 false
            val isGalleryImportAllowed = call.argument<Boolean>("isGalleryImportAllowed") ?: false;
            // 保存结果回调，稍后在扫描完成时使用
            this.pendingResult = result
            // 启动文档扫描流程
            startScan(noOfPages, isGalleryImportAllowed)
        } else {
            // 如果是未实现的方法，返回未实现状态
            result.notImplemented()
        }
    }

    /**
     * 当插件从 Flutter Engine 分离时调用
     * 
     * 此方法在 Flutter Engine 关闭时被调用，用于清理资源。
     * 
     * @param binding Flutter 插件绑定
     */
    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        // 移除方法调用处理器
        channel.setMethodCallHandler(null)
    }

    /**
     * 当插件附加到 Activity 时调用
     * 
     * 此方法在 Activity 创建时被调用，用于获取 Activity 实例
     * 并添加 Activity 结果监听器。
     * 
     * @param binding Activity 插件绑定
     */
    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        // 保存 Activity 实例
        this.activity = binding.activity
        // 添加 Activity 结果监听器
        addActivityResultListener(binding)
    }

    /**
     * 添加 Activity 结果监听器
     * 
     * 此方法创建并添加一个监听器来处理文档扫描 Activity 返回的结果。
     * 支持两种扫描模式：
     * 1. Google ML Kit 文档扫描器（START_DOCUMENT_ACTIVITY）
     * 2. 后备自定义扫描器（START_DOCUMENT_FB_ACTIVITY）
     * 
     * @param binding Activity 插件绑定
     */
    private fun addActivityResultListener(binding: ActivityPluginBinding) {
        this.binding = binding
        if (this.delegate == null) {
            this.delegate = PluginRegistry.ActivityResultListener { requestCode, resultCode, data ->
                // 检查请求码是否匹配我们的文档扫描 Activity
                if (requestCode != START_DOCUMENT_ACTIVITY && requestCode != START_DOCUMENT_FB_ACTIVITY) {
                    return@ActivityResultListener false
                }
                var handled = false
                // 处理 Google ML Kit 文档扫描器的结果
                if (requestCode == START_DOCUMENT_ACTIVITY) {
                    when (resultCode) {
                        Activity.RESULT_OK -> {
                            // 检查是否有错误
                            val error = data?.extras?.getString("error")
                            if (error != null) {
                                pendingResult?.error("ERROR", "error - $error", null)
                            } else {
                                // 获取扫描的文档文件路径数组
                                val scanningResult: GmsDocumentScanningResult =
                                    data?.extras?.getParcelable("extra_scanning_result")
                                        ?: return@ActivityResultListener false

                                // 提取图像 URI 并移除 "file://" 前缀
                                val successResponse = scanningResult.pages?.map {
                                    it.imageUri.toString().removePrefix("file://")
                                }?.toList()
                                // 触发成功事件处理器，返回裁剪后的图像数组
                                pendingResult?.success(successResponse)
                            }
                            handled = true
                        }

                        Activity.RESULT_CANCELED -> {
                            // 用户关闭了相机
                            pendingResult?.success(emptyList<String>())
                            handled = true
                        }
                    }
                } else {
                    // 处理后备文档扫描器的结果
                    when (resultCode) {
                        Activity.RESULT_OK -> {
                            // 检查是否有错误
                            val error = data?.extras?.getString("error")
                            if (error != null) {
                                pendingResult?.error("ERROR", "error - $error", null)
                            } else {
                                // 获取扫描的文档文件路径数组
                                val croppedImageResults =
                                    data?.getStringArrayListExtra("croppedImageResults")?.toList()
                                        ?: let {
                                            pendingResult?.error("ERROR", "No cropped images returned", null)
                                            return@ActivityResultListener true
                                        }

                                // 返回文件路径列表
                                // 移除文件 URI 前缀，因为 Flutter 文件处理会有问题
                                val successResponse = croppedImageResults.map {
                                    it.removePrefix("file://")
                                }.toList()
                                // 触发成功事件处理器，返回裁剪后的图像数组
                                pendingResult?.success(successResponse)
                            }
                            handled = true
                        }

                        Activity.RESULT_CANCELED -> {
                            // 用户关闭了相机
                            pendingResult?.success(emptyList<String>())
                            handled = true
                        }
                    }
                }

                if (handled) {
                    // 清除待处理的结果，避免重复使用
                    pendingResult = null
                }
                return@ActivityResultListener handled
            }
        } else {
            binding.removeActivityResultListener(this.delegate!!)
        }

        binding.addActivityResultListener(delegate!!)
    }


    /**
     * 创建启动文档扫描器的 Intent 并设置自定义选项
     * 
     * 此方法创建一个 Intent 来启动后备文档扫描 Activity（自定义实现）。
     * 当 Google ML Kit 不可用时使用此方法。
     * 
     * @param noOfPages 最大可扫描的页数
     * @return 配置好的文档扫描 Intent
     */
    private fun createDocumentScanIntent(noOfPages: Int): Intent {
        val documentScanIntent = Intent(activity, DocumentScannerActivity::class.java)

        // 设置最大文档数量参数
        documentScanIntent.putExtra(
            DocumentScannerExtra.EXTRA_MAX_NUM_DOCUMENTS,
            noOfPages
        )

        return documentScanIntent
    }

    /**
     * 添加文档扫描器结果处理器并启动文档扫描器
     * 
     * 此方法是启动文档扫描的核心方法。它会：
     * 1. 首先尝试使用 Google ML Kit 文档扫描器
     * 2. 如果 ML Kit 不可用，则回退到自定义文档扫描器实现
     * 
     * @param noOfPages 最大可扫描的页数
     * @param isGalleryImportAllowed 是否允许从图库导入图像
     */
    private fun startScan(noOfPages: Int, isGalleryImportAllowed: Boolean) {
        // 配置 Google ML Kit 文档扫描器选项
        val options = GmsDocumentScannerOptions.Builder()
            .setGalleryImportAllowed(isGalleryImportAllowed)  // 设置是否允许从图库导入
            .setPageLimit(noOfPages)  // 设置页数限制
            .setResultFormats(RESULT_FORMAT_JPEG)  // 设置结果格式为 JPEG
            .setScannerMode(SCANNER_MODE_FULL)  // 设置为完整扫描模式（包含裁剪和过滤）
            .build()
        
        // 获取文档扫描器客户端
        val scanner = GmsDocumentScanning.getClient(options)
        
        // 获取启动扫描的 Intent
        scanner.getStartScanIntent(activity).addOnSuccessListener {
            try {
                // 使用自定义请求码启动 Activity，用于在 onActivityResult 中识别
                activity.startIntentSenderForResult(it, START_DOCUMENT_ACTIVITY, null, 0, 0, 0)
            } catch (e: IntentSender.SendIntentException) {
                // 启动失败，返回错误
                pendingResult?.error("ERROR", "Failed to start document scanner", null)
            }
        }.addOnFailureListener {
            // 如果 ML Kit 不可用（例如设备不支持或服务未安装）
            if (it is MlKitException) {
                // 使用后备文档扫描器（自定义实现）
                val intent = createDocumentScanIntent(noOfPages)
                try {
                    ActivityCompat.startActivityForResult(
                        this.activity,
                        intent,
                        START_DOCUMENT_FB_ACTIVITY,
                        null
                    )
                } catch (e: ActivityNotFoundException) {
                    // 启动 Activity 失败
                    pendingResult?.error("ERROR", "FAILED TO START ACTIVITY", null)
                }
            } else {
                // 其他错误
                pendingResult?.error("ERROR", "Failed to start document scanner Intent", null)
            }
        }
    }

    /**
     * 当 Activity 因配置更改而分离时调用
     * 
     * 例如屏幕旋转时会触发此方法。
     */
    override fun onDetachedFromActivityForConfigChanges() {
        // 不需要做任何处理
    }

    /**
     * 当 Activity 因配置更改而重新附加时调用
     * 
     * 例如屏幕旋转后会触发此方法。
     * 
     * @param binding 新的 Activity 插件绑定
     */
    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        // 重新添加 Activity 结果监听器
        addActivityResultListener(binding)
    }

    /**
     * 当插件从 Activity 分离时调用
     * 
     * 此方法在 Activity 销毁时被调用，用于清理资源。
     */
    override fun onDetachedFromActivity() {
        // 移除 Activity 结果监听器
        removeActivityResultListener()
    }

    /**
     * 移除 Activity 结果监听器
     * 
     * 此方法用于清理 Activity 结果监听器，防止内存泄漏。
     */
    private fun removeActivityResultListener() {
        this.delegate?.let { this.binding?.removeActivityResultListener(it) }
    }
}
