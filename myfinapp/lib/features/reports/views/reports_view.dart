import 'package:flutter/material.dart';
import '../../../../core/widgets/menu_item_tile.dart';

class ReportsView extends StatelessWidget {
  const ReportsView({super.key});

  static const _items = [
    _SectionItem(
      title: 'Trial Balance',
      icon: Icons.balance_rounded,
    ),
    _SectionItem(
      title: 'Profit & Loss',
      icon: Icons.trending_up_rounded,
    ),
    _SectionItem(
      title: 'Balance Sheet',
      icon: Icons.description_rounded,
    ),
    _SectionItem(
      title: 'Account Statement',
      icon: Icons.account_balance_rounded,
    ),
    _SectionItem(
      title: 'Cash Flow Statement',
      icon: Icons.waterfall_chart_rounded,
    ),
    _SectionItem(
      title: 'Income Statement',
      icon: Icons.pie_chart_rounded,
    ),
    _SectionItem(
      title: 'Budget vs Actual',
      icon: Icons.compare_arrows_rounded,
    ),
    _SectionItem(
      title: 'Savings Goal Progress',
      icon: Icons.savings_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
      ),
      body: SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _items.length,
          itemBuilder: (context, index) {
            final item = _items[index];
            return MenuItemTile(
              title: item.title,
              icon: item.icon,
              onTap: () {},
            );
          },
        ),
      ),
    );
  }
}

class _SectionItem {
  final String title;
  final IconData icon;
  const _SectionItem({
    required this.title,
    required this.icon,
  });
}
