// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:provider/provider.dart';
// import 'package:share_plus/share_plus.dart';
// import 'package:video_player/video_player.dart';
// import 'package:visibility_detector/visibility_detector.dart';
// import 'package:http/http.dart' as http;

// import 'package:veegify/helper/storage_helper.dart';
// import 'package:veegify/model/user_model.dart';
// import 'package:veegify/utils/responsive.dart';

// // ─────────────────────────────────────────────
// //  DATA MODEL  (update fields once API is ready)
// // ─────────────────────────────────────────────

// class ReelItem {
//   final String id;
//   final String videoUrl; // full URL to mp4 / HLS stream
//   final String thumbUrl; // poster / thumbnail
//   final String title;
//   final String description;
//   final String? restaurantName;
//   final String? restaurantId;
//   final String? deepLink; // optional share link

//   const ReelItem({
//     required this.id,
//     required this.videoUrl,
//     required this.thumbUrl,
//     required this.title,
//     required this.description,
//     this.restaurantName,
//     this.restaurantId,
//     this.deepLink,
//   });

//   /// ✅  Adjust keys to match your actual API response
//   factory ReelItem.fromJson(Map<String, dynamic> json) {
//     return ReelItem(
//       id: json['_id'] ?? json['id'] ?? '',
//       videoUrl: json['videoUrl'] ?? json['video_url'] ?? '',
//       thumbUrl: json['thumbUrl'] ?? json['thumbnail'] ?? '',
//       title: json['title'] ?? '',
//       description: json['description'] ?? '',
//       restaurantName: json['restaurantName'],
//       restaurantId: json['restaurantId'],
//       deepLink: json['deepLink'] ?? json['shareLink'],
//     );
//   }
// }

// /// Parse top-level API response.
// /// ✅ Adjust wrapper key once you share your response structure.
// List<ReelItem> reelsFromApiResponse(String body) {
//   final decoded = jsonDecode(body);

//   // Common patterns:  { reels: [...] }  |  { data: [...] }  |  [...]
//   List<dynamic> list;
//   if (decoded is List) {
//     list = decoded;
//   } else if (decoded is Map) {
//     list = decoded['reels'] ?? decoded['data'] ?? decoded['items'] ?? [];
//   } else {
//     list = [];
//   }

//   return list.map((e) => ReelItem.fromJson(e as Map<String, dynamic>)).toList();
// }

// // ─────────────────────────────────────────────
// //  SCREEN WRAPPER (matches existing nav pattern)
// // ─────────────────────────────────────────────

// class ReelsScreenWithController extends StatelessWidget {
//   final ScrollController scrollController;

//   const ReelsScreenWithController({
//     super.key,
//     required this.scrollController,
//   });

//   @override
//   Widget build(BuildContext context) => const ReelsScreen();
// }

// // ─────────────────────────────────────────────
// //  MAIN REELS SCREEN
// // ─────────────────────────────────────────────

// class ReelsScreen extends StatefulWidget {
//   const ReelsScreen({super.key});

//   @override
//   State<ReelsScreen> createState() => _ReelsScreenState();
// }

// class _ReelsScreenState extends State<ReelsScreen> {
//   static const String _apiHost = "https://api.vegiffyy.com";

//   final PageController _pageController = PageController();

//   List<ReelItem> _reels = [];
//   bool _loading = true;
//   String? _error;

//   int _currentPage = 0;

//   @override
//   void initState() {
//     super.initState();
//     _fetchReels();
//     // Make status bar overlay for immersive look
//     SystemChrome.setSystemUIOverlayStyle(
//       const SystemUiOverlayStyle(
//         statusBarColor: Colors.transparent,
//         statusBarIconBrightness: Brightness.light,
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _pageController.dispose();
//     super.dispose();
//   }

//   // ── API ──────────────────────────────────────

//   Future<void> _fetchReels() async {
//     setState(() {
//       _loading = true;
//       _error = null;
//     });

//     try {
//       /// ✅ Replace endpoint once confirmed by backend
//       final url = Uri.parse("$_apiHost/api/vendor/getallreels");
//       final response = await http.get(url);

//       debugPrint("Reels response [${response.statusCode}]: ${response.body}");

