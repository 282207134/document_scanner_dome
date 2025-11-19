import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cunning_document_scanner/cunning_document_scanner.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '文档扫描器',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: ScannerPage(),
    );
  }
}

class ScannerPage extends StatefulWidget {
  @override
  _ScannerPageState createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  List<String> _images = [];
  bool _scanning = false;

  // 基本扫描
  Future<void> _basicScan() async {
    setState(() => _scanning = true);
    try {
      final images = await CunningDocumentScanner.getPictures();
      if (images != null && images.isNotEmpty) {
        setState(() => _images = images);
        _showMessage('扫描成功 ${images.length} 张');
      } else {
        _showMessage('已取消');
      }
    } catch (e) {
      _showMessage('失败: $e');
    } finally {
      setState(() => _scanning = false);
    }
  }

  // Android 高级扫描
  Future<void> _androidScan() async {
    setState(() => _scanning = true);
    try {
      final images = await CunningDocumentScanner.getPictures(
        noOfPages: 5,
        isGalleryImportAllowed: true,
      );
      if (images != null && images.isNotEmpty) {
        setState(() => _images = images);
        _showMessage('扫描成功 ${images.length} 张');
      }
    } catch (e) {
      _showMessage('失败: $e');
    } finally {
      setState(() => _scanning = false);
    }
  }

  // iOS 高级扫描
  Future<void> _iosScan() async {
    setState(() => _scanning = true);
    try {
      final images = await CunningDocumentScanner.getPictures(
        iosScannerOptions: IosScannerOptions(
          imageFormat: IosImageFormat.jpg,
          jpgCompressionQuality: 0.7,
        ),
      );
      if (images != null && images.isNotEmpty) {
        setState(() => _images = images);
        _showMessage('扫描成功 ${images.length} 张');
      }
    } catch (e) {
      _showMessage('失败: $e');
    } finally {
      setState(() => _scanning = false);
    }
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('文档扫描器'),
        actions: [
          if (_images.isNotEmpty)
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () => setState(() => _images.clear()),
            ),
        ],
      ),
      body: Column(
        children: [
          // 按钮区域
          Container(
            padding: EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Column(
              children: [
                ElevatedButton.icon(
                  onPressed: _scanning ? null : _basicScan,
                  icon: Icon(Icons.document_scanner),
                  label: Text('基本扫描'),
                ),
                SizedBox(height: 8),
                if (Platform.isAndroid)
                  ElevatedButton.icon(
                    onPressed: _scanning ? null : _androidScan,
                    icon: Icon(Icons.android),
                    label: Text('Android 高级'),
                  ),
                if (Platform.isIOS)
                  ElevatedButton.icon(
                    onPressed: _scanning ? null : _iosScan,
                    icon: Icon(Icons.apple),
                    label: Text('iOS 高级'),
                  ),
                if (_scanning)
                  Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: CircularProgressIndicator(),
                  ),
              ],
            ),
          ),
          // 图片列表
          Expanded(
            child: _images.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.camera_alt, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('还没有扫描的文档', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _images.length,
                    padding: EdgeInsets.all(8),
                    itemBuilder: (context, index) {
                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 8),
                        child: Column(
                          children: [
                            Image.file(
                              File(_images[index]),
                              fit: BoxFit.cover,
                              height: 300,
                            ),
                            Padding(
                              padding: EdgeInsets.all(12),
                              child: Text(
                                '第 ${index + 1} 页',
                                style: TextStyle(fontWeight: FontWeight.bold),
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
