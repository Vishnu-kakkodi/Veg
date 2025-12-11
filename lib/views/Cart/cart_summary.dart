// import 'package:flutter/material.dart';
// import 'package:veegify/provider/CartProvider/cart_provider.dart';

// /// Expandable ticket-style pricing summary widget
// class TicketPricingSummary extends StatefulWidget {
//   final CartProvider cartProvider;
//   final ThemeData theme;
//   final ColorScheme colorScheme;

//   const TicketPricingSummary({
//     Key? key,
//     required this.cartProvider,
//     required this.theme,
//     required this.colorScheme,
//   }) : super(key: key);

//   @override
//   State<TicketPricingSummary> createState() => _TicketPricingSummaryState();
// }

// class _TicketPricingSummaryState extends State<TicketPricingSummary>
//     with SingleTickerProviderStateMixin {
//   bool _isExpanded = false;
//   late AnimationController _animationController;
//   late Animation<double> _expandAnimation;

//   bool get _isDark => widget.theme.brightness == Brightness.dark;

//   @override
//   void initState() {
//     super.initState();
//     _animationController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 300),
//     );
//     _expandAnimation = CurvedAnimation(
//       parent: _animationController,
//       curve: Curves.easeInOut,
//     );
//   }

//   @override
//   void dispose() {
//     _animationController.dispose();
//     super.dispose();
//   }

//   void _toggleExpanded() {
//     setState(() {
//       _isExpanded = !_isExpanded;
//       if (_isExpanded) {
//         _animationController.forward();
//       } else {
//         _animationController.reverse();
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = widget.theme;
//     final colorScheme = widget.colorScheme;

//     return Container(
//       decoration: BoxDecoration(
//         color: _isDark ? colorScheme.surface : Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: _isDark
//                 ? Colors.black.withOpacity(0.4)
//                 : Colors.black.withOpacity(0.08),
//             blurRadius: _isDark ? 26 : 20,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         children: [
//           // Top perforated edge
//           _buildTicketEdge(isTop: true),

