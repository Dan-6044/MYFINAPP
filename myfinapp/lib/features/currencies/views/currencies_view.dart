import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/currency_controller.dart';
import '../models/currency.dart';
import 'currency_form_page.dart';

class CurrenciesView extends GetView<CurrencyController> {
  const CurrenciesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Currencies')),
      body: Obx(() {
        if (controller.isLoading.value && controller.currencies.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        final error = controller.errorMessage.value;
        if (error != null && error.isNotEmpty && controller.currencies.isEmpty) {
          return Center(child: Text(error));
        }

        return RefreshIndicator(
          onRefresh: controller.loadCurrencies,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.currencies.length,
            itemBuilder: (context, index) {
              final currency = controller.currencies[index];
              final symbol = currency.currencySymbol ?? '-';

              return _CurrencyListItem(
                currency: currency,
                symbol: symbol,
              );
            },
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Get.to(() => const CurrencyFormPage());
          if (result == true && context.mounted) {
            await controller.loadCurrencies();
            Get.snackbar(
              'Success',
              'Currency created successfully.',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: const Color(0xFF4CAF50),
              colorText: Colors.white,
            );
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _CurrencyListItem extends StatelessWidget {
  const _CurrencyListItem({
    required this.currency,
    required this.symbol,
  });

  final Currency currency;
  final String symbol;

  Future<void> _handleActivateDeactivate(BuildContext context, bool newStatus) async {
    if (newStatus == currency.isActive) return;
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
                newStatus ? 'Activate Currency' : 'Deactivate Currency',
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
              currency.currencyName,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF3D2C2C),
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              newStatus
                  ? 'Are you sure you want to activate this currency?'
                  : 'Are you sure you want to deactivate this currency?',
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
      final currencyController = Get.find<CurrencyController>();
      await currencyController.setActiveStatus(currency.currencyID, newStatus);
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
        Icon(
          currency.isActive ? Icons.check_circle : Icons.cancel,
          color: currency.isActive ? Colors.green : Colors.red,
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
                  () => CurrencyFormPage(currency: currency),
                );
                if (result == true && context.mounted) {
                  final currencyController = Get.find<CurrencyController>();
                  await currencyController.loadCurrencies();
                  Get.snackbar(
                    'Success',
                    'Currency updated successfully.',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: const Color(0xFF4CAF50),
                    colorText: Colors.white,
                  );
                }
              }
              if (value == 'activate' || value == 'deactivate') {
                final newStatus = value == 'activate';
                await _handleActivateDeactivate(context, newStatus);
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
              PopupMenuItem(
                value: currency.isActive ? 'deactivate' : 'activate',
                child: Row(
                  children: [
                    Icon(
                      currency.isActive ? Icons.cancel_rounded : Icons.check_circle_rounded,
                      size: 18,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      currency.isActive ? 'Deactivate' : 'Activate',
                      style: const TextStyle(color: Colors.white),
                    ),
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
                    '${currency.currencyCode} - ${currency.currencyName}',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF3D2C2C),
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Symbol: $symbol • Base: ${currency.isActive ? 'Yes' : 'No'}',
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
