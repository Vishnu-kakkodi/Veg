import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:veegify/helper/storage_helper.dart';

// ─── Model ───────────────────────────────────────────────────────────────────

class NotificationModel {
  final String id;
  final String type;
  final String title;
  final String message;
  final DateTime timestamp;
  bool isRead;
  bool isSelected;

  NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.isRead,
    this.isSelected = false,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    // ✅ FIX: prefer '_id' since that's what the API actually returns
    final id = (json['_id'] ?? json['id'] ?? '').toString().trim();
    return NotificationModel(
      id: id,
      type: json['type'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
      isRead: json['status'] == 'read',
    );
  }
}

// ─── Service ─────────────────────────────────────────────────────────────────

class NotificationService {
  static const String _baseUrl = 'https://api.vegiffyy.com/api';

  static Future<List<NotificationModel>> fetchNotifications(
      String userId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/getnotification/$userId'),
      headers: {'Content-Type': 'application/json'},
    );

    debugPrint('FETCH RESPONSE: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        final List notifications = data['notifications'] ?? [];
        final parsed = notifications
            .map((n) => NotificationModel.fromJson(n))
            .toList();

        // ✅ Debug: print every parsed ID so we can verify
        for (final n in parsed) {
          debugPrint('Parsed notification — id: "${n.id}" title: "${n.title}"');
        }

        return parsed;
      }
    }
    throw Exception('Failed to load notifications (${response.statusCode})');
  }

  /// Pass one or more IDs — always sent as an array.
  static Future<bool> deleteNotifications(
      String userId, List<String> notificationIds) async {
    // ✅ FIX: filter out any empty strings before sending
    final cleanIds =
        notificationIds.where((id) => id.trim().isNotEmpty).toList();

    if (cleanIds.isEmpty) {
      debugPrint('DELETE aborted — no valid IDs to send');
      return false;
    }

    final body = jsonEncode({'notificationIds': cleanIds});
    debugPrint('DELETE REQUEST → userId: $userId, body: $body');

    final response = await http.delete(
      Uri.parse('$_baseUrl/delete-notifications/$userId'),
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    debugPrint('DELETE RESPONSE (${response.statusCode}): ${response.body}');
    return response.statusCode == 200;
  }
}

