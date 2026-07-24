import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:ascento_abacus/shared/models/feature_models.dart';

class TimetablePdfGenerator {
  static Future<Uint8List> generatePdfBytes(
    List<TimetableSlot> slots, 
    String className, 
    String sectionName,
  ) async {
    final pdf = pw.Document();

    final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
    final periods = ['P1', 'P2', 'P3', 'P4', 'P5', 'P6', 'P7', 'P8'];

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Ascento Abacus',
                        style: pw.TextStyle(fontSize: 28, fontWeight: pw.FontWeight.bold, color: PdfColors.blue800),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'Official Timetable',
                        style: pw.TextStyle(fontSize: 16, color: PdfColors.grey700),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'Class: $className',
                        style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
                      ),
                      pw.Text(
                        'Section: $sectionName',
                        style: pw.TextStyle(fontSize: 14, color: PdfColors.grey700),
                      ),
                    ],
                  ),
                ],
              ),
              pw.Divider(thickness: 2, color: PdfColors.blue800),
              pw.SizedBox(height: 16),

              // Timetable Grid
              pw.Expanded(
                child: pw.TableHelper.fromTextArray(
                  context: context,
                  headers: ['Day', ...periods],
                  data: List.generate(days.length, (dayIndex) {
                    final dayName = days[dayIndex];
                    final daySlots = slots.where((s) => s.dayOfWeek == dayIndex + 1).toList();
                    daySlots.sort((a, b) => a.startTime.compareTo(b.startTime));

                    return [
                      dayName,
                      ...List.generate(periods.length, (pIndex) {
                        if (pIndex < daySlots.length) {
                          final slot = daySlots[pIndex];
                          return '${slot.subject}\n${slot.startTime} - ${slot.endTime}\n${slot.teacherName}';
                        }
                        return '';
                      }),
                    ];
                  }),
                  headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white, fontSize: 12),
                  headerDecoration: pw.BoxDecoration(
                    color: PdfColors.blue800,
                  ),
                  cellAlignment: pw.Alignment.center,
                  cellPadding: const pw.EdgeInsets.all(8),
                  border: pw.TableBorder.all(color: PdfColors.grey400, width: 1),
                  cellStyle: const pw.TextStyle(fontSize: 10),
                  oddRowDecoration: const pw.BoxDecoration(color: PdfColors.grey100),
                ),
              ),

              // Footer
              pw.SizedBox(height: 12),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Generated securely from Ascento Abacus system', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
                  pw.Text('Date: ${DateTime.now().toString().split(' ')[0]}', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
                ],
              ),
            ],
          );
        },
      ),
    );

    return await pdf.save();
  }
}
