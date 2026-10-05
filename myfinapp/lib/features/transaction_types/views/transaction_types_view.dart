import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../transaction_types/controllers/transaction_type_controller.dart';
import '../../transaction_types/models/transaction_type.dart';
import '../../transaction_types/views/transaction_type_form_page.dart';

class TransactionTypesView extends GetView<TransactionTypeController> {
  const TransactionTypesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value && controller.transactionTypes.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      final error = controller.errorMessage.value;
      if (error != null && error.isNotEmpty && controller.transactionTypes.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.wifi_off_rounded, size: 40, color: Color(0xFFD6C8C0)),
                const SizedBox(height: 12),
                Text(
                  'Unable to load transaction types',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF3D2C2C),
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  'Please check your connection and try again.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF8C7B7B),
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: controller.loadTransactionTypes,
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        );
      }

      if (controller.transactionTypes.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.swap_horiz_rounded, size: 40, color: Color(0xFFD6C8C0)),
                const SizedBox(height: 12),
                Text(
                  'No Transaction Types',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF3D2C2C),
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  'No transaction types have been created yet.',
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

      return RefreshIndicator(
        onRefresh: controller.loadTransactionTypes,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.transactionTypes.length,
          itemBuilder: (context, index) {
            final transactionType = controller.transactionTypes[index];

            return _TransactionTypeListItem(
              transactionType: transactionType,
            );
          },
        ),
      );
    });
  }
}

class _TransactionTypeListItem extends StatelessWidget {
  const _TransactionTypeListItem({
    required this.transactionType,
  });

  final TransactionType transactionType;

  Future<void> _handleActivateDeactivate(BuildContext context, bool newStatus) async {
    if (newStatus == transactionType.isActive) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Icon(
              newStatus ? Icons.check_circle_rounded : Icons.cancel_rounded,
              size: 22,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                newStatus ? 'Activate Transaction Type' : 'Deactivate Transaction Type',
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
              transactionType.transactionTypeName,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF3D2C2C),
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              newStatus
                  ? 'Are you sure you want to activate this transaction type?'
                  : 'Are you sure you want to deactivate this transaction type?',
              style: const TextStyle(color: Color(0xFF8C7B7B)),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            child: Text(newStatus ? 'Activate' : 'Deactivate'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      final transactionTypeController = Get.find<TransactionTypeController>();
      await transactionTypeController.setActiveStatus(transactionType.transactionTypeID, newStatus);
    } catch (e) {
      if (context.mounted) {
        Get.snackbar(
          'Error',
          e.toString().replaceFirst('Exception: ', ''),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFE53935),
          colorText: Colors.white,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final trailing = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: transactionType.isActive ? const Color(0xFFFFF7EF) : const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: transactionType.isActive ? const Color(0xFFF4793A) : const Color(0xFFBDBDBD),
              width: 1,
            ),
          ),
          child: Text(
            transactionType.isActive ? 'Active' : 'Inactive',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: transactionType.isActive ? const Color(0xFFF4793A) : const Color(0xFF757575),
              letterSpacing: 0.4,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Switch(
          value: transactionType.isActive,
          onChanged: (value) => _handleActivateDeactivate(context, value),
          activeThumbColor: const Color(0xFFF4793A),
          activeTrackColor: const Color(0xFFFFF7EF),
          inactiveThumbColor: Colors.white,
          inactiveTrackColor: const Color(0xFFE0E0E0),
        ),
        const SizedBox(width: 8),
        Theme(
          data: Theme.of(context).copyWith(
            popupMenuTheme: PopupMenuThemeData(
              color: const Color(0xFFF4793A),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          child: PopupMenuButton<String>(
            icon: Icon(Icons.more_vert_rounded, size: 18, color: const Color(0xFFF4793A)),
            onSelected: (value) async {
              if (value == 'edit') {
                final result = await Get.to(
                  () => TransactionTypeFormPage(transactionType: transactionType),
                );
                if (result == true && context.mounted) {
                  final transactionTypeController = Get.find<TransactionTypeController>();
                  await transactionTypeController.loadTransactionTypes();
                  Get.snackbar(
                    'Success',
                    'Transaction type updated successfully.',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: const Color(0xFF4CAF50),
                    colorText: Colors.white,
                  );
                }
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit_rounded, size: 18, color: Colors.white),
                    const SizedBox(width: 12),
                    const Text('Edit', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );

    return InkWell(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xFFF0E6DC), width: 1)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${transactionType.transactionTypeCode} - ${transactionType.transactionTypeName}',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF3D2C2C),
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    transactionType.description ?? '-',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: const Color(0xFF8C7B7B),
                        ),
                  ),
                ],
              ),
            ),
            ...trailing.children,
          ],
        ),
      ),
    );
  }
}
