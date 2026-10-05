import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/widgets/myfin_footer.dart';
import '../controllers/transaction_controller.dart';
import '../controllers/credit_loans_controller.dart';
import 'transaction_form_page.dart';
import 'transactions_view.dart';
import 'journals_view.dart';
import 'credit_loans_view.dart';

class AccountingView extends StatefulWidget {
  const AccountingView({super.key});

  @override
  State<AccountingView> createState() => _AccountingViewState();
}

class _AccountingViewState extends State<AccountingView> {
  static const _items = <_AccountingMenuItem>[
    _AccountingMenuItem(
      id: 'transactions',
      title: 'Transactions',
      icon: Icons.receipt_long_rounded,
    ),
    _AccountingMenuItem(
      id: 'journals',
      title: 'Journals',
      icon: Icons.book_rounded,
    ),
    _AccountingMenuItem(
      id: 'credit_loans',
      title: 'Credit/Loans',
      icon: Icons.credit_card_rounded,
    ),
    _AccountingMenuItem(
      id: 'credit_payments',
      title: 'Credit Payments',
      icon: Icons.payments_rounded,
    ),
    _AccountingMenuItem(
      id: 'saving_goals',
      title: 'Saving Goals',
      icon: Icons.savings_rounded,
    ),
    _AccountingMenuItem(
      id: 'saving_contributions',
      title: 'Saving Contributions',
      icon: Icons.add_rounded,
    ),
    _AccountingMenuItem(
      id: 'budgets',
      title: 'Budgets',
      icon: Icons.account_balance_wallet_rounded,
    ),
  ];

  var _selectedId = 'transactions';
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final selectedItem = _items.firstWhere(
      (item) => item.id == _selectedId,
      orElse: () => _items.first,
    );

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFE0E0E0),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu_rounded, color: Color(0xFF3D2C2C)),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: Text(
          selectedItem.title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: const Color(0xFF3D2C2C),
              ),
        ),
        centerTitle: false,
      ),
      drawer: _AccountingDrawer(
        items: _items,
        selectedId: _selectedId,
        onSelected: (id) {
          setState(() => _selectedId = id);
          Navigator.pop(context);
        },
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: _buildContent(selectedItem.id)),
            const MyfinFooter(),
          ],
        ),
      ),
      floatingActionButton: _selectedId == 'transactions'
          ? FloatingActionButton(
              onPressed: _onAddTransactionPressed,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : _selectedId == 'credit_loans'
              ? FloatingActionButton(
                  onPressed: _onAddCreditLoanPressed,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: const Icon(Icons.add, color: Colors.white),
                )
              : null,
    );
  }

  Future<void> _onAddTransactionPressed() async {
    final result = await Get.to(() => const TransactionFormPage());
    if (result == true && mounted) {
      try {
        final controller = Get.find<TransactionController>();
        await controller.loadTransactions();
        Get.snackbar(
          'Success',
          'Transaction created successfully.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF4CAF50),
          colorText: Colors.white,
        );
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
  }

  Future<void> _onAddCreditLoanPressed() async {
    final result = await Get.to(
      () => const TransactionFormPage(
        title: 'New Credit/Loan Transaction',
      ),
    );
    if (result == true && mounted) {
      try {
        final controller = Get.find<CreditLoansController>();
        await controller.loadCreditLoans();
        Get.snackbar(
          'Success',
          'Credit/Loan transaction created successfully.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF4CAF50),
          colorText: Colors.white,
        );
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
  }

  Widget _buildContent(String id) {
    switch (id) {
      case 'transactions':
        return const TransactionsView();
      case 'journals':
        return const JournalsView();
      case 'credit_loans':
        return const CreditLoansView();
      case 'credit_payments':
        return const _AccountingPlaceholder(title: 'Credit Payments');
      case 'saving_goals':
        return const _AccountingPlaceholder(title: 'Saving Goals');
      case 'saving_contributions':
        return const _AccountingPlaceholder(title: 'Saving Contributions');
      case 'budgets':
        return const _AccountingPlaceholder(title: 'Budgets');
      default:
        return const _AccountingPlaceholder(title: 'Accounting');
    }
  }
}

class _AccountingDrawer extends StatelessWidget {
  final List<_AccountingMenuItem> items;
  final String selectedId;
  final ValueChanged<String> onSelected;

  const _AccountingDrawer({
    required this.items,
    required this.selectedId,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.72,
      child: Container(
        color: const Color(0xFFF4793A),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 18),
                child: Text(
                  'Accounting',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
              const Divider(color: Color(0x33FFFFFF), height: 1),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final isSelected = item.id == selectedId;
                    return _DrawerTile(
                      item: item,
                      isSelected: isSelected,
                      onTap: () => onSelected(item.id),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DrawerTile extends StatelessWidget {
  final _AccountingMenuItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const _DrawerTile({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: Container(
        color: isSelected ? const Color(0x26FFFFFF) : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Icon(
              item.icon,
              color: Colors.white,
              size: 22,
            ),
            const SizedBox(width: 14),
            Text(
              item.title,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccountingPlaceholder extends StatelessWidget {
  final String title;

  const _AccountingPlaceholder({required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_open_rounded, size: 48, color: const Color(0xFFD6C8C0)),
            const SizedBox(height: 16),
            Text(
              '$title module',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF3D2C2C),
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'This module will be implemented in a later phase.',
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
}

class _AccountingMenuItem {
  final String id;
  final String title;
  final IconData icon;

  const _AccountingMenuItem({
    required this.id,
    required this.title,
    required this.icon,
  });
}
