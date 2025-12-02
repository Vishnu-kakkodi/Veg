import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class OfferVideoPlayerLazy extends StatefulWidget {
  final String? videoUrl; // optional network video
  final String assetVideo; // fallback asset video
  final double height;
  final double width;

  const OfferVideoPlayerLazy({
    Key? key,
    this.videoUrl,
    this.assetVideo = 'assets/videos/home.mp4',
    this.height = 200,
    this.width = double.infinity,
  }) : super(key: key);

  @override
  State<OfferVideoPlayerLazy> createState() => _OfferVideoPlayerLazyState();
}

class _OfferVideoPlayerLazyState extends State<OfferVideoPlayerLazy> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();

    // Use network video if provided, else asset video
    if (widget.videoUrl != null && widget.videoUrl!.isNotEmpty) {
      _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl!));
    } else {
      _controller = VideoPlayerController.asset(widget.assetVideo);
    }

    // Initialize, autoplay, and loop immediately
    _controller.initialize().then((_) {
      _controller.setLooping(true);
      _controller.play();
      setState(() {}); // refresh widget once initialized
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        height: widget.height,
        width: widget.width,
        child: VideoPlayer(_controller), // no loader, no controls
      ),
    );
  }
}