//       if (response.statusCode == 200) {
//         final reels = reelsFromApiResponse(response.body);
//         setState(() {
//           _reels = reels;
//           _loading = false;
//           if (_reels.isEmpty) _error = "No reels found";
//         });
//       } else {
//         setState(() {
//           _loading = false;
//           _error = "Failed to load reels (${response.statusCode})";
//         });
//       }
//     } on SocketException {
//       setState(() {
//         _loading = false;
//         _error = "No internet connection";
//       });
//     } catch (e, st) {
//       debugPrint("Error fetching reels: $e\n$st");
//       setState(() {
//         _loading = false;
//         _error = "Something went wrong";
//       });
//     }
//   }

//   // ── SHARE ────────────────────────────────────

//   Future<void> _shareReel(ReelItem reel) async {
//     final shareText = reel.deepLink?.isNotEmpty == true
//         ? "Check out this on Vegiffy! 🌿\n${reel.deepLink}"
//         : "Check out this on Vegiffy! 🌿\n$_apiHost";
//     await Share.share(shareText, subject: reel.title);
//   }

//   // ── BUILD ─────────────────────────────────────

//   @override
//   Widget build(BuildContext context) {
//     // Full immersive – no AppBar
//     return Scaffold(
//       backgroundColor: Colors.black,
//       extendBodyBehindAppBar: true,
//       body: _loading
//           ? _buildLoader()
//           : _error != null && _reels.isEmpty
//               ? _buildError()
//               : _buildReelsFeed(),
//     );
//   }

//   Widget _buildLoader() {
//     return const Center(
//       child: CircularProgressIndicator(color: Colors.white),
//     );
//   }

//   Widget _buildError() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           const Icon(Icons.wifi_off, color: Colors.white54, size: 64),
//           const SizedBox(height: 16),
//           Text(
//             _error ?? "Something went wrong",
//             style: const TextStyle(color: Colors.white70, fontSize: 16),
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 24),
//           ElevatedButton.icon(
//             onPressed: _fetchReels,
//             icon: const Icon(Icons.refresh),
//             label: const Text("Retry"),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: const Color(0xFF4CAF50),
//               foregroundColor: Colors.white,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(24),
//               ),
//               padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildReelsFeed() {
//     return PageView.builder(
//       controller: _pageController,
//       scrollDirection: Axis.vertical,
//       physics: const PageScrollPhysics(),
//       itemCount: _reels.length,
//       onPageChanged: (index) => setState(() => _currentPage = index),
//       itemBuilder: (context, index) {
//         return _ReelPlayerPage(
//           key: ValueKey(_reels[index].id),
//           reel: _reels[index],
//           isActive: index == _currentPage,
//           onShare: () => _shareReel(_reels[index]),
//         );
//       },
//     );
//   }
// }

// // ─────────────────────────────────────────────
// //  SINGLE REEL PAGE
// // ─────────────────────────────────────────────

// class _ReelPlayerPage extends StatefulWidget {
//   final ReelItem reel;
//   final bool isActive;
//   final VoidCallback onShare;

//   const _ReelPlayerPage({
//     super.key,
//     required this.reel,
//     required this.isActive,
//     required this.onShare,
//   });

//   @override
//   State<_ReelPlayerPage> createState() => _ReelPlayerPageState();
// }

// class _ReelPlayerPageState extends State<_ReelPlayerPage>
//     with SingleTickerProviderStateMixin {
//   VideoPlayerController? _videoController;
//   bool _initialized = false;
//   bool _showPlayIcon = false;
//   late AnimationController _playIconAnim;

//   @override
//   void initState() {
//     super.initState();
//     _playIconAnim = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 400),
//     );
//     _initVideo();
//   }

//   Future<void> _initVideo() async {
//     if (widget.reel.videoUrl.isEmpty) return;

//     final controller = VideoPlayerController.networkUrl(
//       Uri.parse(widget.reel.videoUrl),
//     );

//     await controller.initialize();
//     controller.setLooping(true);

//     if (!mounted) {
//       controller.dispose();
//       return;
//     }

//     setState(() {
//       _videoController = controller;
//       _initialized = true;
//     });

