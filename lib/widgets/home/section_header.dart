// import 'package:flutter/material.dart';

// class SectionHeader extends StatelessWidget {
//   final String title;
//   final VoidCallback onSeeAll;

//   const SectionHeader({
//     super.key,
//     required this.title,
//     required this.onSeeAll,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
    
//     return Row(
//       children: [
//         Text(
//           title,
//           style: theme.textTheme.titleMedium?.copyWith(
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         const Spacer(),
//         TextButton(
//           onPressed: onSeeAll,
//           style: TextButton.styleFrom(
//             foregroundColor: theme.colorScheme.primary,
//           ),
//           child: Row(
//             children: [
//               Text(
//                 'See All',
//                 style: theme.textTheme.bodyMedium?.copyWith(
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//               const SizedBox(width: 4),
//               Icon(
//                 Icons.arrow_forward_ios,
//                 size: 12,
//                 color: theme.colorScheme.primary,
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }


















import 'package:flutter/material.dart';
import 'package:veegify/utils/responsive.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onSeeAll;

  const SectionHeader({
    super.key,
    required this.title,
    required this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final double titleFontSize = Responsive.isMobile(context)
        ? 16
        : Responsive.isTablet(context)
            ? 18
            : 20;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: titleFontSize,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          TextButton(
            onPressed: onSeeAll,
            style: TextButton.styleFrom(
              foregroundColor: theme.colorScheme.primary,
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
            child: Row(
              children: [
                Text(
                  'See All',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.arrow_forward_ios,
                  size: Responsive.isMobile(context) ? 12 : 14,
                  color: theme.colorScheme.primary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
