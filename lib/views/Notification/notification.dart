// import 'package:flutter/material.dart';

// class NotificationScreen extends StatefulWidget {
//   const NotificationScreen({super.key});

//   @override
//   State<NotificationScreen> createState() => _NotificationScreenState();
// }

// class NotificationItem {
//   final String title;
//   final String subtitle;
//   final DateTime time;
//   final IconData icon;
//   final Color iconBgColor;

//   NotificationItem({
//     required this.title,
//     required this.subtitle,
//     required this.time,
//     required this.icon,
//     required this.iconBgColor,
//   });
// }

// class _NotificationScreenState extends State<NotificationScreen> {
//   List<NotificationItem> notifications = [
//     NotificationItem(
//       title: 'Order Confirmed',
//       subtitle: 'Your order #12345 has been confirmed.',
//       time: DateTime.now().subtract(const Duration(minutes: 10)),
//       icon: Icons.check_circle_outline,
//       iconBgColor: Colors.green.shade100,
//     ),
//     NotificationItem(
//       title: 'New Offer',
//       subtitle: 'Get 20% off on fresh vegetables!',
//       time: DateTime.now().subtract(const Duration(hours: 2)),
//       icon: Icons.local_offer_outlined,
//       iconBgColor: Colors.orange.shade100,
//     ),
//     NotificationItem(
//       title: 'Delivery Update',
//       subtitle: 'Your order is out for delivery.',
//       time: DateTime.now().subtract(const Duration(hours: 5)),
//       icon: Icons.delivery_dining,
//       iconBgColor: Colors.blue.shade100,
//     ),
//   ];

//   String _formatTimeAgo(DateTime time) {
//     final now = DateTime.now();
//     final difference = now.difference(time);

//     if (difference.inSeconds < 60) return 'Just now';
//     if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
//     if (difference.inHours < 24) return '${difference.inHours}h ago';
//     return '${difference.inDays}d ago';
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Notifications'),
//         centerTitle: true,
//         elevation: 0,
//         backgroundColor: Colors.green,
//         actions: [
//           if (notifications.isNotEmpty)
//             IconButton(
//               icon: const Icon(Icons.delete_forever_outlined),
//               tooltip: 'Clear All',
//               onPressed: () {
//                 setState(() {
//                   notifications.clear();
//                 });
//               },
//             ),
//         ],
//       ),
//       body: notifications.isEmpty
//           ? _buildEmptyState()
//           : ListView.separated(
//               padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
//               itemCount: notifications.length,
//               separatorBuilder: (_, __) => const Divider(height: 16),
//               itemBuilder: (context, index) {
//                 final item = notifications[index];
//                 return Dismissible(
//                   key: ValueKey(item.time.toIso8601String()),
//                   direction: DismissDirection.endToStart,
//                   background: Container(
//                     padding: const EdgeInsets.only(right: 20),
//                     alignment: Alignment.centerRight,
//                     color: Colors.red.shade400,
//                     child: const Icon(Icons.delete, color: Colors.white),
//                   ),
//                   onDismissed: (_) {
//                     setState(() {
//                       notifications.removeAt(index);
//                     });
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(content: Text('Notification dismissed')),
//                     );
//                   },
//                   child: ListTile(
//                     leading: CircleAvatar(
//                       backgroundColor: item.iconBgColor,
//                       child: Icon(item.icon, color: Colors.deepOrange),
//                     ),
//                     title: Text(
//                       item.title,
//                       style: const TextStyle(
//                         fontWeight: FontWeight.w600,
//                         fontSize: 16,
//                       ),
//                     ),
//                     subtitle: Text(
//                       item.subtitle,
//                       style: const TextStyle(color: Colors.black87),
//                     ),
//                     trailing: Text(
//                       _formatTimeAgo(item.time),
//                       style: TextStyle(
//                         color: Colors.grey.shade600,
//                         fontSize: 12,
//                       ),
//                     ),
//                     onTap: () {
//                       // Handle notification tap if needed
//                     },
//                   ),
//                 );
//               },
//             ),
//     );
//   }

//   Widget _buildEmptyState() {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 32),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.notifications_off_outlined,
//               size: 100,
//               color: Colors.grey.shade400,
//             ),
//             const SizedBox(height: 20),
//             Text(
//               'No notifications yet',
//               style: TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.w600,
//                 color: Colors.grey.shade600,
//               ),
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 8),
//             Text(
//               'We\'ll notify you when something important happens.',
//               style: TextStyle(
//                 fontSize: 14,
//                 color: Colors.grey.shade500,
//                 height: 1.4,
//               ),
//               textAlign: TextAlign.center,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
