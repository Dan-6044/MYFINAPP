import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../../core/widgets/myfin_footer.dart';
import '../../../modules/auth/controllers/auth_controller.dart';
import '../../financial_periods/controllers/financial_period_controller.dart';
import '../controllers/transaction_controller.dart';
import '../models/transaction_model.dart';

class TransactionDetailPage extends StatefulWidget {
  const TransactionDetailPage({super.key, required this.transactionId});

  final int transactionId;

  @override
  State<TransactionDetailPage> createState() => _TransactionDetailPageState();
}

class _TransactionDetailPageState extends State<TransactionDetailPage> {
  final TransactionController _controller = Get.find<TransactionController>();
  final RxBool _isLoading = false.obs;
  final Rx<String?> _errorMessage = Rxn<String>();
  final Rxn<TransactionDetailModel> _transaction = Rxn<TransactionDetailModel>();

  @override
  void initState() {
    super.initState();
    _loadTransaction();
  }

  Future<void> _loadTransaction() async {
    _isLoading.value = true;
    _errorMessage.value = null;
    try {
      final data = await _controller.getTransactionDetails(widget.transactionId);
      _transaction.value = data;
    } catch (e) {
      _errorMessage.value = e.toString();
    } finally {
      _isLoading.value = false;
    }
  }

  bool get _isPosted => _transaction.value?.status.toUpperCase() == 'POSTED';
  bool get _isVoided => _transaction.value?.status.toUpperCase() == 'VOIDED';
  bool get _isDraft => _transaction.value?.status.toUpperCase() == 'DRAFT';
  bool get _isValidated => _transaction.value?.status.toUpperCase() == 'VALIDATED';

  Future<void> _postTransaction() async {
    final transaction = _transaction.value;
    if (transaction == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Icon(
              Icons.check_circle_rounded,
              size: 22,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                'Post Transaction',
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              transaction.transactionNumber,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF3D2C2C),
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Are you sure you want to post this transaction? This will create journal entries and affect accounting balances.',
              style: const TextStyle(color: Color(0xFF8C7B7B)),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Post'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final authController = Get.find<AuthController>();
      await _controller.postTransaction(transaction.transactionId, authController.userID.value);
      await _loadTransaction();
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString().replaceFirst('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFE53935),
        colorText: Colors.white,
      );
    }
  }

  Future<void> _validateTransaction() async {
    final transaction = _transaction.value;
    if (transaction == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Icon(
              Icons.verified_rounded,
              size: 22,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                'Validate Transaction',
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              transaction.transactionNumber,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF3D2C2C),
                  ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Are you sure you want to validate this transaction? Once validated, it can be posted.',
              style: TextStyle(color: Color(0xFF8C7B7B)),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Validate'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _controller.validateTransaction(transaction.transactionId);
      await _loadTransaction();
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString().replaceFirst('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFE53935),
        colorText: Colors.white,
      );
    }
  }

  Future<void> _voidTransaction() async {
    final transaction = _transaction.value;
    if (transaction == null) return;

    final voidReasonController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Icon(
              Icons.cancel_rounded,
              size: 22,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                'Void Transaction',
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              transaction.transactionNumber,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF3D2C2C),
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Are you sure you want to void this transaction? This action cannot be undone.',
              style: const TextStyle(color: Color(0xFF8C7B7B)),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: voidReasonController,
              decoration: const InputDecoration(
                labelText: 'Void Reason',
                hintText: 'Enter reason for voiding',
                filled: true,
                fillColor: Color(0xFFF5EBE0),
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE04057)),
            child: const Text('Void Transaction'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final voidReason = voidReasonController.text.trim();
    if (voidReason.isEmpty) {
      Get.snackbar(
        'Validation',
        'Please enter a void reason.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFE04057),
        colorText: Colors.white,
      );
      return;
    }

    try {
      final authController = Get.find<AuthController>();
      await _controller.voidTransaction(transaction.transactionId, authController.userID.value, voidReason);
      await _loadTransaction();
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString().replaceFirst('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFE53935),
        colorText: Colors.white,
      );
    }
  }

