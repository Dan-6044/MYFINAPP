import 'package:flutter/material.dart';
import '../../features/dashboard/models/myfin_module.dart';

class MyfinModuleTile extends StatelessWidget {
  final MyfinModule module;
  final VoidCallback onTap;

  const MyfinModuleTile({
    super.key,
    required this.module,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7EF),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              module.icon,
              color: theme.colorScheme.primary,
              size: 32,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            module.title,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: const Color(0xFF3D2C2C),
            ),
          ),
        ],
      ),
    );
  }
}
