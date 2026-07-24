import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:printing/printing.dart';

class TimetablePdfPreviewScreen extends StatelessWidget {
  final Uint8List pdfBytes;
  final String title;

  const TimetablePdfPreviewScreen({
    super.key,
    required this.pdfBytes,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            tooltip: 'Print Timetable',
            onPressed: () async {
              await Printing.layoutPdf(
                onLayout: (_) => pdfBytes,
                name: '$title.pdf',
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'Download / Share PDF',
            onPressed: () async {
              await Printing.sharePdf(
                bytes: pdfBytes,
                filename: '$title.pdf',
              );
            },
          ),
        ],
      ),
      body: SfPdfViewer.memory(pdfBytes),
    );
  }
}