  Future<void> _exportPdf() async {
    final transaction = _transaction.value;
    if (transaction == null) return;

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
                pw.Text('Transaction Details', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 20),
                pw.Text('Transaction ID: ${transaction.transactionId}', style: const pw.TextStyle(fontSize: 12)),
                pw.Text('Transaction Number: ${transaction.transactionNumber}', style: const pw.TextStyle(fontSize: 12)),
                pw.Text('Type: ${transaction.transactionTypeCode} - ${transaction.transactionTypeName}', style: const pw.TextStyle(fontSize: 12)),
                pw.Text('Date: ${DateFormat('dd MMMM yyyy').format(transaction.transactionDate)}', style: const pw.TextStyle(fontSize: 12)),
                pw.Text('Status: ${transaction.status}', style: const pw.TextStyle(fontSize: 12)),
                if (transaction.description != null)
                  pw.Text('Description: ${transaction.description}', style: const pw.TextStyle(fontSize: 12)),
                if (transaction.referenceNumber != null)
                  pw.Text('Reference: ${transaction.referenceNumber}', style: const pw.TextStyle(fontSize: 12)),
                pw.SizedBox(height: 20),
                pw.Text('Transaction Lines', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 10),
                pw.TableHelper.fromTextArray(
                  headers: ['Account', 'Description', 'Debit', 'Credit'],
                  data: transaction.lines
                      .map((line) => [
                            '${line.coaCode} - ${line.coaName}',
                            line.description ?? '-',
                            line.debitAmount > 0 ? line.debitAmount.toStringAsFixed(2) : '-',
                            line.creditAmount > 0 ? line.creditAmount.toStringAsFixed(2) : '-',
                          ])
                      .toList(),
                ),
                pw.SizedBox(height: 20),
                pw.Text('Total Debit: ${transaction.totalDebit.toStringAsFixed(2)}', style: const pw.TextStyle(fontSize: 12)),
                pw.Text('Total Credit: ${transaction.totalCredit.toStringAsFixed(2)}', style: const pw.TextStyle(fontSize: 12)),
              ],
            );
          },
        ),
      );

      final bytes = await pdf.save();
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/MYFIN_Transaction_${transaction.transactionNumber}.pdf');
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
          'Transaction Details',
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
        if (error != null && _transaction.value == null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.wifi_off_rounded, size: 40, color: Color(0xFFD6C8C0)),
                  const SizedBox(height: 12),
                  Text(
                    'Unable to load transaction details',
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

        final transaction = _transaction.value;
        if (transaction == null) {
          return const SizedBox.shrink();
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Transaction ID: ${transaction.transactionId}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF8C7B7B),
                      fontWeight: FontWeight.w500,
                    ),
              ),
              const SizedBox(height: 12),
              Text(
                transaction.transactionNumber,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF3D2C2C),
                    ),
              ),
              const SizedBox(height: 20),
              Text(
                'Transaction Information',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF3D2C2C),
                    ),
              ),
              const SizedBox(height: 12),
              _buildDisabledDropdown(
                context,
                'Transaction Type',
                '${transaction.transactionTypeCode} - ${transaction.transactionTypeName}',
              ),
              const SizedBox(height: 12),
              _buildDisabledDropdown(
                context,
                'Financial Period',
                _resolveFinancialPeriodLabel(transaction.financialPeriodId),
              ),
              const SizedBox(height: 12),
              _buildDisabledField(context, 'Transaction Date', DateFormat('dd MMMM yyyy').format(transaction.transactionDate)),
              const SizedBox(height: 12),
              _buildDisabledField(context, 'Description', transaction.description ?? ''),
              const SizedBox(height: 12),
              _buildDisabledField(context, 'Reference Number', transaction.referenceNumber ?? ''),
              const SizedBox(height: 20),
              Row(
                children: [
                  Text(
                    'Transaction Lines',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF3D2C2C),
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...transaction.lines.map((line) => _TransactionLineCard(line: line)),
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
                      'Total Debit: ${transaction.totalDebit.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF3D2C2C),
                          ),
                    ),
                    const Spacer(),
                    Text(
                      'Total Credit: ${transaction.totalCredit.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF3D2C2C),
                          ),
                    ),
                  ],
                ),
              ),
              if (transaction.journal != null) ...[
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
                  'Journal Number',
                  transaction.journal!.journalNumber,
                ),
                const SizedBox(height: 12),
                _buildDisabledField(
                  context,
                  'Journal Date',
                  DateFormat('dd MMMM yyyy').format(transaction.journal!.journalDate),
                ),
                const SizedBox(height: 12),
                _buildDisabledDropdown(
                  context,
                  'Journal Status',
                  transaction.journal!.status,
                ),
                const SizedBox(height: 12),
                ...transaction.journal!.lines.map((line) => _JournalLineCard(line: line)),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF4CAF50)),
                  ),
                  child: Row(
                    children: [
                      Text(
                        'Journal Debit: ${transaction.journal!.totalDebit.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF2E7D32),
                            ),
                      ),
                      const Spacer(),
                      Text(
                        'Journal Credit: ${transaction.journal!.totalCredit.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF2E7D32),
                            ),
                      ),
                    ],
                  ),
                ),
              ],
              if (transaction.voidedAt != null) ...[
                const SizedBox(height: 20),
                Text(
                  'Void Information',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFC62828),
                      ),
                ),
                const SizedBox(height: 12),
                _buildDisabledField(
                  context,
                  'Voided At',
                  DateFormat('dd MMMM yyyy HH:mm').format(transaction.voidedAt!),
                ),
                const SizedBox(height: 12),
                _buildDisabledField(context, 'Void Reason', transaction.voidReason ?? '-'),
              ],
              const SizedBox(height: 20),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  if (_isDraft)
                    ElevatedButton.icon(
                      onPressed: _validateTransaction,
                      icon: const Icon(Icons.verified_rounded, size: 18),
                      label: const Text('Validate'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2196F3),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  if (_isValidated && !_isPosted && !_isVoided)
                    ElevatedButton.icon(
                      onPressed: _postTransaction,
                      icon: const Icon(Icons.check_circle_rounded, size: 18),
                      label: const Text('Post'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  if (!_isVoided && !_isPosted)
                    ElevatedButton.icon(
                      onPressed: _voidTransaction,
                      icon: const Icon(Icons.cancel_rounded, size: 18),
                      label: const Text('Void Transaction'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE04057),
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

  String _resolveFinancialPeriodLabel(int financialPeriodId) {
    try {
      final period = Get.find<FinancialPeriodController>().periods.firstWhereOrNull(
            (p) => (p as dynamic).financialPeriodID == financialPeriodId,
          );
      if (period != null) {
        final p = period as dynamic;
        return '${p.periodCode} - ${p.periodName}';
      }
    } catch (_) {
      // ignore
    }
    return 'Period $financialPeriodId';
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

class _TransactionLineCard extends StatelessWidget {
  const _TransactionLineCard({required this.line});

  final TransactionDetailLineModel line;

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

class _JournalLineCard extends StatelessWidget {
  const _JournalLineCard({required this.line});

  final TransactionJournalLineModel line;

  @override
  Widget build(BuildContext context) {
    final isDebit = line.debitAmount > 0;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF4CAF50)),
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
                        color: const Color(0xFF2E7D32),
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
                      color: const Color(0xFF2E7D32),
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
