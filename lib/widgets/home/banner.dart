// import 'package:carousel_slider/carousel_slider.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../provider/BannerProvider/banner_provider.dart';

// class PromoBanner extends StatefulWidget {
//   const PromoBanner({super.key});

//   @override
//   State<PromoBanner> createState() => _PromoBannerState();
// }

// class _PromoBannerState extends State<PromoBanner> {
//   int _currentIndex = 0;

//   @override
//   Widget build(BuildContext context) {
//     final bannerProvider = Provider.of<BannerProvider>(context);

//     if (bannerProvider.isLoading) {
//       return const SizedBox(
//         height: 180,
//         child: Center(child: CircularProgressIndicator()),
//       );
//     }

//     if (bannerProvider.banners.isEmpty) {
//       return const SizedBox(
//         height: 180,
//         child: Center(child: Text('No banners available')),
//       );
//     }

//     return Column(
//       children: [
//         CarouselSlider(
//           items: bannerProvider.banners
//               .map(
//                 (banner) => ClipRRect(
//                   borderRadius: BorderRadius.circular(12),
//                   child: Image.network(
//                     banner.imageUrl,
//                     fit: BoxFit.fill,
//                     width: double.infinity,
//                     loadingBuilder: (context, child, progress) {
//                       if (progress == null) return child;
//                       return Container(
//                         color: Colors.grey[200],
//                         child: const Center(child: CircularProgressIndicator()),
//                       );
//                     },
//                     errorBuilder: (context, error, stackTrace) =>
//                         const Center(child: Icon(Icons.error)),
//                   ),
//                 ),
//               )
//               .toList(),
//           options: CarouselOptions(
//             height: 130,
//             autoPlay: true,
//             enlargeCenterPage: true,
//             viewportFraction: 0.95,
//             onPageChanged: (index, reason) {
//               setState(() => _currentIndex = index);
//             },
//           ),
//         ),
//         const SizedBox(height: 8),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: bannerProvider.banners.asMap().entries.map((entry) {
//             return Container(
//               width: 8.0,
//               height: 8.0,
//               margin: const EdgeInsets.symmetric(horizontal: 4.0),
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 color: _currentIndex == entry.key
//                     ? Colors.green
//                     : Colors.grey.shade400,
//               ),
//             );
//           }).toList(),
//         ),
//       ],
//     );
//   }
// }










import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/BannerProvider/banner_provider.dart';

class PromoBanner extends StatefulWidget {
  const PromoBanner({super.key});

  @override
  State<PromoBanner> createState() => _PromoBannerState();
}

class _PromoBannerState extends State<PromoBanner> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bannerProvider = Provider.of<BannerProvider>(context);
    final isDark = theme.brightness == Brightness.dark;

    if (bannerProvider.isLoading) {
      return SizedBox(
        height: 140,
        child: Center(
          child: SizedBox(
            height: 28,
            width: 28,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(
                theme.colorScheme.primary,
              ),
            ),
          ),
        ),
      );
    }

    if (bannerProvider.banners.isEmpty) {
      return SizedBox(
        height: 120,
        child: Center(
          child: Text(
            'No offers available',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        CarouselSlider(
          items: bannerProvider.banners.map((banner) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Image
                  AspectRatio(
                    aspectRatio: 16 / 6,
                    child: Image.network(
                      banner.imageUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return Container(
                          color: isDark ? Colors.grey[850] : Colors.grey[200],
                          child: Center(
                            child: SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  theme.colorScheme.primary,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: isDark ? Colors.grey[900] : Colors.grey[200],
                        child: Center(
                          child: Icon(
                            Icons.broken_image_outlined,
                            size: 32,
                            color: theme.colorScheme.onSurface
                                .withOpacity(0.5),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Gradient overlay (for future text / better look)
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withOpacity(0.45),
                          Colors.black.withOpacity(0.05),
                        ],
                      ),
                    ),
                  ),

                  // Optional content (if later you want to put title/cta)
                  // Positioned(
                  //   left: 16,
                  //   bottom: 16,
                  //   right: 16,
                  //   child: Text(
                  //     banner.title ?? '',
                  //     style: theme.textTheme.titleMedium?.copyWith(
                  //       color: Colors.white,
                  //       fontWeight: FontWeight.w600,
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            );
          }).toList(),
          options: CarouselOptions(
            height: 140,
            autoPlay: true,
            enlargeCenterPage: true,
            viewportFraction: 0.95,
            autoPlayInterval: const Duration(seconds: 4),
            autoPlayAnimationDuration: const Duration(milliseconds: 600),
            onPageChanged: (index, reason) {
              setState(() => _currentIndex = index);
            },
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: bannerProvider.banners.asMap().entries.map((entry) {
            final bool isActive = _currentIndex == entry.key;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
              width: isActive ? 16.0 : 8.0,
              height: 8.0,
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: isActive
                    ? theme.colorScheme.primary
                    : theme.disabledColor.withOpacity(0.6),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
