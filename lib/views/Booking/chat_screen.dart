
// // lib/screens/chat_screen.dart
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:provider/provider.dart';
// import 'package:veegify/model/ChatModel/chat_message.dart';
// import 'package:veegify/provider/ChatProvider/chat_provider.dart';

// class ChatScreen extends StatefulWidget {
//   final String deliveryBoyId;
//   final String userId;
//   final String title;
//   const ChatScreen({
//     Key? key,
//     required this.deliveryBoyId,
//     required this.userId,
//     this.title = 'Chat',
//   }) : super(key: key);

//   @override
//   State<ChatScreen> createState() => _ChatScreenState();
// }

// class _ChatScreenState extends State<ChatScreen> {
//   final TextEditingController _controller = TextEditingController();
//   final ScrollController _scroll = ScrollController();
//   bool _sending = false;

//   @override
//   void initState() {
//     super.initState();
//     // set scroll callback after provider is created (post frame)
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       final prov = Provider.of<ChatProvider>(context, listen: false);
//       prov.setScrollCallback(() {
//         if (_scroll.hasClients) {
//           _scroll.animateTo(_scroll.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
//         }
//       });
//     });
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     _scroll.dispose();
//     super.dispose();
//   }

//   void _scrollToBottom() {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (_scroll.hasClients) {
//         _scroll.animateTo(_scroll.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
//       }
//     });
//   }

//   Future<void> _onSend(ChatProvider provider) async {
//     final text = _controller.text;
//     if (text.trim().isEmpty) return;
//     setState(() => _sending = true);
//     final ok = await provider.sendMessage(text);
//     setState(() => _sending = false);
//     if (ok) {
//       _controller.clear();
//       _scrollToBottom();
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: const Text('Failed to send message'),
//           behavior: SnackBarBehavior.floating,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//         ),
//       );
//     }
//   }

//   Widget _buildBubble(ChatMessage msg, ThemeData theme, bool isDark) {
//     final isUser = msg.senderType.toLowerCase() != 'rider';
//     final alignment = isUser ? MainAxisAlignment.end : MainAxisAlignment.start;
//     final bg = isUser 
//         ? theme.colorScheme.primary.withOpacity(0.1)
//         : isDark 
//             ? Colors.grey[700] 
//             : Colors.grey.shade200;
//     final textColor = isUser 
//         ? theme.colorScheme.onPrimary.withOpacity(0.9)
//         : theme.colorScheme.onSurface;
//     final timeColor = isUser 
//         ? theme.colorScheme.onPrimary.withOpacity(0.7)
//         : theme.colorScheme.onSurface.withOpacity(0.6);
    
//     final radius = BorderRadius.only(
//       topLeft: const Radius.circular(12),
//       topRight: const Radius.circular(12),
//       bottomLeft: Radius.circular(isUser ? 12 : 0),
//       bottomRight: Radius.circular(isUser ? 0 : 12),
//     );
    
//     final time = DateFormat('hh:mm a').format(msg.timestamp);
    
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
//       child: Row(
//         mainAxisAlignment: alignment,
//         children: [
//           Flexible(
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
//               decoration: BoxDecoration(
//                 color: bg, 
//                 borderRadius: radius,
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.end,
//                 children: [
//                   Text(
//                     msg.message, 
//                     style: TextStyle(
//                       color: textColor, 
//                       fontSize: 15
//                     )
//                   ),
//                   const SizedBox(height: 6),
//                   Text(
//                     time, 
//                     style: TextStyle(
//                       color: timeColor, 
//                       fontSize: 11
//                     )
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final isDark = theme.brightness == Brightness.dark;
    
//     print("fldskfhjkfdsklfhldfhdslkfhdslfhjdslfhjdsfh${widget.deliveryBoyId}");
    
//     return ChangeNotifierProvider<ChatProvider>(
//       create: (_) => ChatProvider(
//         deliveryBoyId: widget.deliveryBoyId, 
//         userId: widget.userId, 
//         usePollingFallback: true
//       ),
//       child: Consumer<ChatProvider>(builder: (context, provider, _) {
//         // scroll to bottom when messages change
//         WidgetsBinding.instance.addPostFrameCallback((_) {
//           if (provider.messages.isNotEmpty) _scrollToBottom();
//         });

