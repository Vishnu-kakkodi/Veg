import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:veegify/views/home/detail_screen.dart';

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

  // Search debouncer and results
  Timer? _debounceTimer;
  bool _isSearching = false;
  List<dynamic> _searchResults = [];

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
    _debounceTimer?.cancel();
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

  // Search API call with debouncer
  void _performSearch(String query) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();

    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      try {
        final response = await http.get(
          Uri.parse('https://api.vegiffyy.com/api/searchpro?search=$query'),
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (mounted) {
            setState(() {
              _searchResults = data['data'] ?? [];
              _isSearching = false;
            });
          }
        } else {
          if (mounted) {
            setState(() {
              _searchResults = [];
              _isSearching = false;
            });
          }
        }
      } catch (e) {
        print('Search error: $e');
        if (mounted) {
          setState(() {
            _searchResults = [];
            _isSearching = false;
          });
        }
      }
    });
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
            content: const Text(
                'Microphone permission is required for voice search'),
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
                  _showSpeakPrompt
                      ? "Please speak anything..."
                      : "Hi, I'm listening...",
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: _showSpeakPrompt
                        ? Colors.orange
                        : theme.colorScheme.onSurface,
                    fontWeight:
                        _showSpeakPrompt ? FontWeight.w600 : FontWeight.normal,
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
                          color: _showSpeakPrompt
                              ? Colors.orange
                              : theme.colorScheme.primary,
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

    // Perform initial search if there's text
    if (_searchController.text.isNotEmpty) {
      _performSearch(_searchController.text);
    }

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
                              fillColor: isDark
                                  ? theme.cardColor
                                  : const Color(0xFFEBF4F1),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide.none,
                              ),
                              hintText: "Search for restaurants, dishes...",
                              hintStyle: TextStyle(
                                color: theme.colorScheme.onSurface
                                    .withOpacity(0.6),
                              ),
                              contentPadding:
                                  const EdgeInsets.symmetric(vertical: 0),
                              prefixIcon: Icon(
                                Icons.search,
                                color: theme.colorScheme.onSurface
                                    .withOpacity(0.6),
                                size: 20,
                              ),
                              suffixIcon: _searchController.text.isNotEmpty
                                  ? IconButton(
                                      icon: Icon(
                                        Icons.close,
                                        color: theme.colorScheme.onSurface
                                            .withOpacity(0.6),
                                      ),
                                      onPressed: () {
                                        _searchController.clear();
                                        setState(() {
                                          _searchResults = [];
                                        });
                                      },
                                    )
                                  : null,
                            ),
                            onChanged: (value) {
                              setState(() {});
                              _performSearch(value);
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
                    child: _isSearching
                        ? const Center(child: CircularProgressIndicator())
                        : _searchResults.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.search,
                                      size: 30,
                                      color: theme.colorScheme.onSurface
                                          .withOpacity(0.5),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      _searchController.text.isEmpty
                                          ? 'Start typing to search...'
                                          : 'No results found for "${_searchController.text}"',
                                      style:
                                          theme.textTheme.bodyLarge?.copyWith(
                                        color: theme.colorScheme.onSurface
                                            .withOpacity(0.6),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: _searchResults.length,
                                itemBuilder: (context, index) {
                                  final result = _searchResults[index];
                                  final restaurant = result['restaurant'];
                                  final products = result['products'] as List;

                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (index > 0) const SizedBox(height: 24),
                                      // Restaurant header
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 12),
                                        child: Row(
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              child: Image.network(
                                                restaurant['image']['url'],
                                                width: 50,
                                                height: 50,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error,
                                                    stackTrace) {
                                                  return Container(
                                                    width: 50,
                                                    height: 50,
                                                    color: Colors.grey[300],
                                                    child: const Icon(
                                                        Icons.restaurant),
                                                  );
                                                },
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    restaurant[
                                                        'restaurantName'],
                                                    style: theme
                                                        .textTheme.titleMedium
                                                        ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Row(
                                                    children: [
                                                      Icon(
                                                        Icons.star,
                                                        size: 16,
                                                        color: Colors.amber,
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        restaurant['rating']
                                                            .toString(),
                                                        style: theme.textTheme
                                                            .bodySmall,
                                                      ),
                                                      const SizedBox(width: 8),
                                                      Text(
                                                        '• ${restaurant['locationName']}',
                                                        style: theme
                                                            .textTheme.bodySmall
                                                            ?.copyWith(
                                                          color: theme
                                                              .colorScheme
                                                              .onSurface
                                                              .withOpacity(0.6),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      // Products
                                      ...products.map((product) {
                                        final recommended =
                                            product['recommended'] as List;
                                        return Column(
                                          children: recommended.map((item) {
                                            return GestureDetector(
                                              onTap: () {
                                                // Navigate to detail screen
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        DetailScreen(
                                                      productId: item['_id'],
                                                      currentUserId:
                                                          '68ef35a7447e0771c2b4aac4', // Replace with actual current user ID
                                                      restaurantId:
                                                          restaurant['_id'],
                                                    ),
                                                  ),
                                                );
                                              },
                                              child: Container(
                                                margin: const EdgeInsets.only(
                                                    bottom: 12),
                                                padding:
                                                    const EdgeInsets.all(12),
                                                decoration: BoxDecoration(
                                                  color: isDark
                                                      ? theme.cardColor
                                                      : Colors.grey[100],
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                child: Row(
                                                  children: [
                                                    ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                      child: Image.network(
                                                        item['image'],
                                                        width: 80,
                                                        height: 80,
                                                        fit: BoxFit.cover,
                                                        errorBuilder: (context,
                                                            error, stackTrace) {
                                                          return Container(
                                                            width: 80,
                                                            height: 80,
                                                            color: Colors
                                                                .grey[300],
                                                            child: const Icon(
                                                                Icons.fastfood),
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                    const SizedBox(width: 12),
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            item['name'],
                                                            style: theme
                                                                .textTheme
                                                                .titleSmall
                                                                ?.copyWith(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              height: 4),
                                                          Text(
                                                            item['content'] ??
                                                                '',
                                                            style: theme
                                                                .textTheme
                                                                .bodySmall
                                                                ?.copyWith(
                                                              color: theme
                                                                  .colorScheme
                                                                  .onSurface
                                                                  .withOpacity(
                                                                      0.6),
                                                            ),
                                                            maxLines: 2,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                          const SizedBox(
                                                              height: 8),
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              Row(
                                                                children: [
                                                                  Text(
                                                                    '₹${item['price']}',
                                                                    style: theme
                                                                        .textTheme
                                                                        .titleMedium
                                                                        ?.copyWith(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      color: theme
                                                                          .colorScheme
                                                                          .primary,
                                                                    ),
                                                                  ),
                                                                  if (item[
                                                                          'discount'] >
                                                                      0) ...[
                                                                    const SizedBox(
                                                                        width:
                                                                            8),
                                                                    Container(
                                                                      padding:
                                                                          const EdgeInsets
                                                                              .symmetric(
                                                                        horizontal:
                                                                            6,
                                                                        vertical:
                                                                            2,
                                                                      ),
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        color: Colors
                                                                            .green,
                                                                        borderRadius:
                                                                            BorderRadius.circular(4),
                                                                      ),
                                                                      child:
                                                                          Text(
                                                                        '${item['discount']}% OFF',
                                                                        style:
                                                                            const TextStyle(
                                                                          color:
                                                                              Colors.white,
                                                                          fontSize:
                                                                              10,
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ],
                                                              ),
                                                              if (item['reviews'] !=
                                                                      null &&
                                                                  (item['reviews']
                                                                          as List)
                                                                      .isNotEmpty)
                                                                Row(
                                                                  children: [
                                                                    const Icon(
                                                                      Icons
                                                                          .star,
                                                                      size: 14,
                                                                      color: Colors
                                                                          .amber,
                                                                    ),
                                                                    const SizedBox(
                                                                        width:
                                                                            4),
                                                                    Text(
                                                                      item['reviews'][0]
                                                                              [
                                                                              'stars']
                                                                          .toString(),
                                                                      style: theme
                                                                          .textTheme
                                                                          .bodySmall,
                                                                    ),
                                                                  ],
                                                                ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                        );
                                      }).toList(),
                                    ],
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
    );

    if (!_isListening) {
      _searchController.clear();
      setState(() {
        _searchResults = [];
      });
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
                  // fillColor: isDark ? theme.cardColor : const Color(0xFFEBF4F1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    // borderSide: BorderSide(
                    //   color: Colors.black, // 👈 border color
                    // ),
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
        // const SizedBox(width: 10),
        // GestureDetector(
        //   onTap: _showVoiceInputModal,
        //   child: Container(
        //     height: 46,
        //     width: 46,
        //     decoration: BoxDecoration(
        //       color: theme.colorScheme.primary,
        //       shape: BoxShape.circle,
        //     ),
        //     child: Icon(
        //       Icons.mic_none,
        //       color: theme.colorScheme.onPrimary,
        //     ),
        //   ),
        // ),
      ],
    );
  }
}
