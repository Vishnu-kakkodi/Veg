// lib/screens/notification_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:veegify/helper/storage_helper.dart';
import 'package:veegify/provider/NotificationProvider/notification_provider.dart';


class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() =>
      _NotificationScreenState();
}

class _NotificationScreenState
    extends State<NotificationScreen> {
  String? userId;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final user = UserPreferences.getUser();
    if (user != null) {
      userId = user.userId;
      Future.microtask(() =>
          context.read<NotificationProvider>()
              .fetchNotifications(userId!));
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotificationProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (provider.notifications.isNotEmpty)
            TextButton(
              onPressed: provider.toggleSelectionMode,
              child: Text(
                  provider.isSelectionMode
                      ? 'Cancel'
                      : 'Select'),
            ),
        ],
      ),
      body: _buildBody(provider),
      bottomNavigationBar:
          provider.isSelectionMode
              ? _buildBottomBar(provider)
              : null,
    );
  }

  Widget _buildBody(NotificationProvider provider) {
    if (provider.isLoading) {
      return const Center(
          child: CircularProgressIndicator());
    }

    if (provider.hasError) {
      return const Center(
          child: Text('Failed to load'));
    }

    if (provider.notifications.isEmpty) {
      return const Center(
          child: Text('No notifications'));
    }

    return RefreshIndicator(
      onRefresh: () =>
          provider.fetchNotifications(userId!),
      child: ListView.builder(
        itemCount: provider.notifications.length,
        itemBuilder: (_, i) {
          final n = provider.notifications[i];

          return Dismissible(
            key: Key(n.id),
            direction: provider.isSelectionMode
                ? DismissDirection.none
                : DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding:
                  const EdgeInsets.only(right: 20),
              color: Colors.red.withOpacity(0.2),
              child: const Icon(Icons.delete,
                  color: Colors.red),
            ),
            onDismissed: (_) {
              provider.deleteSingle(userId!, n);
            },
            child: ListTile(
              leading: provider.isSelectionMode
                  ? Checkbox(
                      value: n.isSelected,
                      onChanged: (_) =>
                          provider.toggleItemSelection(n),
                    )
                  : const Icon(Icons.notifications),
              title: Text(
                n.title,
                style: TextStyle(
                  fontWeight: n.isRead
                      ? FontWeight.normal
                      : FontWeight.bold,
                ),
              ),
              subtitle: Text(n.message),
              onTap: () {
                if (provider.isSelectionMode) {
                  provider.toggleItemSelection(n);
                } else {
                  provider.markAsRead(n);
                }
              },
              onLongPress: () {
                provider.toggleSelectionMode();
                provider.toggleItemSelection(n);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildBottomBar(NotificationProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ElevatedButton(
        onPressed: provider.selected.isEmpty ||
                provider.isDeleting
            ? null
            : () =>
                provider.deleteSelected(userId!),
        child: provider.isDeleting
            ? const CircularProgressIndicator(
                color: Colors.white)
            : const Text('Delete Selected'),
      ),
    );
  }
}