import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/transaction_type_rule_controller.dart';
import './transaction_type_rule_form_page.dart';

class TransactionTypeRulesView extends GetView<TransactionTypeRuleController> {
  const TransactionTypeRulesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Transaction Type Rules')),
      body: Obx(() {
        if (controller.isLoading.value && controller.transactionTypeRules.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        final error = controller.errorMessage.value;
        if (error != null && error.isNotEmpty && controller.transactionTypeRules.isEmpty) {
          return Center(child: Text(error));
        }

        return RefreshIndicator(
          onRefresh: controller.loadTransactionTypeRules,
          child: ListView.builder(
            itemCount: controller.transactionTypeRules.length,
            itemBuilder: (context, index) {
              final rule = controller.transactionTypeRules[index];
              return ListTile(
                title: Text(rule.mainHeadName),
                subtitle: Text('${rule.transactionTypeName} • ${rule.entrySide}'),
                trailing: Text('Seq: ${rule.sequenceNo}'),
              );
            },
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Get.to(() => const TransactionTypeRuleFormPage());
          if (result == true && context.mounted) {
            await controller.loadTransactionTypeRules();
            Get.snackbar(
              'Success',
              'Transaction type rule created successfully.',
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
