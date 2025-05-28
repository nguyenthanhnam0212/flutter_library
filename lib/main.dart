import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdfx/pdfx.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Ẩn status bar và navigation bar (fullscreen)
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: PDFViewerFromUrl(
        url:
            'https://www.daotranglienhoa.com/wp-content/uploads/2022/01/kinh_dia_tang.pdf',
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
  final TextEditingController _pageInputController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPdf();
  }

  Future<void> _loadPdf() async {
    final file = await DefaultCacheManager().getSingleFile(widget.url);

    _pdfController = PdfController(
      document: PdfDocument.openFile(file.path),
      initialPage: 1,
    );

    final doc = await PdfDocument.openFile(file.path);
    _totalPages = doc.pagesCount;

    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _pdfController.dispose();
    _pageInputController.dispose();
    super.dispose();
  }

  void _goToPage(String text) {
    final page = int.tryParse(text);
    if (page != null && page >= 1 && page <= _totalPages) {
      _pdfController.animateToPage(
        page,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              top: false,
              bottom: false,
              child: Column(
                children: [
                  Container(
                    color: Colors.black87,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    height: 56,
                    child: Row(
                      children: [
                        ValueListenableBuilder<int>(
                          valueListenable: _pdfController.pageListenable,
                          builder: (context, currentPage, _) {
                            return Text(
                              'Trang $currentPage / $_totalPages',
                              style: const TextStyle(color: Colors.white),
                            );
                          },
                        ),
                        const Spacer(),
                        SizedBox(
                          width: 80,
                          child: TextField(
                            controller: _pageInputController,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              hintText: 'Đi đến...',
                              hintStyle: TextStyle(color: Colors.white54),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 8,
                                horizontal: 8,
                              ),
                            ),
                            onSubmitted: _goToPage,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.check, color: Colors.white),
                          onPressed: () => _goToPage(_pageInputController.text),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: PdfView(
                      controller: _pdfController,
                      scrollDirection: Axis.horizontal,
                      pageSnapping: true,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