//         return Scaffold(
//           backgroundColor: theme.scaffoldBackgroundColor,
//           appBar: AppBar(
//             elevation: 0,
//             backgroundColor: isDark ? theme.cardColor : Colors.white,
//             leading: IconButton(
//               icon: Icon(
//                 Icons.arrow_back, 
//                 color: theme.colorScheme.onSurface
//               ), 
//               onPressed: () => Navigator.of(context).maybePop()
//             ),
//             title: Row(
//               children: [
//                 CircleAvatar(
//                   radius: 16, 
//                   backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
//                   child: Icon(
//                     Icons.person, 
//                     color: theme.colorScheme.primary,
//                     size: 18,
//                   )
//                 ),
//                 const SizedBox(width: 10),
//                 Text(
//                   widget.title, 
//                   style: TextStyle(
//                     color: theme.colorScheme.onSurface
//                   )
//                 ),
//                 const SizedBox(width: 8),
//                 if (provider.socketConnected)
//                   Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), 
//                     decoration: BoxDecoration(
//                       color: theme.colorScheme.primary.withOpacity(0.1), 
//                       borderRadius: BorderRadius.circular(12)
//                     ), 
//                     child: Text(
//                       'Live', 
//                       style: TextStyle(
//                         color: theme.colorScheme.primary, 
//                         fontSize: 12,
//                         fontWeight: FontWeight.w500,
//                       )
//                     )
//                   ),
//               ],
//             ),
//           ),
//           body: SafeArea(
//             child: Column(
//               children: [
//                 Expanded(
//                   child: provider.loading && provider.messages.isEmpty
//                       ? Center(
//                           child: CircularProgressIndicator(
//                             color: theme.colorScheme.primary,
//                           ),
//                         )
//                       : ListView.builder(
//                           controller: _scroll,
//                           padding: const EdgeInsets.only(top: 12, bottom: 12),
//                           itemCount: provider.messages.length,
//                           itemBuilder: (context, index) {
//                             final msg = provider.messages[index];
//                             return _buildBubble(msg, theme, isDark);
//                           },
//                         ),
//                 ),

//                 // Input area
//                 Container(
//                   decoration: BoxDecoration(
//                     color: isDark ? theme.cardColor : Colors.white, 
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.1), 
//                         blurRadius: 6, 
//                         offset: const Offset(0, -1)
//                       )
//                     ]
//                   ),
//                   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                   child: Row(
//                     children: [
//                       Expanded(
//                         child: TextField(
//                           controller: _controller,
//                           textInputAction: TextInputAction.send,
//                           onSubmitted: (_) => _onSend(provider),
//                           style: TextStyle(
//                             color: theme.colorScheme.onSurface,
//                           ),
//                           decoration: InputDecoration(
//                             hintText: 'Text here',
//                             hintStyle: TextStyle(
//                               color: theme.colorScheme.onSurface.withOpacity(0.6),
//                             ),
//                             contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(30), 
//                               borderSide: BorderSide.none
//                             ),
//                             filled: true,
//                             fillColor: isDark ? Colors.grey[800] : Colors.grey[100],
//                           ),
//                         ),
//                       ),
//                       const SizedBox(width: 8),
//                       FloatingActionButton(
//                         mini: true,
//                         onPressed: _sending ? null : () => _onSend(provider),
//                         backgroundColor: _sending 
//                             ? theme.colorScheme.onSurface.withOpacity(0.3)
//                             : theme.colorScheme.primary,
//                         child: _sending 
//                             ? SizedBox(
//                                 width: 20, 
//                                 height: 20, 
//                                 child: CircularProgressIndicator(
//                                   color: theme.colorScheme.onPrimary,
//                                   strokeWidth: 2
//                                 )
//                               ) 
//                             : Icon(
//                                 Icons.send, 
//                                 color: theme.colorScheme.onPrimary
//                               ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       }),
//     );
//   }
// }












// lib/screens/chat_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:veegify/model/ChatModel/chat_message.dart';
import 'package:veegify/provider/ChatProvider/chat_provider.dart';

