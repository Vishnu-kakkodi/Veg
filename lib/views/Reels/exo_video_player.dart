import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

class ExoVideoPlayer extends StatefulWidget {
  final String url;
  final bool autoPlay;

  const ExoVideoPlayer({Key? key, required this.url, this.autoPlay = true})
    : super(key: key);

  @override
  State<ExoVideoPlayer> createState() => _ExoVideoPlayerState();
}

class _ExoVideoPlayerState extends State<ExoVideoPlayer> {
  MethodChannel? _channel;
  bool _isViewReady = false;
  int _viewId = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didUpdateWidget(ExoVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_isViewReady) {
      // Handle autoPlay changes
      if (oldWidget.autoPlay != widget.autoPlay) {
        _updatePlaybackState();
      }
      // Handle URL changes (if needed for different reels)
      if (oldWidget.url != widget.url) {
        _loadNewVideo();
      }
    }
  }

  void _updatePlaybackState() {
    if (widget.autoPlay) {
      _channel?.invokeMethod('play');
    } else {
      _channel?.invokeMethod('pause');
    }
  }

  void _loadNewVideo() {
    if (_channel != null) {
      final Map<String, dynamic> params = {
        'url': widget.url,
        'autoPlay': widget.autoPlay,
      };
      _channel?.invokeMethod('loadVideo', params);
    }
  }

  @override
  void dispose() {
    _channel = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const String viewType = 'com.posternova/ExoPlayerView';
    final Map<String, dynamic> creationParams = {
      'url': widget.url,
      'autoPlay': widget.autoPlay,
    };

    return PlatformViewLink(
      viewType: viewType,
      surfaceFactory: (context, controller) {
        return AndroidViewSurface(
          controller: controller as AndroidViewController,
          gestureRecognizers: const {},
          hitTestBehavior: PlatformViewHitTestBehavior.opaque,
        );
      },
      onCreatePlatformView: (params) {
        _viewId = params.id;
        _channel = MethodChannel('com.posternova/ExoPlayerView_${params.id}');

        return PlatformViewsService.initSurfaceAndroidView(
            id: params.id,
            viewType: viewType,
            layoutDirection: TextDirection.ltr,
            creationParams: creationParams,
            creationParamsCodec: const StandardMessageCodec(),
            onFocus: () => params.onFocusChanged(true),
          )
          ..addOnPlatformViewCreatedListener((id) {
            params.onPlatformViewCreated(id);
            setState(() => _isViewReady = true);
            // Ensure correct initial playback state
            if (widget.autoPlay) {
              _channel?.invokeMethod('play');
            } else {
              _channel?.invokeMethod('pause');
            }
          })
          ..create();
      },
    );
  }
}