//     if (widget.isActive) {
//       controller.play();
//     }
//   }

//   @override
//   void didUpdateWidget(covariant _ReelPlayerPage oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (!_initialized) return;

//     if (widget.isActive && !oldWidget.isActive) {
//       _videoController?.play();
//     } else if (!widget.isActive && oldWidget.isActive) {
//       _videoController?.pause();
//     }
//   }

//   @override
//   void dispose() {
//     _videoController?.dispose();
//     _playIconAnim.dispose();
//     super.dispose();
//   }

//   void _togglePlay() {
//     if (_videoController == null) return;

//     if (_videoController!.value.isPlaying) {
//       _videoController!.pause();
//     } else {
//       _videoController!.play();
//     }

//     // Flash play/pause icon
//     setState(() => _showPlayIcon = true);
//     _playIconAnim.forward(from: 0).then((_) {
//       if (mounted) setState(() => _showPlayIcon = false);
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;

//     return GestureDetector(
//       onTap: _togglePlay,
//       child: Stack(
//         fit: StackFit.expand,
//         children: [
//           // ── VIDEO / THUMBNAIL ──────────────────
//           _buildVideoLayer(size),

//           // ── GRADIENT OVERLAY ───────────────────
//           _buildGradientOverlay(),

//           // ── PLAY / PAUSE FLASH ICON ────────────
//           if (_showPlayIcon) _buildPlayFlash(),

//           // ── BOTTOM INFO + SHARE ────────────────
//           Positioned(
//             left: 0,
//             right: 0,
//             bottom: 0,
//             child: _buildBottomBar(),
//           ),

//           // ── PROGRESS BAR ──────────────────────
//           if (_initialized && _videoController != null)
//             Positioned(
//               left: 0,
//               right: 0,
//               bottom: 0,
//               child: _buildProgressBar(),
//             ),
//         ],
//       ),
//     );
//   }

//   Widget _buildVideoLayer(Size size) {
//     if (_initialized && _videoController != null) {
//       return SizedBox.expand(
//         child: FittedBox(
//           fit: BoxFit.cover,
//           child: SizedBox(
//             width: _videoController!.value.size.width,
//             height: _videoController!.value.size.height,
//             child: VideoPlayer(_videoController!),
//           ),
//         ),
//       );
//     }

//     // Thumbnail while loading
//     return widget.reel.thumbUrl.isNotEmpty
//         ? Image.network(
//             widget.reel.thumbUrl,
//             fit: BoxFit.cover,
//             errorBuilder: (_, __, ___) =>
//                 Container(color: const Color(0xFF1A1A1A)),
//           )
//         : Container(color: const Color(0xFF1A1A1A));
//   }