//           // Main collapsed view - Total Payable
//           InkWell(
//             onTap: _toggleExpanded,
//             borderRadius: BorderRadius.circular(16),
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
//               child: Row(
//                 children: [
//                   // Receipt icon
//                   Container(
//                     padding: const EdgeInsets.all(10),
//                     decoration: BoxDecoration(
//                       color: colorScheme.primary.withOpacity(_isDark ? 0.2 : 0.1),
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     child: Icon(
//                       Icons.receipt_long,
//                       color: colorScheme.primary,
//                       size: 24,
//                     ),
//                   ),

//                   const SizedBox(width: 16),

//                   // Label and amount
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'To Pay',
//                           style: theme.textTheme.bodyMedium?.copyWith(
//                             color:
//                                 colorScheme.onSurface.withOpacity(0.6),
//                             fontSize: 13,
//                           ),
//                         ),
//                         const SizedBox(height: 2),
//                         Text(
//                           '₹${widget.cartProvider.totalPayable.toStringAsFixed(2)}',
//                           style: theme.textTheme.titleLarge?.copyWith(
//                             color: colorScheme.primary,
//                             fontWeight: FontWeight.bold,
//                             fontSize: 24,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),

//                   // Expand/collapse icon with rotation animation
//                   AnimatedRotation(
//                     turns: _isExpanded ? 0.5 : 0,
//                     duration: const Duration(milliseconds: 300),
//                     child: Container(
//                       padding: const EdgeInsets.all(8),
//                       decoration: BoxDecoration(
//                         color: colorScheme.surfaceVariant
//                             .withOpacity(_isDark ? 0.4 : 1),
//                         shape: BoxShape.circle,
//                       ),
//                       child: Icon(
//                         Icons.keyboard_arrow_down,
//                         color: colorScheme.onSurface,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),

//           // Expandable details section
//           SizeTransition(
//             sizeFactor: _expandAnimation,
//             axisAlignment: -1,
//             child: Column(
//               children: [
//                 // Dashed divider
//                 _buildDashedDivider(),

//                 // Detailed breakdown
//                 Padding(
//                   padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
//                   child: Column(
//                     children: [
//                       _buildDetailRow(
//                         icon: Icons.shopping_bag_outlined,
//                         label: 'Total Items',
//                         value: widget.cartProvider.totalItems
//                             .toString()
//                             .padLeft(2, '0'),
//                         showCurrency: false,
//                       ),
//                       const SizedBox(height: 12),
//                       _buildDetailRow(
//                         icon: Icons.receipt,
//                         label: 'Sub Total',
//                         value:
//                             widget.cartProvider.subtotal.toStringAsFixed(2),
//                       ),
//                       if (widget.cartProvider.couponDiscount > 0) ...[
//                         const SizedBox(height: 12),
//                         _buildDetailRow(
//                           icon: Icons.discount,
//                           label: 'Coupon Discount',
//                           value: widget.cartProvider.couponDiscount
//                               .toStringAsFixed(2),
//                           valueColor: Colors.green,
//                           isNegative: true,
//                         ),
//                       ],
//                       const SizedBox(height: 12),
//                       _buildDetailRow(
//                         icon: Icons.delivery_dining,
//                         label: 'Delivery Charge',
//                         value: widget.cartProvider.deliveryCharge
//                             .toStringAsFixed(2),
//                       ),
//                       const SizedBox(height: 12),
//                       _buildDetailRow(
//                         icon: Icons.smartphone,
//                         label: 'Platform Charge',
//                         value: widget.cartProvider.platformCharge
//                             .toStringAsFixed(2),
//                       ),
//                       const SizedBox(height: 12),
//                       _buildDetailRow(
//                         icon: Icons.account_balance,
//                         label: 'GST',
//                         value: widget.cartProvider.gstAmount
//                             .toStringAsFixed(2),
//                       ),
//                                             const SizedBox(height: 12),

//                                            _buildDetailRow(
//                         icon: Icons.account_balance,
//                         label: 'Delivery Gst',
//                         value: widget.cartProvider.gstOnDelivery.toStringAsFixed(2),
//                       ),

//                                                                   const SizedBox(height: 12),

//                                            _buildDetailRow(
//                         icon: Icons.account_balance,
//                         label: 'Packing Charge',
//                         value: widget.cartProvider.packingCharges.toStringAsFixed(2),
//                       ),
//                     ],
//                   ),
//                 ),

//                 // Final total with highlight
//                 Padding(
//                   padding: const EdgeInsets.all(20),
//                   child: Container(
//                     padding: const EdgeInsets.all(16),
//                     decoration: BoxDecoration(
//                       color: colorScheme.primary.withOpacity(_isDark ? 0.15 : 0.1),
//                       borderRadius: BorderRadius.circular(12),
//                       border: Border.all(
//                         color: colorScheme.primary
//                             .withOpacity(_isDark ? 0.5 : 0.3),
//                         width: 1,
//                       ),
//                     ),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Row(
//                           children: [
//                             Icon(
//                               Icons.payments,
//                               color: colorScheme.primary,
//                               size: 20,
//                             ),
//                             const SizedBox(width: 8),
//                             Text(
//                               'Total Payable',
//                               style: theme.textTheme.titleMedium?.copyWith(
//                                 fontWeight: FontWeight.bold,
//                                 color: colorScheme.onSurface,
//                               ),
//                             ),
//                           ],
//                         ),
//                         Text(
//                           '₹${widget.cartProvider.totalPayable.toStringAsFixed(2)}',
//                           style: theme.textTheme.titleMedium?.copyWith(
//                             fontWeight: FontWeight.bold,
//                             color: colorScheme.primary,
//                             fontSize: 18,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           // Bottom perforated edge
//           _buildTicketEdge(isTop: false),
//         ],
//       ),
//     );
//   }

//   /// Build detail row with icon
//   Widget _buildDetailRow({
//     required IconData icon,
//     required String label,
//     required String value,
//     Color? valueColor,
//     bool isNegative = false,
//     bool showCurrency = true,
//   }) {
//     final theme = widget.theme;
//     final colorScheme = widget.colorScheme;

//     return Row(
//       children: [
//         // Icon
//         Container(
//           padding: const EdgeInsets.all(6),
//           decoration: BoxDecoration(
//             color: colorScheme.surfaceVariant
//                 .withOpacity(_isDark ? 0.6 : 1),
//             borderRadius: BorderRadius.circular(8),
//           ),
//           child: Icon(
//             icon,
//             size: 16,
//             color: colorScheme.onSurface.withOpacity(0.6),
//           ),
//         ),

//         const SizedBox(width: 12),

//         // Label
//         Expanded(
//           child: Text(
//             label,
//             style: theme.textTheme.bodyMedium?.copyWith(
//               color: colorScheme.onSurface.withOpacity(0.7),
//             ),
//           ),
//         ),

//         // Value
//         Text(
//           '${isNegative ? '-' : ''}${showCurrency ? '₹' : ''}$value',
//           style: theme.textTheme.bodyMedium?.copyWith(
//             color: valueColor ?? colorScheme.onSurface,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//       ],
//     );
//   }

//   /// Build ticket perforated edge
//   Widget _buildTicketEdge({required bool isTop}) {
//     final colorScheme = widget.colorScheme;
//     final baseColor =
//         colorScheme.surfaceVariant.withOpacity(_isDark ? 0.5 : 0.3);

//     return Row(
//       children: List.generate(
//         40,
//         (index) {
//           if (index == 0 || index == 39) {
//             return Expanded(
//               child: Container(
//                 height: 8,
//                 decoration: BoxDecoration(
//                   color: baseColor,
//                   borderRadius: isTop
//                       ? (index == 0
//                           ? const BorderRadius.only(
//                               topLeft: Radius.circular(16),
//                             )
//                           : const BorderRadius.only(
//                               topRight: Radius.circular(16),
//                             ))
//                       : (index == 0
//                           ? const BorderRadius.only(
//                               bottomLeft: Radius.circular(16),
//                             )
//                           : const BorderRadius.only(
//                               bottomRight: Radius.circular(16),
//                             )),
//                 ),
//               ),
//             );
//           }
//           return Expanded(
//             child: Container(
//               margin: const EdgeInsets.symmetric(horizontal: 1),
//               height: 8,
//               decoration: BoxDecoration(
//                 color: baseColor,
//                 borderRadius: BorderRadius.circular(2),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }

//   /// Build dashed divider
//   Widget _buildDashedDivider() {
//     final colorScheme = widget.colorScheme;

//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 20),
//       child: Row(
//         children: List.generate(
//           40,
//           (index) => Expanded(
//             child: Container(
//               margin: const EdgeInsets.symmetric(horizontal: 2),
//               height: 1,
//               color: colorScheme.outline.withOpacity(_isDark ? 0.35 : 0.2),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// Usage example:
// TicketPricingSummary(
//   cartProvider: cartProvider,
//   theme: theme,
//   colorScheme: theme.colorScheme,
// )












import 'package:flutter/material.dart';
import 'package:veegify/provider/CartProvider/cart_provider.dart';
import 'package:veegify/utils/responsive.dart'; // ✅ add this

/// Expandable ticket-style pricing summary widget
class TicketPricingSummary extends StatefulWidget {
  final CartProvider cartProvider;
  final ThemeData theme;
  final ColorScheme colorScheme;

  const TicketPricingSummary({
    Key? key,
    required this.cartProvider,
    required this.theme,
    required this.colorScheme,
  }) : super(key: key);

  @override
  State<TicketPricingSummary> createState() => _TicketPricingSummaryState();
}

class _TicketPricingSummaryState extends State<TicketPricingSummary>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

  bool get _isDark => widget.theme.brightness == Brightness.dark;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    final colorScheme = widget.colorScheme;

    final isMobile = Responsive.isMobile(context);
    final isTablet = Responsive.isTablet(context);
    final isDesktop = Responsive.isDesktop(context);

    // Keep ticket narrow on big screens
    final double maxWidth =
        isDesktop ? 420 : (isTablet ? 380 : double.infinity);

    // Slightly adjust paddings
    final double horizontalPadding = isMobile ? 16 : 20;
    final double topBottomPadding = isMobile ? 14 : 16;

    final double mainAmountFontSize = isDesktop ? 26 : 24;
    final double totalPayableFontSize = isDesktop ? 20 : 18;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Container(
          decoration: BoxDecoration(
            color: _isDark ? colorScheme.surface : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: _isDark
                    ? Colors.black.withOpacity(0.4)
                    : Colors.black.withOpacity(0.08),
                blurRadius: _isDark ? 26 : 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Top perforated edge
              _buildTicketEdge(isTop: true),

              // Main collapsed view - Total Payable
              InkWell(
                onTap: _toggleExpanded,
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: topBottomPadding,
                  ),
                  child: Row(
                    children: [
                      // Receipt icon
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: colorScheme.primary
                              .withOpacity(_isDark ? 0.2 : 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.receipt_long,
                          color: colorScheme.primary,
                          size: 24,
                        ),
                      ),

                      const SizedBox(width: 16),

                      // Label and amount
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'To Pay',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurface.withOpacity(0.6),
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '₹${widget.cartProvider.totalPayable.toStringAsFixed(2)}',
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: mainAmountFontSize,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Expand/collapse icon with rotation animation
                      AnimatedRotation(
                        turns: _isExpanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 300),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceVariant
                                .withOpacity(_isDark ? 0.4 : 1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.keyboard_arrow_down,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Expandable details section
              SizeTransition(
                sizeFactor: _expandAnimation,
                axisAlignment: -1,
                child: Column(
                  children: [
                    // Dashed divider
                    _buildDashedDivider(),

                    // Detailed breakdown
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                      child: Column(
                        children: [
                          _buildDetailRow(
                            icon: Icons.shopping_bag_outlined,
                            label: 'Total Items',
                            value: widget.cartProvider.totalItems
                                .toString()
                                .padLeft(2, '0'),
                            showCurrency: false,
                          ),
                          const SizedBox(height: 12),
                          _buildDetailRow(
                            icon: Icons.receipt,
                            label: 'Sub Total',
                            value: widget.cartProvider.subtotal
                                .toStringAsFixed(2),
                          ),
                          if (widget.cartProvider.couponDiscount > 0) ...[
                            const SizedBox(height: 12),
                            _buildDetailRow(
                              icon: Icons.discount,
                              label: 'Coupon Discount',
                              value: widget.cartProvider.couponDiscount
                                  .toStringAsFixed(2),
                              valueColor: Colors.green,
                              isNegative: true,
                            ),
                          ],
                          const SizedBox(height: 12),
                          _buildDetailRow(
                            icon: Icons.delivery_dining,
                            label: 'Delivery Charge',
                            value: widget.cartProvider.deliveryCharge
                                .toStringAsFixed(2),
                          ),
                          const SizedBox(height: 12),
                          _buildDetailRow(
                            icon: Icons.smartphone,
                            label: 'Platform Charge',
                            value: widget.cartProvider.platformCharge
                                .toStringAsFixed(2),
                          ),
                          const SizedBox(height: 12),
                          _buildDetailRow(
                            icon: Icons.account_balance,
                            label: 'GST',
                            value: widget.cartProvider.gstAmount
                                .toStringAsFixed(2),
                          ),
                          const SizedBox(height: 12),
                          _buildDetailRow(
                            icon: Icons.account_balance,
                            label: 'Delivery GST',
                            value: widget.cartProvider.gstOnDelivery
                                .toStringAsFixed(2),
                          ),
                          const SizedBox(height: 12),
                          _buildDetailRow(
                            icon: Icons.account_balance_wallet_outlined,
                            label: 'Packing Charge',
                            value: widget.cartProvider.packingCharges
                                .toStringAsFixed(2),
                          ),
                        ],
                      ),
                    ),

                    // Final total with highlight
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: colorScheme.primary
                              .withOpacity(_isDark ? 0.15 : 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: colorScheme.primary
                                .withOpacity(_isDark ? 0.5 : 0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.payments,
                                  color: colorScheme.primary,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Total Payable',
                                  style:
                                      theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              '₹${widget.cartProvider.totalPayable.toStringAsFixed(2)}',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.primary,
                                fontSize: totalPayableFontSize,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Bottom perforated edge
              _buildTicketEdge(isTop: false),
            ],
          ),
        ),
      ),
    );
  }

  /// Build detail row with icon
  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
    bool isNegative = false,
    bool showCurrency = true,
  }) {
    final theme = widget.theme;
    final colorScheme = widget.colorScheme;

    return Row(
      children: [
        // Icon
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: colorScheme.surfaceVariant
                .withOpacity(_isDark ? 0.6 : 1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 16,
            color: colorScheme.onSurface.withOpacity(0.6),
          ),
        ),

        const SizedBox(width: 12),

        // Label
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ),

        // Value
        Text(
          '${isNegative ? '-' : ''}${showCurrency ? '₹' : ''}$value',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: valueColor ?? colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  /// Build ticket perforated edge
  Widget _buildTicketEdge({required bool isTop}) {
    final colorScheme = widget.colorScheme;
    final baseColor =
        colorScheme.surfaceVariant.withOpacity(_isDark ? 0.5 : 0.3);

    return Row(
      children: List.generate(
        40,
        (index) {
          if (index == 0 || index == 39) {
            return Expanded(
              child: Container(
                height: 8,
                decoration: BoxDecoration(
                  color: baseColor,
                  borderRadius: isTop
                      ? (index == 0
                          ? const BorderRadius.only(
                              topLeft: Radius.circular(16),
                            )
                          : const BorderRadius.only(
                              topRight: Radius.circular(16),
                            ))
                      : (index == 0
                          ? const BorderRadius.only(
                              bottomLeft: Radius.circular(16),
                            )
                          : const BorderRadius.only(
                              bottomRight: Radius.circular(16),
                            )),
                ),
              ),
            );
          }
          return Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 1),
              height: 8,
              decoration: BoxDecoration(
                color: baseColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Build dashed divider
  Widget _buildDashedDivider() {
    final colorScheme = widget.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: List.generate(
          40,
          (index) => Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              height: 1,
              color: colorScheme.outline.withOpacity(
                _isDark ? 0.35 : 0.2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
