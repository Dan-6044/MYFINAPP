import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/widgets/form_fields.dart';
import '../../../core/widgets/myfin_footer.dart';
import '../../financial_periods/controllers/financial_period_controller.dart';
import '../../financial_periods/models/financial_period.dart';

class CloseFinancialPeriodPage extends StatefulWidget {
  const CloseFinancialPeriodPage({super.key, required this.period});

  final FinancialPeriod period;

  @override
  State<CloseFinancialPeriodPage> createState() => _CloseFinancialPeriodPageState();
}

class _CloseFinancialPeriodPageState extends State<CloseFinancialPeriodPage> {
  final _isSaving = false.obs;

  Future<void> _close() async {
    _isSaving.value = true;

    try {
      final controller = Get.find<FinancialPeriodController>();
      await controller.closePeriod(widget.period);

      if (mounted) {
        Get.snackbar(
          'Success',
          'Financial period closed successfully.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF4CAF50),
          colorText: Colors.white,
        );
        Get.back();
      }
    } catch (e) {
      if (mounted) {
        Get.snackbar(
          'Error',
          e.toString().replaceFirst('Exception: ', ''),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFE04057),
          colorText: Colors.white,
        );
      }
    } finally {
      _isSaving.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final status = widget.period.status.toUpperCase();

    return FormPageScaffold(
      title: 'Close Financial Period',
      subtitle: 'This action will close the selected financial period.',
      isSaving: _isSaving.value,
      onSave: _close,
      onCancel: () => Get.back(),
      saveLabel: 'Close Financial Period',
      footer: const MyfinFooter(),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF7EF),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE8DDD6)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _InfoRow(label: 'Period Code', value: widget.period.periodCode),
              const SizedBox(height: 8),
              _InfoRow(label: 'Period Name', value: widget.period.periodName),
              const SizedBox(height: 8),
              _InfoRow(label: 'Status', value: status),
              const SizedBox(height: 8),
              _InfoRow(label: 'Start Date', value: widget.period.startDate),
              const SizedBox(height: 8),
              _InfoRow(label: 'End Date', value: widget.period.endDate),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Are you sure you want to close this financial period? Once closed, no further transactions can be recorded in this period.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: const Color(0xFF8C7B7B),
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: const Color(0xFF8C7B7B),
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: const Color(0xFF3D2C2C),
          ),
        ),
      ],
    );
  }
}
