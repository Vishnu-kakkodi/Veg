import 'dart:async';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';

class SearchBarWithVoice extends StatefulWidget {
  const SearchBarWithVoice({super.key});

  @override
  State<SearchBarWithVoice> createState() => _SearchBarWithVoiceState();
}

class _SearchBarWithVoiceState extends State<SearchBarWithVoice>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  
  bool _isListening = false;
  String _recognizedText = '';
  bool _showSpeakPrompt = false;
  
  // Speech to text instance
  late stt.SpeechToText _speech;
  bool _speechAvailable = false;

  // Animation controllers for voice listening
  late AnimationController _pulseAnimationController;
  late Animation<double> _pulseAnimation;
  
  // Timer for showing "speak anything" prompt
  Timer? _silenceTimer;
  Timer? _autoCloseTimer;

  @override
  void initState() {
    super.initState();
    
    // Initialize speech to text
    _speech = stt.SpeechToText();
    _initializeSpeech();
    
    // Initialize pulse animation for listening state
    _pulseAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseAnimationController,
      curve: Curves.easeInOut,
    ));
  }
  
  Future<void> _initializeSpeech() async {
    try {
      _speechAvailable = await _speech.initialize(
        onError: (error) {
          print('Speech recognition error: $error');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Speech can not recognise'),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          }
        },
        onStatus: (status) {
          print('Speech status: $status');
        },
      );
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      print('Failed to initialize speech recognition: $e');
      _speechAvailable = false;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _pulseAnimationController.dispose();
    _speech.stop();
    _silenceTimer?.cancel();
    _autoCloseTimer?.cancel();
    super.dispose();
  }
  
  void _startSilenceTimer() {
    _silenceTimer?.cancel();
    _autoCloseTimer?.cancel();
    
    // Show "speak anything" after 3 seconds
    _silenceTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && _recognizedText.isEmpty && _isListening) {
        setState(() {
          _showSpeakPrompt = true;
        });
        
        // Auto-close after another 3 seconds if still nothing
        _autoCloseTimer = Timer(const Duration(seconds: 3), () {
          if (mounted && _recognizedText.isEmpty && _isListening) {
            Navigator.of(context).pop();
          }
        });
      }
    });
  }
  
  void _cancelTimers() {
    _silenceTimer?.cancel();
    _autoCloseTimer?.cancel();
  }

  Future<void> _showVoiceInputModal() async {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Check microphone permission
    var status = await Permission.microphone.status;
    if (!status.isGranted) {
      status = await Permission.microphone.request();
      if (!status.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Microphone permission is required for voice search'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        return;
      }
    }

    if (!_speechAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Speech recognition not available'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    setState(() {
      _isListening = true;
      _recognizedText = '';
      _showSpeakPrompt = false;
    });
    
    // Start the silence timer
    _startSilenceTimer();

    // Start listening
    await _speech.listen(
      onResult: (result) {
        setState(() {
          _recognizedText = result.recognizedWords;
          // Reset timers and hide prompt when user starts speaking
          if (_recognizedText.isNotEmpty) {
            _showSpeakPrompt = false;
            _cancelTimers();
          }
        });
        
        // Auto-close when final result is received
        if (result.finalResult && _recognizedText.isNotEmpty) {
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted && _isListening) {
              Navigator.of(context).pop();
            }
          });
        }
      },
      listenMode: stt.ListenMode.confirmation,
      pauseFor: const Duration(seconds: 3),
      listenFor: const Duration(seconds: 30),
    );

    await showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? theme.cardColor : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isDismissible: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Close button
                Align(
                  alignment: Alignment.topRight,
                  child: GestureDetector(
                    onTap: () async {
                      _cancelTimers();
                      await _speech.stop();
                      setState(() {
                        _isListening = false;
                        _showSpeakPrompt = false;
                      });
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[700] : Colors.grey.shade200,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close, 
                        size: 24,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                
                // Listening text
                Text(
                  _showSpeakPrompt ? "Please speak anything..." : "Hi, I'm listening...",
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: _showSpeakPrompt ? Colors.orange : theme.colorScheme.onSurface,
                    fontWeight: _showSpeakPrompt ? FontWeight.w600 : FontWeight.normal,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                
                // Recognized text display
                Text(
                  _recognizedText.isEmpty ? '""' : '"$_recognizedText"',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                
                // Animated mic icon
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulseAnimation.value,
                      child: Container(
                        height: 100,
                        width: 100,
                        decoration: BoxDecoration(
                          color: _showSpeakPrompt ? Colors.orange : theme.colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.mic,
                          color: theme.colorScheme.onPrimary,
                          size: 50,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 60),
              ],
            ),
          );
        },
      ),
    ).whenComplete(() async {
      _cancelTimers();
      await _speech.stop();
      setState(() {
        _isListening = false;
        _showSpeakPrompt = false;
      });
      
      // Update search bar with recognized text and show search modal
      if (_recognizedText.isNotEmpty) {
        _searchController.text = _recognizedText;
        await _showSearchModal(context);
      }
    });
  }

  Future<void> _showSearchModal(BuildContext context) async {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    await showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation1, animation2) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, -1),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation1,
            curve: Curves.easeOut,
          )),
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: isDark ? theme.scaffoldBackgroundColor : Colors.white,
              child: Column(
                children: [
                  SizedBox(height: MediaQuery.of(context).padding.top),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.arrow_back,
                            color: theme.colorScheme.onSurface,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            focusNode: _searchFocusNode,
                            autofocus: _searchController.text.isEmpty,
                            style: TextStyle(
                              color: theme.colorScheme.onSurface,
                            ),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: isDark ? theme.cardColor : const Color(0xFFEBF4F1),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide.none,
                              ),
                              hintText: "Search for restaurants, dishes...",
                              hintStyle: TextStyle(
                                color: theme.colorScheme.onSurface.withOpacity(0.6),
                              ),
                              contentPadding: const EdgeInsets.symmetric(vertical: 0),
                              prefixIcon: Icon(
                                Icons.search,
                                color: theme.colorScheme.onSurface.withOpacity(0.6),
                                size: 20,
                              ),
                              suffixIcon: _searchController.text.isNotEmpty
                                  ? IconButton(
                                      icon: Icon(
                                        Icons.close,
                                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                                      ),
                                      onPressed: () {
                                        _searchController.clear();
                                        setState(() {});
                                      },
                                    )
                                  : null,
                            ),
                            onChanged: (value) {
                              setState(() {});
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                            _showVoiceInputModal();
                          },
                          child: Container(
                            height: 46,
                            width: 46,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.mic_none,
                              color: theme.colorScheme.onPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(
                    height: 1,
                    color: isDark ? Colors.grey[700] : Colors.grey.shade300,
                  ),
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search, 
                            size: 30, 
                            color: theme.colorScheme.onSurface.withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _searchController.text.isEmpty 
                                ? 'Start typing to search...'
                                : 'Searching for "${_searchController.text}"',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Connect your data source to see results',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.4),
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
        );
      },
    );
    
    if (!_isListening) {
      _searchController.clear();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => _showSearchModal(context),
            child: AbsorbPointer(
              child: TextField(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: isDark ? theme.cardColor : const Color(0xFFEBF4F1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                  hintText: "Search...",
                  hintStyle: TextStyle(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  prefixIcon: Icon(
                    Icons.search,
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                    size: 25,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: _showVoiceInputModal,
          child: Container(
            height: 46,
            width: 46,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.mic_none,
              color: theme.colorScheme.onPrimary,
            ),
          ),
        ),
      ],
    );
  }
}