//   Widget _buildGradientOverlay() {
//     return Container(
//       decoration: const BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topCenter,
//           end: Alignment.bottomCenter,
//           stops: [0.0, 0.4, 0.7, 1.0],
//           colors: [
//             Color(0x44000000),
//             Colors.transparent,
//             Color(0x66000000),
//             Color(0xCC000000),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildPlayFlash() {
//     return Center(
//       child: FadeTransition(
//         opacity: Tween<double>(begin: 1, end: 0).animate(
//           CurvedAnimation(parent: _playIconAnim, curve: Curves.easeOut),
//         ),
//         child: Container(
//           padding: const EdgeInsets.all(20),
//           decoration: BoxDecoration(
//             color: Colors.black45,
//             shape: BoxShape.circle,
//           ),
//           child: Icon(
//             _videoController?.value.isPlaying == true
//                 ? Icons.play_arrow_rounded
//                 : Icons.pause_rounded,
//             color: Colors.white,
//             size: 56,
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildBottomBar() {
//     final reel = widget.reel;

//     return Padding(
//       padding: EdgeInsets.fromLTRB(
//         20,
//         0,
//         20,
//         MediaQuery.of(context).padding.bottom + 80, // above bottom nav
//       ),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.end,
//         children: [
//           // ── TEXT INFO ─────────────────────────
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 if (reel.restaurantName?.isNotEmpty == true) ...[
//                   Row(
//                     children: [
//                       Container(
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 10, vertical: 4),
//                         decoration: BoxDecoration(
//                           color: const Color(0xFF4CAF50).withOpacity(0.9),
//                           borderRadius: BorderRadius.circular(20),
//                         ),
//                         child: Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             const Icon(Icons.store,
//                                 color: Colors.white, size: 12),
//                             const SizedBox(width: 4),
//                             Text(
//                               reel.restaurantName!,
//                               style: const TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 12,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 8),
//                 ],
//                 Text(
//                   reel.title,
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                     height: 1.3,
//                     shadows: [
//                       Shadow(
//                           color: Colors.black54,
//                           blurRadius: 6,
//                           offset: Offset(0, 1))
//                     ],
//                   ),
//                   maxLines: 2,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//                 if (reel.description.isNotEmpty) ...[
//                   const SizedBox(height: 6),
//                   Text(
//                     reel.description,
//                     style: const TextStyle(
//                       color: Colors.white70,
//                       fontSize: 13,
//                       height: 1.4,
//                     ),
//                     maxLines: 2,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 ],
//               ],
//             ),
//           ),

//           const SizedBox(width: 16),

//           // ── SHARE BUTTON ──────────────────────
//           _buildShareButton(),
//         ],
//       ),
//     );
//   }

//   Widget _buildShareButton() {
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         GestureDetector(
//           onTap: widget.onShare,
//           child: Container(
//             width: 52,
//             height: 52,
//             decoration: BoxDecoration(
//               color: Colors.white.withOpacity(0.15),
//               shape: BoxShape.circle,
//               border: Border.all(color: Colors.white30, width: 1),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.3),
//                   blurRadius: 8,
//                   offset: const Offset(0, 2),
//                 ),
//               ],
//             ),
//             child: const Icon(
//               Icons.share_rounded,
//               color: Colors.white,
//               size: 24,
//             ),
//           ),
//         ),
//         const SizedBox(height: 6),
//         const Text(
//           "Share",
//           style: TextStyle(
//             color: Colors.white70,
//             fontSize: 11,
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildProgressBar() {
//     return ValueListenableBuilder<VideoPlayerValue>(
//       valueListenable: _videoController!,
//       builder: (context, value, _) {
//         final duration = value.duration.inMilliseconds;
//         final position = value.position.inMilliseconds;
//         final progress =
//             duration > 0 ? (position / duration).clamp(0.0, 1.0) : 0.0;

//         return LinearProgressIndicator(
//           value: progress,
//           backgroundColor: Colors.white24,
//           valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
//           minHeight: 3,
//         );
//       },
//     );
//   }
// }

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:http/http.dart' as http;

// ─────────────────────────────────────────────
//  DATA MODEL
// ─────────────────────────────────────────────

class ReelItem {
  final String id;
  final String videoUrl;
  final String thumbUrl;
  final String title;
  final String description;
  final String? restaurantName;
  final String? restaurantId;

  const ReelItem({
    required this.id,
    required this.videoUrl,
    required this.thumbUrl,
    required this.title,
    required this.description,
    this.restaurantName,
    this.restaurantId,
  });

  factory ReelItem.fromJson(Map<String, dynamic> json) {
    return ReelItem(
      id: json['_id'] ?? json['id'] ?? '',
      videoUrl: json['videoUrl'] ?? json['video_url'] ?? '',
      thumbUrl: json['thumbUrl'] ?? json['thumbnail'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      restaurantName: json['restaurantName'],
      restaurantId: json['restaurantId'],
    );
  }
}

List<ReelItem> reelsFromApiResponse(String body) {
  final decoded = jsonDecode(body);
  List<dynamic> list;
  if (decoded is List) {
    list = decoded;
  } else if (decoded is Map) {
    list = decoded['reels'] ?? decoded['data'] ?? decoded['items'] ?? [];
  } else {
    list = [];
  }
  return list.map((e) => ReelItem.fromJson(e as Map<String, dynamic>)).toList();
}

// ─────────────────────────────────────────────
//  SCREEN WRAPPER
// ─────────────────────────────────────────────

class ReelsScreenWithController extends StatelessWidget {
  final ScrollController scrollController;
  final bool isScreenVisible;

  const ReelsScreenWithController({
    super.key,
    required this.scrollController,
    this.isScreenVisible = false,
  });

  @override
  Widget build(BuildContext context) =>
      ReelsScreen(isScreenVisible: isScreenVisible);
}

// ─────────────────────────────────────────────
//  MAIN REELS SCREEN
// ─────────────────────────────────────────────

class ReelsScreen extends StatefulWidget {
  /// ✅ KEY FIX: Pass true only when this tab is actually selected.
  /// When false (other tabs open), videos never initialize or play.
  final bool isScreenVisible;

  const ReelsScreen({
    super.key,
    this.isScreenVisible = false,
  });

  @override
  State<ReelsScreen> createState() => _ReelsScreenState();
}

class _ReelsScreenState extends State<ReelsScreen> with WidgetsBindingObserver {
  static const String _apiHost = "https://api.vegiffyy.com";

  final PageController _pageController = PageController();

  List<ReelItem> _reels = [];
  bool _loading = false; // start false — don't load until tab is active
  String? _error;
  int _currentPage = 0;
  bool _appInForeground = true;

  bool get _isActive => widget.isScreenVisible && _appInForeground;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Only fetch if tab is already selected on mount
    if (widget.isScreenVisible) {
      _fetchReels();
    }
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
  }

  @override
  void didUpdateWidget(covariant ReelsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Tab just became active for the first time
    if (widget.isScreenVisible && !oldWidget.isScreenVisible) {
      if (_reels.isEmpty && !_loading) {
        _fetchReels();
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pageController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      setState(() => _appInForeground = false);
    } else if (state == AppLifecycleState.resumed) {
      setState(() => _appInForeground = true);
    }
  }

  Future<void> _fetchReels() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final url = Uri.parse("$_apiHost/api/vendor/getallreels");
      final response = await http.get(url);

      debugPrint("Reels response [${response.statusCode}]: ${response.body}");

      if (response.statusCode == 200) {
        final reels = reelsFromApiResponse(response.body);
        setState(() {
          _reels = reels;
          _loading = false;
          if (_reels.isEmpty) _error = "No reels found";
        });
      } else {
        setState(() {
          _loading = false;
          _error = "Failed to load reels (${response.statusCode})";
        });
      }
    } on SocketException {
      setState(() {
        _loading = false;
        _error = "No internet connection";
      });
    } catch (e, st) {
      debugPrint("Error fetching reels: $e\n$st");
      setState(() {
        _loading = false;
        _error = "Something went wrong";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // ✅ While tab is not selected, render nothing — no video controllers created
    if (!widget.isScreenVisible) {
      return const Scaffold(backgroundColor: Colors.black);
    }

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      body: _loading
          ? _buildLoader()
          : _error != null && _reels.isEmpty
              ? _buildError()
              : _buildReelsFeed(),
    );
  }

  Widget _buildLoader() {
    return const Center(
      child: CircularProgressIndicator(color: Colors.white),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wifi_off, color: Colors.white54, size: 64),
          const SizedBox(height: 16),
          Text(
            _error ?? "Something went wrong",
            style: const TextStyle(color: Colors.white70, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _fetchReels,
            icon: const Icon(Icons.refresh),
            label: const Text("Retry"),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReelsFeed() {
    return PageView.builder(
      controller: _pageController,
      scrollDirection: Axis.vertical,
      physics: const PageScrollPhysics(),
      itemCount: _reels.length,
      onPageChanged: (index) => setState(() => _currentPage = index),
      itemBuilder: (context, index) {
        return _ReelPlayerPage(
          key: ValueKey(_reels[index].id),
          reel: _reels[index],
          isActive: index == _currentPage && _isActive,
        );
      },
    );
  }
}

// ─────────────────────────────────────────────
//  SINGLE REEL PAGE
// ─────────────────────────────────────────────

class _ReelPlayerPage extends StatefulWidget {
  final ReelItem reel;
  final bool isActive;

  const _ReelPlayerPage({
    super.key,
    required this.reel,
    required this.isActive,
  });

  @override
  State<_ReelPlayerPage> createState() => _ReelPlayerPageState();
}

class _ReelPlayerPageState extends State<_ReelPlayerPage>
    with SingleTickerProviderStateMixin {
  VideoPlayerController? _videoController;
  bool _initialized = false;
  bool _showPlayIcon = false;
  late AnimationController _playIconAnim;

  @override
  void initState() {
    super.initState();
    _playIconAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    if (widget.isActive) {
      _initVideo();
    }
  }

  Future<void> _initVideo() async {
    if (widget.reel.videoUrl.isEmpty) return;

    final controller = VideoPlayerController.networkUrl(
      Uri.parse(widget.reel.videoUrl),
    );

    await controller.initialize();
    controller.setLooping(true);

    if (!mounted) {
      controller.dispose();
      return;
    }

    setState(() {
      _videoController = controller;
      _initialized = true;
    });

    if (widget.isActive) {
      controller.play();
    }
  }

  @override
  void didUpdateWidget(covariant _ReelPlayerPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isActive && !oldWidget.isActive && !_initialized) {
      _initVideo();
      return;
    }

    if (!_initialized) return;

    if (widget.isActive && !oldWidget.isActive) {
      _videoController?.play();
    } else if (!widget.isActive && oldWidget.isActive) {
      _videoController?.pause();
      _videoController?.seekTo(Duration.zero);
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _playIconAnim.dispose();
    super.dispose();
  }

  void _togglePlay() {
    if (_videoController == null) return;
    if (_videoController!.value.isPlaying) {
      _videoController!.pause();
    } else {
      _videoController!.play();
    }
    setState(() => _showPlayIcon = true);
    _playIconAnim.forward(from: 0).then((_) {
      if (mounted) setState(() => _showPlayIcon = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _togglePlay,
      child: Stack(
        fit: StackFit.expand,
        children: [
          _buildVideoLayer(),
          _buildGradientOverlay(),
          if (_initialized && _videoController != null)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _buildTopProgressBar(),
            ),
          if (_showPlayIcon) _buildPlayFlash(),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildBottomBar(),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoLayer() {
    if (_initialized && _videoController != null) {
      return SizedBox.expand(
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: _videoController!.value.size.width,
            height: _videoController!.value.size.height,
            child: VideoPlayer(_videoController!),
          ),
        ),
      );
    }
    return widget.reel.thumbUrl.isNotEmpty
        ? Image.network(
            widget.reel.thumbUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) =>
                Container(color: const Color(0xFF1A1A1A)),
          )
        : Container(color: const Color(0xFF1A1A1A));
  }

  Widget _buildGradientOverlay() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0.0, 0.4, 0.7, 1.0],
          colors: [
            Color(0x55000000),
            Colors.transparent,
            Color(0x66000000),
            Color(0xCC000000),
          ],
        ),
      ),
    );
  }

  Widget _buildTopProgressBar() {
    return ValueListenableBuilder<VideoPlayerValue>(
      valueListenable: _videoController!,
      builder: (context, value, _) {
        final duration = value.duration.inMilliseconds;
        final position = value.position.inMilliseconds;
        final progress =
            duration > 0 ? (position / duration).clamp(0.0, 1.0) : 0.0;

        return Container(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 4,
          ),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.white24,
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
            minHeight: 3,
          ),
        );
      },
    );
  }

  Widget _buildPlayFlash() {
    return Center(
      child: FadeTransition(
        opacity: Tween<double>(begin: 1, end: 0).animate(
          CurvedAnimation(parent: _playIconAnim, curve: Curves.easeOut),
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.black45,
            shape: BoxShape.circle,
          ),
          child: Icon(
            _videoController?.value.isPlaying == true
                ? Icons.play_arrow_rounded
                : Icons.pause_rounded,
            color: Colors.white,
            size: 56,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    final reel = widget.reel;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        0,
        20,
        MediaQuery.of(context).padding.bottom + 80,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (reel.restaurantName?.isNotEmpty == true) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50).withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.store, color: Colors.white, size: 12),
                  const SizedBox(width: 4),
                  Text(
                    reel.restaurantName!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
          Text(
            reel.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              height: 1.3,
              shadows: [
                Shadow(
                    color: Colors.black54, blurRadius: 6, offset: Offset(0, 1))
              ],
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (reel.description.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              reel.description,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}
