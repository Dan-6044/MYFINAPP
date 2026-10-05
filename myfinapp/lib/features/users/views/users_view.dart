import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/user_controller.dart';
import '../models/user.dart';
import './user_form_page.dart';

class UsersView extends GetView<UserController> {
  const UsersView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value && controller.users.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      final error = controller.errorMessage.value;
      if (error != null && error.isNotEmpty && controller.users.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.wifi_off_rounded, size: 40, color: Color(0xFFD6C8C0)),
                const SizedBox(height: 12),
                Text(
                  'Unable to load users',
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
                  onPressed: controller.loadUsers,
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        );
      }

      if (controller.users.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.people_rounded, size: 40, color: Color(0xFFD6C8C0)),
                const SizedBox(height: 12),
                Text(
                  'No Users',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF3D2C2C),
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  'No users have been created yet.',
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
        onRefresh: controller.loadUsers,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.users.length,
          itemBuilder: (context, index) {
            final user = controller.users[index];

            return _UserListItem(
              user: user,
            );
          },
        ),
      );
    });
  }
}

class _UserListItem extends StatelessWidget {
  const _UserListItem({
    required this.user,
  });

  final User user;

  Future<void> _handleActivateDeactivate(BuildContext context, bool newStatus) async {
    if (newStatus == (user.status == 'A')) return;
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
                newStatus ? 'Activate User' : 'Deactivate User',
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
              user.username,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF3D2C2C),
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              newStatus
                  ? 'Are you sure you want to activate this user?'
                  : 'Are you sure you want to deactivate this user?',
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
      final userController = Get.find<UserController>();
      await userController.setActiveStatus(user.userID, newStatus);
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
    final isActive = user.status == 'A';
    final trailing = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFFFFF7EF) : const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isActive ? const Color(0xFFF4793A) : const Color(0xFFBDBDBD),
              width: 1,
            ),
          ),
          child: Text(
            isActive ? 'Active' : 'Inactive',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: isActive ? const Color(0xFFF4793A) : const Color(0xFF757575),
              letterSpacing: 0.4,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Switch(
          value: isActive,
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
                  () => UserFormPage(user: user),
                );
                if (result == true && context.mounted) {
                  final userController = Get.find<UserController>();
                  await userController.loadUsers();
                  Get.snackbar(
                    'Success',
                    'User updated successfully.',
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
                    user.username,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF3D2C2C),
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${user.firstName} ${user.middleName ?? ''} ${user.lastName ?? ''}'.trim(),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: const Color(0xFF8C7B7B),
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${user.email ?? '-'} ${user.phoneNumber != null ? '• ${user.phoneNumber}' : ''}'.trim(),
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
