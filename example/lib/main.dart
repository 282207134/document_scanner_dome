import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cunning_document_scanner/cunning_document_scanner.dart';

/// 示例应用程序入口
void main() {
  runApp(MyApp());
}

/// 应用程序主类
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '文档扫描器示例',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: DocumentScannerPage(),
    );
  }
}

/// 文档扫描器页面
class DocumentScannerPage extends StatefulWidget {
  @override
  _DocumentScannerPageState createState() => _DocumentScannerPageState();
}

class _DocumentScannerPageState extends State<DocumentScannerPage> {
  /// 存储扫描的图片路径
  List<String> _scannedImages = [];

  /// 是否正在扫描
  bool _isScanning = false;

  /// 基本扫描 - 使用默认设置
  Future<void> _scanDocumentBasic() async {
    setState(() {
      _isScanning = true;
    });

    try {
      // 调用文档扫描器
      final images = await CunningDocumentScanner.getPictures();

      if (images != null && images.isNotEmpty) {
        setState(() {
          _scannedImages = images;
        });

        _showMessage('成功扫描 ${images.length} 张图片');
      } else {
        _showMessage('扫描已取消');
      }
    } catch (e) {
      _showError('扫描失败: $e');
    } finally {
      setState(() {
        _isScanning = false;
      });
    }
  }

  /// Android 高级扫描 - 限制页数和允许图库导入
  Future<void> _scanDocumentAndroid() async {
    setState(() {
      _isScanning = true;
    });

    try {
      final images = await CunningDocumentScanner.getPictures(
        noOfPages: 5, // 最多扫描 5 页
        isGalleryImportAllowed: true, // 允许从图库选择
      );

      if (images != null && images.isNotEmpty) {
        setState(() {
          _scannedImages = images;
        });

        _showMessage('成功扫描 ${images.length} 张图片');
      } else {
        _showMessage('扫描已取消');
      }
    } catch (e) {
      _showError('扫描失败: $e');
    } finally {
      setState(() {
        _isScanning = false;
      });
    }
  }

  /// iOS 高级扫描 - 使用 JPEG 格式和自定义压缩质量
  Future<void> _scanDocumentIOS() async {
    setState(() {
      _isScanning = true;
    });

    try {
      final images = await CunningDocumentScanner.getPictures(
        iosScannerOptions: IosScannerOptions(
          imageFormat: IosImageFormat.jpg, // 使用 JPEG 格式
          jpgCompressionQuality: 0.7, // 70% 质量
        ),
      );

      if (images != null && images.isNotEmpty) {
        setState(() {
          _scannedImages = images;
        });

        _showMessage('成功扫描 ${images.length} 张图片');
      } else {
        _showMessage('扫描已取消');
      }
    } catch (e) {
      _showError('扫描失败: $e');
    } finally {
      setState(() {
        _isScanning = false;
      });
    }
  }

  /// 清除所有扫描的图片
  void _clearImages() {
    setState(() {
      _scannedImages.clear();
    });
    _showMessage('已清除所有图片');
  }

  /// 显示消息提示
  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2),
      ),
    );
  }

  /// 显示错误提示
  void _showError(String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      ),
    );
  }

  /// 构建扫描按钮
  Widget _buildScanButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: _isScanning ? null : onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        textStyle: TextStyle(fontSize: 16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('文档扫描器示例'),
        actions: [
          if (_scannedImages.isNotEmpty)
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: _clearImages,
              tooltip: '清除所有图片',
            ),
        ],
      ),
      body: Column(
        children: [
          // 扫描按钮区域
          Container(
            padding: EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '选择扫描模式',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                _buildScanButton(
                  label: '基本扫描',
                  icon: Icons.document_scanner,
                  onPressed: _scanDocumentBasic,
                ),
                SizedBox(height: 8),
                if (Platform.isAndroid)
                  _buildScanButton(
                    label: 'Android 高级扫描',
                    icon: Icons.android,
                    onPressed: _scanDocumentAndroid,
                  ),
                if (Platform.isIOS)
                  _buildScanButton(
                    label: 'iOS 高级扫描',
                    icon: Icons.apple,
                    onPressed: _scanDocumentIOS,
                  ),
                if (_isScanning)
                  Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
              ],
            ),
          ),

          // 扫描结果显示区域
          Expanded(
            child: _scannedImages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.camera_alt,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          '还没有扫描的文档',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '点击上方按钮开始扫描',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _scannedImages.length,
                    padding: EdgeInsets.all(8),
                    itemBuilder: (context, index) {
                      final imagePath = _scannedImages[index];
                      return Card(
                        elevation: 4,
                        margin: EdgeInsets.symmetric(vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // 图片
                            ClipRRect(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(4),
                              ),
                              child: Image.file(
                                File(imagePath),
                                fit: BoxFit.cover,
                                height: 300,
                              ),
                            ),
                            // 图片信息
                            Padding(
                              padding: EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '第 ${index + 1} 页',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    '路径: $imagePath',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
