import 'package:flutter/material.dart';

class MenuItemTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const MenuItemTile({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xFFF0E6DC), width: 1)),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: const Color(0xFFF4793A),
              size: 22,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF3D2C2C),
                    ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: const Color(0xFFF4793A),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
