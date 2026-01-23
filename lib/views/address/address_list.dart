

// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:veegify/model/address_model.dart';
// import 'package:veegify/provider/address_provider.dart';
// import 'package:veegify/views/address/add_address.dart';


// class AddressList extends StatefulWidget {
//   const AddressList({super.key});

//   @override
//   State<AddressList> createState() => _AddressListState();
// }

// class _AddressListState extends State<AddressList> {
//   @override
//   void initState() {
//     super.initState();
//     // Load addresses when the screen initializes
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       context.read<AddressProvider>().loadAddresses();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final colorScheme = theme.colorScheme;

//     return Scaffold(
//       backgroundColor: theme.scaffoldBackgroundColor,
//       appBar: AppBar(
//         backgroundColor: theme.cardColor,
//         surfaceTintColor: theme.cardColor,
//         elevation: 1,
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back, color: colorScheme.onBackground),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: Text(
//           'Addresses',
//           style: theme.textTheme.titleLarge?.copyWith(
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         centerTitle: true,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             // Add Address Button
//             SizedBox(
//               width: double.infinity,
//               height: 50,
//               child: ElevatedButton(
//                 onPressed: () async {
//                   final result = await Navigator.push(
//                     context, 
//                     MaterialPageRoute(builder: (context) => const AddAddress())
//                   );
                  
//                   // Refresh the list if an address was added
//                   if (result == true) {
//                     context.read<AddressProvider>().refreshAddresses();
//                   }
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: colorScheme.primary,
//                   foregroundColor: colorScheme.onPrimary,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   elevation: 0,
//                 ),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(
//                       Icons.add,
//                       color: colorScheme.onPrimary,
//                       size: 20,
//                     ),
//                     const SizedBox(width: 8),
//                     Text(
//                       'Add address',
//                       style: theme.textTheme.titleMedium?.copyWith(
//                         color: colorScheme.onPrimary,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             const SizedBox(height: 20),
//             // Address List
//             Expanded(
//               child: Consumer<AddressProvider>(
//                 builder: (context, addressProvider, child) {
//                   if (addressProvider.isLoading) {
//                     return Center(
//                       child: CircularProgressIndicator(
//                         color: colorScheme.primary,
//                       ),
//                     );
//                   }

//                   if (addressProvider.errorMessage.isNotEmpty) {
//                     return Center(
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Icon(
//                             Icons.error_outline_rounded,
//                             size: 48,
//                             color: colorScheme.error,
//                           ),
//                           const SizedBox(height: 16),
//                           Text(
//                             addressProvider.errorMessage,
//                             textAlign: TextAlign.center,
//                             style: theme.textTheme.bodyMedium?.copyWith(
//                               color: colorScheme.error,
//                             ),
//                           ),
//                           const SizedBox(height: 16),
//                           ElevatedButton(
//                             onPressed: () {
//                               addressProvider.refreshAddresses();
//                             },
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: colorScheme.primary,
//                               foregroundColor: colorScheme.onPrimary,
//                             ),
//                             child: const Text('Retry'),
//                           ),
//                         ],
//                       ),
//                     );
//                   }

//                   if (addressProvider.addresses.isEmpty) {
//                     return Center(
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Icon(
//                             Icons.location_off_outlined,
//                             size: 48,
//                             color: colorScheme.onSurface.withOpacity(0.5),
//                           ),
//                           const SizedBox(height: 16),
//                           Text(
//                             'No addresses found',
//                             style: theme.textTheme.titleMedium?.copyWith(
//                               color: colorScheme.onSurface.withOpacity(0.7),
//                             ),
//                           ),
//                           const SizedBox(height: 8),
//                           Text(
//                             'Add your first address to get started',
//                             style: theme.textTheme.bodyMedium?.copyWith(
//                               color: colorScheme.onSurface.withOpacity(0.5),
//                             ),
//                           ),
//                         ],
//                       ),
//                     );
//                   }

//                   return ListView.separated(
//                     itemCount: addressProvider.addresses.length,
//                     separatorBuilder: (context, index) => const SizedBox(height: 12),
//                     itemBuilder: (context, index) {
//                       final address = addressProvider.addresses[index];
//                       return _buildAddressCard(context, address, addressProvider, theme, colorScheme);
//                     },
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildAddressCard(
//     BuildContext context, 
//     Address address, 
//     AddressProvider provider,
//     ThemeData theme,
//     ColorScheme colorScheme,
//   ) {
//     return Container(
//       width: double.infinity,
//       decoration: BoxDecoration(
//         color: theme.cardColor,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.1),
//             spreadRadius: 1,
//             blurRadius: 4,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Row(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             // Location Icon
//             Align(
//               alignment: Alignment.centerLeft,
//               child: Container(
//                 margin: const EdgeInsets.only(top: 2),
//                 child: Icon(
//                   Icons.location_on_outlined,
//                   color: colorScheme.primary,
//                   size: 30,
//                 ),
//               ),
//             ),
//             const SizedBox(width: 12),
//             // Address Details
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Container(
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 8,
//                           vertical: 4,
//                         ),
//                         decoration: BoxDecoration(
//                           color: colorScheme.primary.withOpacity(0.1),
//                           borderRadius: BorderRadius.circular(6),
//                         ),
//                         child: Text(
//                           address.addressType,
//                           style: theme.textTheme.titleSmall?.copyWith(
//                             color: colorScheme.primary,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                       ),
//                       PopupMenuButton<String>(
//                         icon: Icon(
//                           Icons.more_vert,
//                           color: colorScheme.onSurfaceVariant,
//                           size: 20,
//                         ),
//                         onSelected: (value) async {
//                           if (value == 'edit') {
//                             // Navigate to edit address
//                             final result = await Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (context) => AddAddress(address: address),
//                               ),
//                             );
//                             if (result == true) {
//                               provider.refreshAddresses();
//                             }
//                           } else if (value == 'delete') {
//                             _showDeleteConfirmation(context, address, provider, theme, colorScheme);
//                           }
//                         },
//                         itemBuilder: (BuildContext context) => [
//                           PopupMenuItem<String>(
//                             value: 'edit',
//                             child: Row(
//                               children: [
//                                 Icon(
//                                   Icons.edit_outlined,
//                                   size: 18,
//                                   color: colorScheme.onSurface,
//                                 ),
//                                 const SizedBox(width: 8),
//                                 Text(
//                                   'Edit',
//                                   style: theme.textTheme.bodyMedium,
//                                 ),
//                               ],
//                             ),
//                           ),
//                           PopupMenuItem<String>(
//                             value: 'delete',
//                             child: Row(
//                               children: [
//                                 Icon(
//                                   Icons.delete_outline,
//                                   size: 18,
//                                   color: colorScheme.error,
//                                 ),
//                                 const SizedBox(width: 8),
//                                 Text(
//                                   'Delete',
//                                   style: theme.textTheme.bodyMedium?.copyWith(
//                                     color: colorScheme.error,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     textAlign: TextAlign.justify,
//                     address.street,
//                     style: theme.textTheme.bodyMedium?.copyWith(
//                       color: colorScheme.onSurface,
//                       height: 1.4,
//                     ),
//                   ),
//                   // if (address.landmark != null && address.landmark!.isNotEmpty) ...[
//                   //   const SizedBox(height: 4),
//                   //   Text(
//                   //     'Landmark: ${address.}',
//                   //     style: theme.textTheme.bodySmall?.copyWith(
//                   //       color: colorScheme.onSurface.withOpacity(0.7),
//                   //     ),
//                   //   ),
//                   // ],
//                   const SizedBox(height: 4),
//                   Text(
//                     '${address.city}, ${address.state} - ${address.postalCode}',
//                     style: theme.textTheme.bodySmall?.copyWith(
//                       color: colorScheme.onSurface.withOpacity(0.7),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _showDeleteConfirmation(
//     BuildContext parentContext, 
//     Address address, 
//     AddressProvider provider,
//     ThemeData theme,
//     ColorScheme colorScheme,
//   ) {
//     showDialog(
//       context: parentContext,
//       builder: (BuildContext dialogContext) {
//         return AlertDialog(
//           backgroundColor: theme.cardColor,
//           surfaceTintColor: theme.cardColor,
//           title: Text(
//             'Delete Address',
//             style: theme.textTheme.titleMedium,
//           ),
//           content: Text(
//             'Are you sure you want to delete "${address.addressType}" address?',
//             style: theme.textTheme.bodyMedium,
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.of(dialogContext).pop(),
//               child: Text(
//                 'Cancel',
//                 style: TextStyle(color: colorScheme.onSurface.withOpacity(0.7)),
//               ),
//             ),
//             TextButton(
//               onPressed: () async {
//                 Navigator.of(dialogContext).pop();

//                 final success = await provider.removeAddress(address.id!);

//                 // ✅ Show snackbar from parentContext after dialog is gone
//                 Future.delayed(const Duration(milliseconds: 100), () {
//                   if (!parentContext.mounted) return;

//                   ScaffoldMessenger.of(parentContext).showSnackBar(
//                     SnackBar(
//                       content: Text(
//                         success
//                             ? 'Address deleted successfully'
//                             : provider.errorMessage,
//                       ),
//                       backgroundColor: success ? colorScheme.primary : colorScheme.error,
//                       behavior: SnackBarBehavior.floating,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                     ),
//                   );
//                 });
//               },
//               child: Text(
//                 'Delete',
//                 style: TextStyle(color: colorScheme.error),
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }











import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:veegify/model/address_model.dart';
import 'package:veegify/provider/address_provider.dart';
import 'package:veegify/views/address/add_address.dart';

class AddressList extends StatefulWidget {
  const AddressList({super.key});

  @override
  State<AddressList> createState() => _AddressListState();
}

class _AddressListState extends State<AddressList> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AddressProvider>().loadAddresses();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.cardColor,
        surfaceTintColor: theme.cardColor,
        elevation: 1,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onBackground),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Addresses',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),

      // ✅ RESPONSIVE BODY
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;

          final bool isMobile = width < 700;
          final bool isTablet = width >= 700 && width < 1100;
          final bool isDesktop = width >= 1100;

          final double maxWidth =
              isDesktop ? 1200 : (isTablet ? 950 : double.infinity);

          final double horizontalPadding =
              isDesktop ? 30 : (isTablet ? 20 : 16);

          final int gridCount = isDesktop ? 3 : (isTablet ? 2 : 1);

          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: 16,
                ),
                child: Column(
                  children: [
                    // ✅ Add Address Button (Responsive)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: SizedBox(
                        width: isMobile ? double.infinity : 260,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AddAddress(),
                              ),
                            );

                            if (result == true) {
                              context.read<AddressProvider>().refreshAddresses();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.primary,
                            foregroundColor: colorScheme.onPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add,
                                color: colorScheme.onPrimary,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Add address',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: colorScheme.onPrimary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ✅ Address List/Grid
                    Expanded(
                      child: Consumer<AddressProvider>(
                        builder: (context, addressProvider, child) {
                          if (addressProvider.isLoading) {
                            return Center(
                              child: CircularProgressIndicator(
                                color: colorScheme.primary,
                              ),
                            );
                          }

                          if (addressProvider.errorMessage.isNotEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.error_outline_rounded,
                                    size: 48,
                                    color: colorScheme.error,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    addressProvider.errorMessage,
                                    textAlign: TextAlign.center,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: colorScheme.error,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: () {
                                      addressProvider.refreshAddresses();
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: colorScheme.primary,
                                      foregroundColor: colorScheme.onPrimary,
                                    ),
                                    child: const Text('Retry'),
                                  ),
                                ],
                              ),
                            );
                          }

                          if (addressProvider.addresses.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.location_off_outlined,
                                    size: 48,
                                    color: colorScheme.onSurface
                                        .withOpacity(0.5),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No addresses found',
                                    style:
                                        theme.textTheme.titleMedium?.copyWith(
                                      color: colorScheme.onSurface
                                          .withOpacity(0.7),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Add your first address to get started',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: colorScheme.onSurface
                                          .withOpacity(0.5),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          // ✅ Mobile -> ListView
                          if (isMobile) {
                            return ListView.separated(
                              itemCount: addressProvider.addresses.length,
                              separatorBuilder: (context, index) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final address =
                                    addressProvider.addresses[index];
                                return _buildAddressCard(
                                  context,
                                  address,
                                  addressProvider,
                                  theme,
                                  colorScheme,
                                );
                              },
                            );
                          }

                          // ✅ Tablet/Web -> GridView
                          return GridView.builder(
                            itemCount: addressProvider.addresses.length,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: gridCount,
                              crossAxisSpacing: 14,
                              mainAxisSpacing: 14,
                              childAspectRatio: isDesktop ? 1.8 : 1.6,
                            ),
                            itemBuilder: (context, index) {
                              final address =
                                  addressProvider.addresses[index];
                              return _buildAddressCard(
                                context,
                                address,
                                addressProvider,
                                theme,
                                colorScheme,
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAddressCard(
    BuildContext context,
    Address address,
    AddressProvider provider,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.location_on_outlined,
              color: colorScheme.primary,
              size: 30,
            ),
            const SizedBox(width: 12),

            // Address Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          address.addressType,
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      PopupMenuButton<String>(
                        icon: Icon(
                          Icons.more_vert,
                          color: colorScheme.onSurfaceVariant,
                          size: 20,
                        ),
                        onSelected: (value) async {
                          if (value == 'edit') {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    AddAddress(address: address),
                              ),
                            );
                            if (result == true) {
                              provider.refreshAddresses();
                            }
                          } else if (value == 'delete') {
                            _showDeleteConfirmation(
                              context,
                              address,
                              provider,
                              theme,
                              colorScheme,
                            );
                          }
                        },
                        itemBuilder: (BuildContext context) => [
                          PopupMenuItem<String>(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.edit_outlined,
                                  size: 18,
                                  color: colorScheme.onSurface,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Edit',
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                          PopupMenuItem<String>(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.delete_outline,
                                  size: 18,
                                  color: colorScheme.error,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Delete',
                                  style:
                                      theme.textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.error,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    address.street,
                    textAlign: TextAlign.justify,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface,
                      height: 1.4,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${address.city}, ${address.state} - ${address.postalCode}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext parentContext,
    Address address,
    AddressProvider provider,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    showDialog(
      context: parentContext,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: theme.cardColor,
          surfaceTintColor: theme.cardColor,
          title: Text(
            'Delete Address',
            style: theme.textTheme.titleMedium,
          ),
          content: Text(
            'Are you sure you want to delete "${address.addressType}" address?',
            style: theme.textTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();

                final success = await provider.removeAddress(address.id!);

                Future.delayed(const Duration(milliseconds: 100), () {
                  if (!parentContext.mounted) return;

                  ScaffoldMessenger.of(parentContext).showSnackBar(
                    SnackBar(
                      content: Text(
                        success
                            ? 'Address deleted successfully'
                            : provider.errorMessage,
                      ),
                      backgroundColor:
                          success ? colorScheme.primary : colorScheme.error,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                });
              },
              child: Text(
                'Delete',
                style: TextStyle(color: colorScheme.error),
              ),
            ),
          ],
        );
      },
    );
  }
}