// ─── Screen ──────────────────────────────────────────────────────────────────

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen>
    with SingleTickerProviderStateMixin {
  String? userId;
  List<NotificationModel> _notifications = [];
  bool _isLoading = true;
  bool _hasError = false;
  bool _isSelectionMode = false;
  bool _isDeletingSelected = false;

  late AnimationController _animController;

  // ── Palette ───────────────────────────────────────────────────────────────
  static const Color _surface = Color(0xFF181A22);
  static const Color _card = Color(0xFF1E2130);
  static const Color _accent = Color(0xFF6C63FF);
  static const Color _accentSoft = Color(0x226C63FF);
  static const Color _textPrimary = Color(0xFFECEDF4);
  static const Color _textSecondary = Color(0xFF8B8FA8);
  static const Color _unreadDot = Color(0xFF6C63FF);
  static const Color _danger = Color(0xFFFF4D6A);
  static const Color _dangerSoft = Color(0x22FF4D6A);
  static const Color _divider = Color(0xFF252836);

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _loadUserId();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _loadUserId() async {
    final user = UserPreferences.getUser();
    if (user != null && mounted) {
      setState(() => userId = user.userId);
      await _fetchNotifications();
    }
  }

  Future<void> _fetchNotifications() async {
    if (userId == null) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final data = await NotificationService.fetchNotifications(userId!);
      if (mounted) {
        setState(() {
          _notifications = data;
          _isLoading = false;
        });
        _animController
          ..reset()
          ..forward();
      }
    } catch (e) {
      debugPrint('Fetch error: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }

  // ── Delete ────────────────────────────────────────────────────────────────

  List<NotificationModel> get _selected =>
      _notifications.where((n) => n.isSelected).toList();

  /// Delete one or many — ids always sent as array
  Future<void> _deleteItems(List<NotificationModel> items) async {
    if (items.isEmpty) return;

    final ids = items.map((n) => n.id).toList();
    debugPrint('Deleting IDs: $ids');

    if (items.length > 1) setState(() => _isDeletingSelected = true);

    final success =
        await NotificationService.deleteNotifications(userId!, ids);

    if (mounted) {
      if (success) {
        final idsSet = ids.toSet();
        setState(() {
          _notifications.removeWhere((n) => idsSet.contains(n.id));
          _isSelectionMode = false;
          _isDeletingSelected = false;
        });
        _showSnack(
          items.length == 1
              ? 'Notification deleted'
              : '${items.length} notifications deleted',
          isError: false,
        );
      } else {
        setState(() => _isDeletingSelected = false);
        _showSnack('Failed to delete. Try again.', isError: true);
      }
    }
  }

  void _showSnack(String msg, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: isError ? _danger : _accent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content:
            Text(msg, style: const TextStyle(color: Colors.white, fontSize: 13)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  IconData _typeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'order':
        return Icons.shopping_bag_rounded;
      case 'promo':
        return Icons.local_offer_rounded;
      case 'alert':
        return Icons.warning_amber_rounded;
      case 'message':
        return Icons.chat_bubble_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  Color _typeColor(String type) {
    switch (type.toLowerCase()) {
      case 'order':
        return const Color(0xFF6C63FF);
      case 'promo':
        return const Color(0xFF00D4AA);
      case 'alert':
        return const Color(0xFFFFB547);
      case 'message':
        return const Color(0xFF3D9EFF);
      default:
        return const Color(0xFF8B8FA8);
    }
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final unreadCount = _notifications.where((n) => !n.isRead).length;

    return Scaffold(
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            _buildHeader(unreadCount),
            Expanded(child: _buildBody()),
            if (_isSelectionMode) _buildSelectionBar(),
          ],
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader(int unreadCount) {
    return Container(
      color: _surface,
      padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).maybePop(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _card,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: _textPrimary, size: 16),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Row(
              children: [
                const Text(
                  'Notifications',
                  style: TextStyle(
                    color: _textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.4,
                  ),
                ),
                if (unreadCount > 0) ...[
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: _accentSoft,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _accent, width: 1),
                    ),
                    child: Text(
                      '$unreadCount',
                      style: const TextStyle(
                        color: _accent,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (!_isLoading && _notifications.isNotEmpty)
            TextButton(
              onPressed: () => setState(() {
                _isSelectionMode = !_isSelectionMode;
                if (!_isSelectionMode) {
                  for (var n in _notifications) {
                    n.isSelected = false;
                  }
                }
              }),
              child: Text(
                _isSelectionMode ? 'Cancel' : 'Select',
                style: TextStyle(
                  color: _isSelectionMode ? _danger : _accent,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          if (!_isSelectionMode)
            GestureDetector(
              onTap: _fetchNotifications,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _card,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.refresh_rounded,
                    color: _textSecondary, size: 18),
              ),
            ),
        ],
      ),
    );
  }

  // ── Body ──────────────────────────────────────────────────────────────────

  Widget _buildBody() {
    if (_isLoading) return _buildLoader();
    if (_hasError) return _buildError();
    if (_notifications.isEmpty) return _buildEmpty();
    return _buildList();
  }

  Widget _buildLoader() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 36,
            height: 36,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: _accent,
              backgroundColor: _accentSoft,
            ),
          ),
          const SizedBox(height: 14),
          const Text('Loading notifications…',
              style: TextStyle(color: _textSecondary, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              color: _dangerSoft,
              shape: BoxShape.circle,
            ),
            child:
                const Icon(Icons.wifi_off_rounded, color: _danger, size: 32),
          ),
          const SizedBox(height: 16),
          const Text('Failed to load',
              style: TextStyle(
                  color: _textPrimary,
                  fontSize: 17,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          const Text('Check your connection and try again',
              style: TextStyle(color: _textSecondary, fontSize: 13)),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _fetchNotifications,
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _accent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              color: _accentSoft,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.notifications_none_rounded,
                color: _accent, size: 38),
          ),
          const SizedBox(height: 16),
          const Text('All caught up!',
              style: TextStyle(
                  color: _textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          const Text('No notifications at the moment',
              style: TextStyle(color: _textSecondary, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildList() {
    return RefreshIndicator(
      color: _accent,
      backgroundColor: _surface,
      onRefresh: _fetchNotifications,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 12),
        itemCount: _notifications.length,
        separatorBuilder: (_, __) =>
            Divider(color: _divider, height: 1, indent: 20, endIndent: 20),
        itemBuilder: (context, i) {
          final n = _notifications[i];
          return AnimatedBuilder(
            animation: _animController,
            builder: (context, child) {
              final delay = (i * 0.08).clamp(0.0, 0.6);
              final t = Curves.easeOutCubic.transform(
                ((_animController.value - delay) / (1 - delay))
                    .clamp(0.0, 1.0),
              );
              return Opacity(
                opacity: t,
                child: Transform.translate(
                  offset: Offset(0, 20 * (1 - t)),
                  child: child,
                ),
              );
            },
            child: _NotificationTile(
              key: ValueKey(n.id), // ✅ Add this key to help Flutter identify the widget
              notification: n,
              isSelectionMode: _isSelectionMode,
              timeAgo: _timeAgo(n.timestamp),
              icon: _typeIcon(n.type),
              iconColor: _typeColor(n.type),
              onTap: () {
                if (_isSelectionMode) {
                  setState(() => n.isSelected = !n.isSelected);
                } else {
                  setState(() => n.isRead = true);
                }
              },
              onLongPress: () {
                setState(() {
                  _isSelectionMode = true;
                  n.isSelected = true;
                });
              },
              // ✅ Fix: Use a callback that doesn't immediately remove the item
              onDelete: () => _handleDismissibleDelete(n),
            ),
          );
        },
      ),
    );
  }

  // ✅ New method to handle Dismissible deletion properly
  Future<void> _handleDismissibleDelete(NotificationModel notification) async {
    // Store the current list of notifications for potential rollback
    final previousNotifications = List<NotificationModel>.from(_notifications);
    
    // Optimistically remove the item from the list
    setState(() {
      _notifications.removeWhere((n) => n.id == notification.id);
    });

    // Attempt to delete from the server
    final success = await NotificationService.deleteNotifications(
        userId!, [notification.id]);

    if (!mounted) return;

    if (success) {
      _showSnack('Notification deleted', isError: false);
    } else {
      // If deletion failed, add the item back
      setState(() {
        _notifications = previousNotifications;
      });
      _showSnack('Failed to delete. Try again.', isError: true);
    }
  }

  // ── Selection bottom bar ──────────────────────────────────────────────────

  Widget _buildSelectionBar() {
    final count = _selected.length;
    return Container(
      color: _surface,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => setState(() {
              final allSelected = _notifications.every((n) => n.isSelected);
              for (var n in _notifications) {
                n.isSelected = !allSelected;
              }
            }),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: _notifications.every((n) => n.isSelected)
                        ? _accent
                        : Colors.transparent,
                    border: Border.all(
                      color: _notifications.every((n) => n.isSelected)
                          ? _accent
                          : _textSecondary,
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: _notifications.every((n) => n.isSelected)
                      ? const Icon(Icons.check_rounded,
                          color: Colors.white, size: 14)
                      : null,
                ),
                const SizedBox(width: 8),
                const Text('All',
                    style: TextStyle(color: _textSecondary, fontSize: 13)),
              ],
            ),
          ),
          const Spacer(),
          Text(
            count == 0
                ? 'Select items'
                : '$count item${count == 1 ? '' : 's'} selected',
            style: const TextStyle(color: _textSecondary, fontSize: 13),
          ),
          const SizedBox(width: 16),
          AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: count > 0 ? 1 : 0.4,
            child: ElevatedButton.icon(
              // ✅ bulk delete — passes all selected as array
              onPressed: count > 0 && !_isDeletingSelected
                  ? () => _deleteItems(_selected)
                  : null,
              icon: _isDeletingSelected
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.delete_outline_rounded, size: 16),
              label: Text(_isDeletingSelected ? 'Deleting…' : 'Delete'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _danger,
                foregroundColor: Colors.white,
                disabledBackgroundColor: _danger.withOpacity(0.5),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(
                    horizontal: 18, vertical: 11),
                textStyle: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Tile widget ──────────────────────────────────────────────────────────────

class _NotificationTile extends StatelessWidget {
  final NotificationModel notification;
  final bool isSelectionMode;
  final String timeAgo;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onDelete;

  static const Color _card = Color(0xFF1E2130);
  static const Color _accent = Color(0xFF6C63FF);
  static const Color _textPrimary = Color(0xFFECEDF4);
  static const Color _textSecondary = Color(0xFF8B8FA8);
  static const Color _unreadDot = Color(0xFF6C63FF);
  static const Color _danger = Color(0xFFFF4D6A);

  const _NotificationTile({
    super.key, // ✅ Allow key to be passed from parent
    required this.notification,
    required this.isSelectionMode,
    required this.timeAgo,
    required this.icon,
    required this.iconColor,
    required this.onTap,
    required this.onLongPress,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final n = notification;
    return Dismissible(
      key: Key(n.id), // Use the notification ID as the key
      direction: isSelectionMode
          ? DismissDirection.none
          : DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        color: _danger.withOpacity(0.15),
        child: const Icon(Icons.delete_outline_rounded, color: _danger),
      ),
      // ✅ Important: Set confirmDismiss to handle the dismissal
      confirmDismiss: (direction) async {
        if (isSelectionMode) return false;
        return true; // Allow dismissal
      },
      onDismissed: (direction) {
        // Call the delete callback
        onDelete();
      },
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        splashColor: _accent.withOpacity(0.06),
        highlightColor: _accent.withOpacity(0.04),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          color: n.isSelected
              ? _accent.withOpacity(0.08)
              : n.isRead
                  ? Colors.transparent
                  : iconColor.withOpacity(0.04),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isSelectionMode)
                Padding(
                  padding: const EdgeInsets.only(top: 2, right: 14),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: n.isSelected ? _accent : Colors.transparent,
                      border: Border.all(
                        color: n.isSelected ? _accent : _textSecondary,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: n.isSelected
                        ? const Icon(Icons.check_rounded,
                            color: Colors.white, size: 14)
                        : null,
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.only(right: 14),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: iconColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(icon, color: iconColor, size: 20),
                  ),
                ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            n.title,
                            style: TextStyle(
                              color: const Color.fromARGB(255, 0, 0, 0),
                              fontSize: 14,
                              fontWeight: n.isRead
                                  ? FontWeight.w500
                                  : FontWeight.w700,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          timeAgo,
                          style: const TextStyle(
                              color: _textSecondary, fontSize: 11),
                        ),
                        if (!n.isRead) ...[
                          const SizedBox(width: 8),
                          Container(
                            width: 7,
                            height: 7,
                            decoration: const BoxDecoration(
                              color: _unreadDot,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      n.message,
                      style: const TextStyle(
                        color: _textSecondary,
                        fontSize: 13,
                        height: 1.45,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: iconColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        n.type,
                        style: TextStyle(
                          color: iconColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}