import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: PDFViewerFromUrl(
        url:
            'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
      ),
    );
  }
}

class PDFViewerFromUrl extends StatefulWidget {
  final String url;

  const PDFViewerFromUrl({super.key, required this.url});

  @override
  State<PDFViewerFromUrl> createState() => _PDFViewerFromUrlState();
}

class _PDFViewerFromUrlState extends State<PDFViewerFromUrl> {
  late PdfControllerPinch _pdfController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPdf();
  }

  Future<void> _loadPdf() async {
    final file = await DefaultCacheManager().getSingleFile(widget.url);

    setState(() {
      _pdfController = PdfControllerPinch(
        document: PdfDocument.openFile(file.path), // ✅ KHÔNG await ở đây
      );
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _pdfController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PDF Viewer')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : PdfViewPinch(controller: _pdfController),
    );
  }
}
