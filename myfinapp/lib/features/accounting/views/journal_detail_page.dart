import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:myfinapp/features/accounting/controllers/journal_controller.dart';
import 'package:myfinapp/core/widgets/myfin_footer.dart';
import 'package:myfinapp/features/accounting/models/transaction_model.dart';
import 'transaction_detail_page.dart';
import 'dart:io';

class JournalDetailPage extends StatefulWidget {
  const JournalDetailPage({super.key, required this.journalId});

  final int journalId;

  @override
  State<JournalDetailPage> createState() => _JournalDetailPageState();
}

class _JournalDetailPageState extends State<JournalDetailPage> {
  final JournalController _controller = Get.find<JournalController>();
  final RxBool _isLoading = false.obs;
  final Rx<String?> _errorMessage = Rxn<String>();
  final Rxn<JournalDetailModel> _journal = Rxn<JournalDetailModel>();

  @override
  void initState() {
    super.initState();
    _loadJournal();
  }

  Future<void> _loadJournal() async {
    _isLoading.value = true;
    _errorMessage.value = null;
    try {
      final data = await _controller.getJournalDetails(widget.journalId);
      _journal.value = data;
    } catch (e) {
      _errorMessage.value = e.toString();
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> _viewTransaction() async {
    final journal = _journal.value;
    if (journal == null) return;

    final result = await Get.to(
      () => TransactionDetailPage(transactionId: journal.transactionId),
    );
    if (result == true && mounted) {
      await _loadJournal();
    }
  }

  Future<void> _exportPdf() async {
    final journal = _journal.value;
    if (journal == null) return;

    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('MYFIN', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                pw.Text('Journal Details', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 20),
                pw.Text('Journal ID: ${journal.journalId}', style: const pw.TextStyle(fontSize: 12)),
                pw.Text('Journal Number: ${journal.journalNumber}', style: const pw.TextStyle(fontSize: 12)),
                pw.Text('Transaction: ${journal.transactionNumber}', style: const pw.TextStyle(fontSize: 12)),
                pw.Text('Type: ${journal.transactionTypeCode} - ${journal.transactionTypeName}', style: const pw.TextStyle(fontSize: 12)),
                pw.Text('Date: ${DateFormat('dd MMMM yyyy').format(journal.journalDate)}', style: const pw.TextStyle(fontSize: 12)),
                pw.Text('Status: ${journal.status}', style: const pw.TextStyle(fontSize: 12)),
                if (journal.description != null)
                  pw.Text('Description: ${journal.description}', style: const pw.TextStyle(fontSize: 12)),
                pw.SizedBox(height: 20),
                pw.Text('Journal Lines', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 10),
                pw.TableHelper.fromTextArray(
                  headers: ['Account', 'Description', 'Debit', 'Credit'],
                  data: journal.lines
                      .map((line) => [
                            '${line.coaCode} - ${line.coaName}',
                            line.description ?? '-',
                            line.debitAmount > 0 ? line.debitAmount.toStringAsFixed(2) : '-',
                            line.creditAmount > 0 ? line.creditAmount.toStringAsFixed(2) : '-',
                          ])
                      .toList(),
                ),
                pw.SizedBox(height: 20),
                pw.Text('Total Debit: ${journal.totalDebit.toStringAsFixed(2)}', style: const pw.TextStyle(fontSize: 12)),
                pw.Text('Total Credit: ${journal.totalCredit.toStringAsFixed(2)}', style: const pw.TextStyle(fontSize: 12)),
              ],
            );
          },
        ),
      );

      final bytes = await pdf.save();
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/MYFIN_Journal_${journal.journalNumber}.pdf');
      await file.writeAsBytes(bytes);

      Get.snackbar(
        'Success',
        'PDF exported: ${file.path}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF4CAF50),
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to export PDF: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFE53935),
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFE0E0E0),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF3D2C2C)),
          onPressed: () => Get.back(result: true),
        ),
        title: Text(
          'Journal Details',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: const Color(0xFF3D2C2C),
              ),
        ),
        centerTitle: false,
      ),
      body: Obx(() {
        if (_isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final error = _errorMessage.value;
        if (error != null && _journal.value == null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.wifi_off_rounded, size: 40, color: Color(0xFFD6C8C0)),
                  const SizedBox(height: 12),
                  Text(
                    'Unable to load journal details',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF3D2C2C),
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    error,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: const Color(0xFF8C7B7B),
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        final journal = _journal.value;
        if (journal == null) {
          return const SizedBox.shrink();
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Journal ID: ${journal.journalId}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF8C7B7B),
                      fontWeight: FontWeight.w500,
                    ),
              ),
              const SizedBox(height: 12),
              Text(
                journal.journalNumber,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF3D2C2C),
                    ),
              ),
              const SizedBox(height: 20),
              Text(
                'Journal Information',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF3D2C2C),
                    ),
              ),
              const SizedBox(height: 12),
              _buildDisabledDropdown(
                context,
                'Transaction',
                journal.transactionNumber,
              ),
              const SizedBox(height: 12),
              _buildDisabledDropdown(
                context,
                'Transaction Type',
                '${journal.transactionTypeCode} - ${journal.transactionTypeName}',
              ),
              const SizedBox(height: 12),
              _buildDisabledField(
                context,
                'Journal Date',
                DateFormat('dd MMMM yyyy').format(journal.journalDate),
              ),
              const SizedBox(height: 12),
              _buildDisabledField(context, 'Description', journal.description ?? ''),
              const SizedBox(height: 12),
              _buildDisabledField(context, 'Status', journal.status),
              const SizedBox(height: 20),
              Row(
                children: [
                  Text(
                    'Journal Lines',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF3D2C2C),
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...journal.lines.map((line) => _JournalLineCard(line: line)),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7EF),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFF0E6DC)),
                ),
                child: Row(
                  children: [
                    Text(
                      'Total Debit: ${journal.totalDebit.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF3D2C2C),
                          ),
                    ),
                    const Spacer(),
                    Text(
                      'Total Credit: ${journal.totalCredit.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF3D2C2C),
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  ElevatedButton.icon(
                    onPressed: _viewTransaction,
                    icon: const Icon(Icons.receipt_long_rounded, size: 18),
                    label: const Text('View Transaction'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2196F3),
                      foregroundColor: Colors.white,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _exportPdf,
                    icon: const Icon(Icons.picture_as_pdf_rounded, size: 18),
                    label: const Text('Export PDF'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF4793A),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const MyfinFooter(),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildDisabledField(BuildContext context, String label, String value) {
    return TextField(
      controller: TextEditingController(text: value),
      enabled: false,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: const Color(0xFFF5EBE0),
        border: const OutlineInputBorder(),
        disabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      maxLines: label == 'Description' ? 3 : 1,
    );
  }

  Widget _buildDisabledDropdown(BuildContext context, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF5EBE0),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF8C7B7B),
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  value.isEmpty ? '-' : value,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF222222),
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _JournalLineCard extends StatelessWidget {
  const _JournalLineCard({required this.line});

  final JournalLineModel line;

  @override
  Widget build(BuildContext context) {
    final isDebit = line.debitAmount > 0;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7EF),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFF0E6DC)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${line.coaCode} - ${line.coaName}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF3D2C2C),
                      ),
                ),
                if (line.description != null)
                  Text(
                    line.description!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: const Color(0xFF8C7B7B),
                        ),
                  ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                isDebit ? 'Debit' : 'Credit',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF8C7B7B),
                    ),
              ),
              Text(
                (isDebit ? line.debitAmount : line.creditAmount).toStringAsFixed(2),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF3D2C2C),
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
