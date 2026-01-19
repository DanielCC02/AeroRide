import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pdfx/pdfx.dart';

class LegalDocumentScreen extends StatefulWidget {
  final String title;
  final String url;

  const LegalDocumentScreen({
    super.key,
    required this.title,
    required this.url,
  });

  @override
  State<LegalDocumentScreen> createState() => _LegalDocumentScreenState();
}

class _LegalDocumentScreenState extends State<LegalDocumentScreen> {
  PdfController? _pdfController;
  int _currentPage = 1;
  int _pageCount = 0;

  bool get _canAccept => _pageCount > 0 && _currentPage >= _pageCount;

  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPdf();
  }

  Future<void> _loadPdf() async {
    try {
      final res = await http.get(Uri.parse(widget.url));
      if (res.statusCode < 200 || res.statusCode >= 300) {
        throw Exception('HTTP ${res.statusCode}');
      }

      final Uint8List bytes = res.bodyBytes;
      final doc = await PdfDocument.openData(bytes);

      _pdfController =
          PdfController(document: Future.value(doc), initialPage: 1);

      setState(() {
        _pageCount = doc.pagesCount;
        _currentPage = 1;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Could not load the document. Please try again.';
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _pdfController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : Column(
                  children: [
                    Expanded(
                      child: PdfView(
                        controller: _pdfController!,
                        scrollDirection: Axis.vertical, // vertical
                        pageSnapping: false, // scroll continuo
                        onPageChanged: (page) {
                          setState(() => _currentPage = page);
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _canAccept
                              ? () => Navigator.of(context).pop(true)
                              : null,
                          child: Text(
                            _canAccept
                                ? 'Accept'
                                : 'Scroll to the last page to accept',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}
