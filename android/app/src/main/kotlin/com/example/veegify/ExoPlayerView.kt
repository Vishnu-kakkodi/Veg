package com.example.veegify

import android.content.Context
import android.view.View
import android.widget.FrameLayout
import androidx.media3.common.MediaItem
import androidx.media3.common.Player
import androidx.media3.exoplayer.ExoPlayer
import androidx.media3.ui.PlayerView
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

class ExoPlayerViewFactory(private val messenger: BinaryMessenger) : PlatformViewFactory(StandardMessageCodec()) {
    override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
        val params = args as? Map<*, *> ?: emptyMap<String, Any>()
        val url = params["url"] as? String ?: ""
        val autoPlay = params["autoPlay"] as? Boolean ?: true
        return ExoPlayerView(context, messenger, viewId, url, autoPlay)
    }
}

class ExoPlayerView(
    private val context: Context,
    messenger: BinaryMessenger,
    viewId: Int,
    private val url: String,
    private val autoPlay: Boolean
) : PlatformView, Player.Listener {

    private val frameLayout = FrameLayout(context)
    private var player: ExoPlayer? = null
    private var playerView: PlayerView? = null
    private val methodChannel = MethodChannel(messenger, "com.posternova/ExoPlayerView_$viewId")

    init {
        initializePlayer()
        methodChannel.setMethodCallHandler { call, result ->
            when (call.method) {
                "play" -> {
                    player?.playWhenReady = true
                    result.success(null)
                }
                "pause" -> {
                    player?.playWhenReady = false
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun initializePlayer() {
        player = ExoPlayer.Builder(context).build().apply {
            val mediaItem = MediaItem.fromUri(url)
            setMediaItem(mediaItem)
            repeatMode = Player.REPEAT_MODE_ALL
            playWhenReady = autoPlay
            addListener(this@ExoPlayerView)
            prepare()
        }

        playerView = PlayerView(context).apply {
            player = this@ExoPlayerView.player
            useController = false
            resizeMode = androidx.media3.ui.AspectRatioFrameLayout.RESIZE_MODE_FILL
            layoutParams = FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.MATCH_PARENT,
                FrameLayout.LayoutParams.MATCH_PARENT
            )
        }

        frameLayout.addView(playerView)
    }

    override fun onPlaybackStateChanged(playbackState: Int) {
        val state = when (playbackState) {
            Player.STATE_READY -> "READY"
            Player.STATE_BUFFERING -> "BUFFERING"
            Player.STATE_ENDED -> "ENDED"
            Player.STATE_IDLE -> "IDLE"
            else -> "UNKNOWN"
        }
        android.util.Log.d("ExoPlayer", "State: $state")
    }

    override fun onPlayerError(error: androidx.media3.common.PlaybackException) {
        android.util.Log.e("ExoPlayer", "Playback error: ${error.message}", error)
    }

    override fun getView(): View = frameLayout

    override fun dispose() {
        methodChannel.setMethodCallHandler(null)
        player?.stop()
        player?.release()
        player = null
        playerView?.player = null
        playerView = null
    }
}