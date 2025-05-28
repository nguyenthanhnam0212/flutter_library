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
            'https://thpthiephoa1.edu.vn/wp-content/uploads/Truyen-co-Girmm-Jakob-Girmm.pdf',
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
  late PdfController _pdfController;
  bool _isLoading = true;
  int _totalPages = 0;

  @override
  void initState() {
    super.initState();
    _loadPdf();
  }

  Future<void> _loadPdf() async {
    final file = await DefaultCacheManager().getSingleFile(widget.url);
    final doc = await PdfDocument.openFile(file.path);
    _totalPages = doc.pagesCount;

    _pdfController = PdfController(
      document: PdfDocument.openFile(file.path), // truyền Future luôn
      initialPage: 1,
    );

    setState(() {
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
          : PdfView(
              controller: _pdfController,
              scrollDirection: Axis.horizontal,
              pageSnapping: true,
            ),
      bottomNavigationBar: _isLoading
          ? null
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: ValueListenableBuilder<int>(
                valueListenable: _pdfController.pageListenable,
                builder: (context, currentPage, _) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () async {
                          if (currentPage > 1) {
                            await _pdfController.animateToPage(
                              currentPage - 1,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        },
                      ),
                      Text('Trang $currentPage / $_totalPages'),
                      IconButton(
                        icon: const Icon(Icons.arrow_forward),
                        onPressed: () async {
                          if (currentPage < _totalPages) {
                            await _pdfController.animateToPage(
                              currentPage + 1,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
    );
  }
}
