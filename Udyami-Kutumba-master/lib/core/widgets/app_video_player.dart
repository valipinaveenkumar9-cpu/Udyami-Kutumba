import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

/// Helper to detect whether a media URL points to a video file.
bool isVideoUrl(String? url) {
  if (url == null || url.isEmpty) return false;
  final clean = url.toLowerCase().split('?').first.trim();
  return clean.endsWith('.mp4') ||
      clean.endsWith('.mov') ||
      clean.endsWith('.webm') ||
      clean.endsWith('.mkv') ||
      clean.endsWith('.m4v') ||
      clean.endsWith('.3gp') ||
      clean.endsWith('.avi');
}

/// Full-screen / in-app video player that plays videos directly from backend URLs.
class AppVideoPlayerScreen extends StatefulWidget {
  final String videoUrl;
  final String? title;

  const AppVideoPlayerScreen({
    super.key,
    required this.videoUrl,
    this.title,
  });

  /// Convenience method to open the video player screen.
  static Future<void> open(
    BuildContext context, {
    required String videoUrl,
    String? title,
  }) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AppVideoPlayerScreen(
          videoUrl: videoUrl,
          title: title,
        ),
      ),
    );
  }

  @override
  State<AppVideoPlayerScreen> createState() => _AppVideoPlayerScreenState();
}

class _AppVideoPlayerScreenState extends State<AppVideoPlayerScreen> {
  VideoPlayerController? _controller;
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = null;
    });

    try {
      final uri = Uri.tryParse(widget.videoUrl.trim());
      if (uri == null || widget.videoUrl.trim().isEmpty) {
        throw Exception('Invalid video URL: "${widget.videoUrl}"');
      }

      // Initialize VideoPlayerController with the backend network URL
      _controller = VideoPlayerController.networkUrl(uri);
      await _controller!.initialize();

      _controller!.addListener(_onControllerUpdate);

      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });

      // Auto-play when ready
      await _controller!.play();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = 'Could not load video: $e';
      });
    }
  }

  void _onControllerUpdate() {
    if (mounted) {
      setState(() {});
    }
  }

  void _togglePlayPause() {
    if (_controller == null || !_controller!.value.isInitialized) return;

    setState(() {
      if (_controller!.value.isPlaying) {
        _controller!.pause();
      } else {
        // If ended, replay from beginning
        if (_controller!.value.position >= _controller!.value.duration) {
          _controller!.seekTo(Duration.zero);
        }
        _controller!.play();
      }
    });
  }

  void _toggleControlsVisibility() {
    setState(() {
      _showControls = !_showControls;
    });
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (duration.inHours > 0) {
      final hours = duration.inHours.toString().padLeft(2, '0');
      return '$hours:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _controller?.removeListener(_onControllerUpdate);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: SafeArea(
          child: Stack(
            children: [
              // Main Video Display Area
              Center(
                child: _buildVideoContent(),
              ),

              // Top Bar (Back Button + Title)
              if (_showControls || _hasError)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.75),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Colors.white,
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            widget.title ?? 'Video Player',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Center Play / Pause button overlay
              if (!_isLoading && !_hasError && _showControls && _controller != null)
                Center(
                  child: GestureDetector(
                    onTap: _togglePlayPause,
                    child: Container(
                      width: 68,
                      height: 68,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.55),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                      ),
                      child: Icon(
                        _controller!.value.isPlaying
                            ? Icons.pause_rounded
                            : (_controller!.value.position >=
                                    _controller!.value.duration
                                ? Icons.replay_rounded
                                : Icons.play_arrow_rounded),
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                  ),
                ),

              // Bottom Controls Bar (Progress Bar + Time)
              if (!_isLoading && !_hasError && _showControls && _controller != null)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.85),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Scrubbable Progress Bar
                        VideoProgressIndicator(
                          _controller!,
                          allowScrubbing: true,
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          colors: VideoProgressColors(
                            playedColor: theme.colorScheme.primary,
                            bufferedColor: Colors.white.withValues(alpha: 0.35),
                            backgroundColor: Colors.white.withValues(alpha: 0.15),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                IconButton(
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  icon: Icon(
                                    _controller!.value.isPlaying
                                        ? Icons.pause_rounded
                                        : Icons.play_arrow_rounded,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                  onPressed: _togglePlayPause,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  '${_formatDuration(_controller!.value.position)} / ${_formatDuration(_controller!.value.duration)}',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              ],
                            ),
                            // Quick 10s Rewind & Forward
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.replay_10_rounded,
                                    color: Colors.white,
                                    size: 22,
                                  ),
                                  onPressed: () {
                                    final target = _controller!.value.position -
                                        const Duration(seconds: 10);
                                    _controller!.seekTo(
                                      target < Duration.zero
                                          ? Duration.zero
                                          : target,
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.forward_10_rounded,
                                    color: Colors.white,
                                    size: 22,
                                  ),
                                  onPressed: () {
                                    final target = _controller!.value.position +
                                        const Duration(seconds: 10);
                                    final max = _controller!.value.duration;
                                    _controller!.seekTo(
                                      target > max ? max : target,
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVideoContent() {
    if (_isLoading) {
      return const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: Colors.white),
          SizedBox(height: 16),
          Text(
            'Loading video...',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ],
      );
    }

    if (_hasError || _controller == null || !_controller!.value.isInitialized) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: Colors.redAccent,
              size: 48,
            ),
            const SizedBox(height: 14),
            const Text(
              'Unable to Play Video',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'An error occurred while loading the video.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _initializePlayer,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black87,
              ),
            ),
          ],
        ),
      );
    }

    // Video is ready
    final aspect = _controller!.value.aspectRatio;
    return GestureDetector(
      onTap: _toggleControlsVisibility,
      behavior: HitTestBehavior.opaque,
      child: Center(
        child: AspectRatio(
          aspectRatio: aspect > 0 ? aspect : (16 / 9),
          child: Stack(
            fit: StackFit.expand,
            children: [
              VideoPlayer(_controller!),
              if (_controller!.value.isBuffering)
                const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A thumbnail / preview card with a play button overlay for video content.
/// Tapping it opens the [AppVideoPlayerScreen].
class AppVideoThumbnail extends StatelessWidget {
  final String videoUrl;
  final String? title;
  final double? height;
  final double? width;
  final double aspectRatio;
  final BorderRadius? borderRadius;

  const AppVideoThumbnail({
    super.key,
    required this.videoUrl,
    this.title,
    this.height,
    this.width,
    this.aspectRatio = 16 / 9,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(12),
      child: Material(
        color: Colors.black87,
        child: InkWell(
          onTap: () {
            AppVideoPlayerScreen.open(
              context,
              videoUrl: videoUrl,
              title: title,
            );
          },
          child: Container(
            height: height,
            width: width,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF1E2631),
                  const Color(0xFF0F141A),
                ],
              ),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Background video icon watermark
                Center(
                  child: Icon(
                    Icons.movie_outlined,
                    size: 64,
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                ),

                // Center Play Button
                Center(
                  child: Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.65),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.4),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ),

                // Video badge
                Positioned(
                  bottom: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.videocam_rounded,
                          color: Colors.white,
                          size: 12,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'VIDEO',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
