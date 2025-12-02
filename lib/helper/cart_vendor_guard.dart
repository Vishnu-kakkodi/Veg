import 'package:flutter/material.dart';
import 'package:veegify/provider/CartProvider/cart_provider.dart';

/// Professional ticket-style modal for vendor change confirmation
Future<bool> addToCartWithVendorGuard({
  required BuildContext context,
  required CartProvider cartProvider,
  required String restaurantIdOfProduct,
  required String restaurantProductId,
  required String recommendedId,
  required int quantity,
  required String variation,
  required int plateItems,
  required String userId,
}) async {
  cartProvider.setUserId(userId);

  final existingVendorId = cartProvider.restaurantId;
  final hasItems = cartProvider.hasItems;

  if (hasItems &&
      existingVendorId.isNotEmpty &&
      existingVendorId != restaurantIdOfProduct) {
    final shouldReplace = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => const VendorChangeTicketModal(),
        ) ??
        false;

    if (!shouldReplace) {
      return false;
    }

    final cleared = await cartProvider.clearCart();
    if (!cleared) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to clear existing cart. Please try again.'),
        ),
      );
      return false;
    }
  }

  final added = await cartProvider.addItemToCart(
    restaurantProductId: restaurantProductId,
    recommendedId: recommendedId,
    quantity: quantity,
    variation: variation,
    plateItems: plateItems,
    userId: userId,
  );

  return added;
}

/// Professional ticket-style modal widget
class VendorChangeTicketModal extends StatelessWidget {
  const VendorChangeTicketModal({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 380),
        child: Stack(
          children: [
            // Main ticket body
            Container(
              margin: const EdgeInsets.only(top: 40),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Ticket notches at top
                  _buildTicketNotches(isTop: true),
                  
                  const SizedBox(height: 32),

                  // Icon header
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.shopping_cart_outlined,
                      size: 48,
                      color: Colors.orange.shade700,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Title
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      'Replace Cart Items?',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade900,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Description
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      'Your cart contains items from another restaurant. Adding this item will clear your current cart.',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey.shade600,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Dashed divider
                  _buildDashedDivider(),

                  const SizedBox(height: 24),

                  // Action buttons
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      children: [
                        // Cancel button
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              side: BorderSide(
                                color: Colors.grey.shade300,
                                width: 1.5,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Keep Current',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 12),

                        // Confirm button
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: Colors.orange.shade600,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Replace Cart',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Ticket notches at bottom
                  _buildTicketNotches(isTop: false),
                ],
              ),
            ),

            // Close button (floating)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: IconButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  icon: Icon(
                    Icons.close,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build ticket-style notches (perforated edge effect)
  Widget _buildTicketNotches({required bool isTop}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(
        20,
        (index) => Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }

  /// Build dashed divider line
  Widget _buildDashedDivider() {
    return Row(
      children: List.generate(
        30,
        (index) => Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 2),
            height: 1,
            color: Colors.grey.shade300,
          ),
        ),
      ),
    );
  }
}