class ChatScreen extends StatefulWidget {
  final String deliveryBoyId;
  final String userId;
  final String title;
  const ChatScreen({
    Key? key,
    required this.deliveryBoyId,
    required this.userId,
    this.title = 'Chat',
  }) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scroll = ScrollController();
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    // set scroll callback after provider is created (post frame)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final prov = Provider.of<ChatProvider>(context, listen: false);
      prov.setScrollCallback(() {
        if (_scroll.hasClients) {
          _scroll.animateTo(
            _scroll.position.maxScrollExtent, 
            duration: const Duration(milliseconds: 300), 
            curve: Curves.easeOut
          );
        }
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent, 
          duration: const Duration(milliseconds: 300), 
          curve: Curves.easeOut
        );
      }
    });
  }

  Future<void> _onSend(ChatProvider provider) async {
    final text = _controller.text;
    if (text.trim().isEmpty) return;
    setState(() => _sending = true);
    final ok = await provider.sendMessage(text);
    setState(() => _sending = false);
    if (ok) {
      _controller.clear();
      _scrollToBottom();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Failed to send message'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  Widget _buildBubble(ChatMessage msg, ThemeData theme, bool isDark) {
    final isUser = msg.senderType.toLowerCase() != 'rider';
    final alignment = isUser ? MainAxisAlignment.end : MainAxisAlignment.start;
    
    // Colors for user messages
    final userBgColor = theme.colorScheme.primary;
    final userTextColor = theme.colorScheme.onPrimary;
    final userTimeColor = theme.colorScheme.onPrimary.withOpacity(0.7);
    
    // Colors for rider messages based on theme
    final riderBgColor = isDark 
        ? theme.colorScheme.surfaceVariant 
        : Colors.grey.shade200;
    final riderTextColor = theme.colorScheme.onSurface;
    final riderTimeColor = theme.colorScheme.onSurface.withOpacity(0.6);
    
    // Select colors based on sender
    final bgColor = isUser ? userBgColor : riderBgColor;
    final textColor = isUser ? userTextColor : riderTextColor;
    final timeColor = isUser ? userTimeColor : riderTimeColor;
    
    final radius = BorderRadius.only(
      topLeft: const Radius.circular(16),
      topRight: const Radius.circular(16),
      bottomLeft: Radius.circular(isUser ? 16 : 4),
      bottomRight: Radius.circular(isUser ? 4 : 16),
    );
    
    final time = DateFormat('hh:mm a').format(msg.timestamp);
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      child: Row(
        mainAxisAlignment: alignment,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            // Rider avatar for incoming messages
            CircleAvatar(
              radius: 16,
              backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
              child: Icon(
                Icons.person_outline,
                size: 16,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: bgColor, 
                borderRadius: radius,
                boxShadow: [
                  if (!isDark)
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    msg.message, 
                    style: TextStyle(
                      color: textColor, 
                      fontSize: 15,
                      height: 1.3,
                    )
                  ),
                  const SizedBox(height: 4),
                  Text(
                    time, 
                    style: TextStyle(
                      color: timeColor, 
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                    )
                  ),
                ],
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            // User avatar for outgoing messages
            CircleAvatar(
              radius: 16,
              backgroundColor: theme.colorScheme.primary,
              child: Icon(
                Icons.person,
                size: 16,
                color: theme.colorScheme.onPrimary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLoadingState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'Loading messages...',
            style: TextStyle(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.chat_bubble_outline,
              size: 48,
              color: theme.colorScheme.primary.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No messages yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Send a message to start chatting',
            style: TextStyle(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    
    print("Chat Screen - DeliveryBoyId: ${widget.deliveryBoyId}");
    
    return ChangeNotifierProvider<ChatProvider>(
      create: (_) => ChatProvider(
        deliveryBoyId: widget.deliveryBoyId, 
        userId: widget.userId, 
        usePollingFallback: true
      ),
      child: Consumer<ChatProvider>(builder: (context, provider, _) {
        // scroll to bottom when messages change
        if (provider.messages.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scrollToBottom();
          });
        }

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: theme.appBarTheme.backgroundColor ?? 
                (isDark ? theme.cardColor : Colors.white),
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new,
                color: colorScheme.onSurface,
              ), 
              onPressed: () => Navigator.of(context).maybePop()
            ),
            title: Row(
              children: [
                // Container(
                //   decoration: BoxDecoration(
                //     shape: BoxShape.circle,
                //     border: Border.all(
                //       color: colorScheme.primary.withOpacity(0.3),
                //       width: 2,
                //     ),
                //   ),
                //   child: CircleAvatar(
                //     radius: 18,
                //     backgroundColor: colorScheme.primary.withOpacity(0.1),
                //     backgroundImage: provider. != null
                //         ? NetworkImage(provider.riderImage!)
                //         : null,
                //     child: provider.riderImage == null
                //         ? Icon(
                //             Icons.person,
                //             color: colorScheme.primary,
                //             size: 20,
                //           )
                //         : null,
                //   ),
                // ),
                // const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: TextStyle(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          // Container(
                          //   width: 8,
                          //   height: 8,
                          //   decoration: BoxDecoration(
                          //     color: provider.socketConnected 
                          //         ? Colors.green 
                          //         : Colors.grey,
                          //     shape: BoxShape.circle,
                          //   ),
                          // ),
                          // const SizedBox(width: 6),
                          // Text(
                          //   provider.socketConnected ? 'Online' : 'Offline',
                          //   style: TextStyle(
                          //     color: colorScheme.onSurface.withOpacity(0.6),
                          //     fontSize: 12,
                          //   ),
                          // ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (provider.socketConnected)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: colorScheme.primary.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.circle,
                          color: Colors.green,
                          size: 8,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Live',
                          style: TextStyle(
                            color: colorScheme.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: provider.loading && provider.messages.isEmpty
                      ? _buildLoadingState(theme)
                      : provider.messages.isEmpty
                          ? _buildEmptyState(theme)
                          : Container(
                              color: isDark 
                                  ? colorScheme.background 
                                  : Colors.grey.shade50,
                              child: ListView.builder(
                                controller: _scroll,
                                padding: const EdgeInsets.only(
                                  top: 16, 
                                  bottom: 16,
                                ),
                                itemCount: provider.messages.length,
                                itemBuilder: (context, index) {
                                  final msg = provider.messages[index];
                                  return _buildBubble(msg, theme, isDark);
                                },
                              ),
                            ),
                ),

                // Typing indicator
                // if (provider.isTyping)
                //   Container(
                //     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                //     child: Row(
                //       children: [
                //         CircleAvatar(
                //           radius: 12,
                //           backgroundColor: colorScheme.primary.withOpacity(0.1),
                //           child: Icon(
                //             Icons.person,
                //             size: 12,
                //             color: colorScheme.primary,
                //           ),
                //         ),
                //         const SizedBox(width: 8),
                //         Container(
                //           padding: const EdgeInsets.symmetric(
                //             horizontal: 12,
                //             vertical: 6,
                //           ),
                //           decoration: BoxDecoration(
                //             color: isDark 
                //                 ? colorScheme.surfaceVariant 
                //                 : Colors.grey.shade200,
                //             borderRadius: BorderRadius.circular(20),
                //           ),
                //           child: Row(
                //             mainAxisSize: MainAxisSize.min,
                //             children: [
                //               _buildTypingDot(theme, 0),
                //               _buildTypingDot(theme, 1),
                //               _buildTypingDot(theme, 2),
                //             ],
                //           ),
                //         ),
                //       ],
                //     ),
                //   ),

                // Input area
                Container(
                  decoration: BoxDecoration(
                    color: theme.bottomAppBarTheme.color ?? 
                        (isDark ? theme.cardColor : Colors.white),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Attachment button (optional)
                      // IconButton(
                      //   icon: Icon(
                      //     Icons.attach_file,
                      //     color: colorScheme.onSurface.withOpacity(0.6),
                      //   ),
                      //   onPressed: () {
                      //     // TODO: Add attachment functionality
                      //   },
                      // ),
                      // const SizedBox(width: 4),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: isDark 
                                ? colorScheme.surfaceVariant 
                                : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: TextField(
                            controller: _controller,
                            textInputAction: TextInputAction.send,
                            onSubmitted: (_) => _onSend(provider),
                            maxLines: null,
                            keyboardType: TextInputType.multiline,
                            style: TextStyle(
                              color: colorScheme.onSurface,
                              fontSize: 15,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Type a message...',
                              hintStyle: TextStyle(
                                color: colorScheme.onSurface.withOpacity(0.5),
                                fontSize: 15,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Send button
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        child: FloatingActionButton(
                          mini: true,
                          onPressed: _sending || !provider.socketConnected 
                              ? null 
                              : () => _onSend(provider),
                          backgroundColor: _sending
                              ? colorScheme.onSurface.withOpacity(0.1)
                              : colorScheme.primary,
                          elevation: _sending ? 0 : 2,
                          child: _sending
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: colorScheme.primary,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Icon(
                                  Icons.send,
                                  color: _sending
                                      ? colorScheme.onSurface.withOpacity(0.3)
                                      : colorScheme.onPrimary,
                                  size: 18,
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildTypingDot(ThemeData theme, int index) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        color: theme.colorScheme.onSurface.withOpacity(0.5),
        shape: BoxShape.circle,
      ),
      child: Center(),
    );
  }
}