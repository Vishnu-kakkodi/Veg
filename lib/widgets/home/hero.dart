import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:veegify/provider/BannerProvider/banner_provider.dart';
import 'package:veegify/provider/LocationProvider/location_provider.dart';
import 'package:veegify/utils/responsive.dart';
import 'package:veegify/views/address/location_picker.dart';
import 'package:veegify/widgets/home/search.dart';

Widget buildHeroSection({
  required BuildContext context,
  required String? userId,
  required int currentIndex,
  required GlobalKey searchBarKey,
}) {
  final theme = Theme.of(context);
  final isDesktop = Responsive.isDesktop(context);

  return Container(
    width: double.infinity,
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color.fromARGB(255, 91, 163, 43),
          Color.fromARGB(255, 91, 163, 43),
        ],
      ),
    ),
    child: Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1400),
        padding: EdgeInsets.symmetric(
          horizontal: isDesktop ? 120 : 16,
          vertical: isDesktop ? 80 : 40,
        ),
        child: Row(
          children: [
            // Left side - Text content
            Expanded(
              flex: isDesktop ? 5 : 6,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                                    // Search bar in hero
                  Container(
                    key: searchBarKey,
                    constraints: const BoxConstraints(maxWidth: 500),
                    child: const SearchBarWithVoice(),
                  ),
                                    SizedBox(height: isDesktop ? 24 : 16),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'The Best Online Pure Veg Store',
                      style: TextStyle(
                        fontSize: isDesktop ? 14 : 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(height: isDesktop ? 20 : 12),
     Text(
  'Your One-Stop Destination\nfor Pure Veg Food',
  style: GoogleFonts.outfit(
    fontWeight: FontWeight.w800,
    fontSize: isDesktop ? 48 : 28,
    height: 1.2,
    color: theme.colorScheme.onBackground,
  ),
),
                  SizedBox(height: isDesktop ? 20 : 12),
                  Text(
                    'Discover delicious vegetarian food delivered\nstraight to your doorstep.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontSize: isDesktop ? 16 : 14,
                      color: Colors.white,
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: isDesktop ? 24 : 16),

                  // Location display
                  Consumer<LocationProvider>(
                    builder: (context, locationProvider, _) {
                      if (locationProvider.hasLocation) {
                        return InkWell(
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => LocationPickerScreen(
                                  isEditing: false,
                                  userId: userId?.toString() ?? '',
                                ),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: theme.colorScheme.outline
                                    .withOpacity(0.2),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.location_on,
                                  color: theme.colorScheme.primary,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Deliver to',
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                          color: theme.colorScheme.onSurface
                                              .withOpacity(0.6),
                                          fontSize: 11,
                                        ),
                                      ),
                                      Text(
                                        locationProvider.address ??
                                            'Select Location',
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  Icons.keyboard_arrow_down,
                                  size: 18,
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.6),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),

                ],
              ),
            ),

            // Right side - Image
            if (isDesktop)
              Expanded(
                flex: 6,
                child: Padding(
                  padding: const EdgeInsets.only(left: 40),
                  child: Consumer<BannerProvider>(
                    builder: (context, bannerProvider, _) {
                      if (bannerProvider.isLoading) {
                        return _desktopBannerPlaceholder(theme);
                      }

                      if (bannerProvider.banners.isEmpty) {
                        return _desktopBannerFallback(theme);
                      }

                      final banner = bannerProvider.banners[
                          currentIndex % bannerProvider.banners.length];

                      return AnimatedSwitcher(
                        duration: const Duration(milliseconds: 600),
                        switchInCurve: Curves.easeInOut,
                        switchOutCurve: Curves.easeInOut,
                        child: ClipRRect(
                          key: ValueKey(banner.imageUrl),
                          borderRadius: BorderRadius.circular(20),
                          child: Image.network(
                            banner.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                _desktopBannerFallback(theme),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              )
          ],
        ),
      ),
    ),
  );
}

// Helper methods that are also needed
Widget _desktopBannerPlaceholder(ThemeData theme) {
  return Container(
    height: 400,
    decoration: BoxDecoration(
      color: theme.colorScheme.primary.withOpacity(0.08),
      borderRadius: BorderRadius.circular(20),
    ),
    child: const Center(
      child: CircularProgressIndicator(strokeWidth: 2.5),
    ),
  );
}

Widget _desktopBannerFallback(ThemeData theme) {
  return Container(
    height: 400,
    decoration: BoxDecoration(
      color: theme.colorScheme.primary.withOpacity(0.1),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Icon(
      Icons.shopping_basket_rounded,
      size: 120,
      color: theme.colorScheme.primary,
    ),
  );
}
