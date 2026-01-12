// lib/providers/chat_provider.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:veegify/model/ChatModel/chat_message.dart';

class ChatProvider extends ChangeNotifier {
  final String deliveryBoyId;
  final String userId;
  final bool usePollingFallback; // keep optional fallback
  final Duration pollingInterval;

  List<ChatMessage> _messages = [];
  bool _loading = false;
  Timer? _pollTimer;

  IO.Socket? _socket;
  bool _connected = false;

  List<ChatMessage> get messages => _messages;
  bool get loading => _loading;
  bool get socketConnected => _connected;

  ChatProvider({
    required this.deliveryBoyId,
    required this.userId,
    this.usePollingFallback = true,
    this.pollingInterval = const Duration(seconds: 3),
  }) {
    _init();
  }

  void _init() {
    // load initial history via HTTP
    fetchMessages();

    // connect socket
    _connectSocket();

    // optional polling fallback in case socket isn't connected
    if (usePollingFallback) {
      _pollTimer = Timer.periodic(pollingInterval, (_) {
        if (!_connected) fetchMessages(); // only poll if socket disconnected
      });
    }
  }

  // --- HTTP fetch (as fallback or initial)
  Future<void> fetchMessages() async {
    _loading = true;
    notifyListeners();

    try {
      print("kkkkkkkkkkkkkkkkkkkkkkkkrrrrererkkkkkkkk$deliveryBoyId");
            print("kkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkk$userId");

      final url = Uri.parse('https://api.vegiffyy.com/api/getchat/$deliveryBoyId/$userId');
            print("uuuuuuuuuuu$url");

      final resp = await http.get(url).timeout(const Duration(seconds: 10));
      if (resp.statusCode == 200) {
        final body = json.decode(resp.body);
        if (body is Map && body['success'] == true && body['messages'] is List) {
          final List raw = body['messages'] as List;
          _messages = raw.map((e) => ChatMessage.fromJson(e as Map<String, dynamic>)).toList();
          _messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
        }
      }
    } catch (e) {
      // ignore network errors; socket may be live
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // --- Send message: uses HTTP to persist (server then emits to socket room).
  // We also optimistically add message locally with a temporary id so UI updates instantly.
  Future<bool> sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return false;

    final tempMsg = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(), // temp id
      deliveryBoyId: deliveryBoyId,
      userId: userId,
      senderType: 'user',
      message: trimmed,
      timestamp: DateTime.now(),
    );

    // optimistic add
    _messages.add(tempMsg);
    _messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    notifyListeners();
    _scrollToBottomHelper();

    // 1) POST to server to save message -> server will emit to room
    final url = Uri.parse('https://api.vegiffyy.com/api/sendchat/$deliveryBoyId/$userId');
    try {
      final body = json.encode({'message': trimmed, 'senderType': 'user'});
      final resp = await http.post(url, headers: {'Content-Type': 'application/json'}, body: body).timeout(const Duration(seconds: 10));
      if (resp.statusCode == 201 || resp.statusCode == 200) {
        final parsed = json.decode(resp.body);
        if (parsed is Map && parsed['success'] == true && parsed['message'] is Map) {
          final serverMsg = ChatMessage.fromJson(parsed['message'] as Map<String, dynamic>);
          // replace temp message with server message (match by timestamp or temp id)
          // we'll try to remove temp by timestamp closeness
          _replaceTempMessage(tempMsg, serverMsg);
          notifyListeners();
          _scrollToBottomHelper();
          return true;
        } else {
          // server returned OK but different shape: re-fetch
          await fetchMessages();
          return true;
        }
      } else {
        // failed - remove optimistic message
        _messages.removeWhere((m) => m.id == tempMsg.id);
        notifyListeners();
        return false;
      }
    } catch (e) {
      // network error - keep optimistic message but mark unsent (optional)
      // For simplicity we leave it and schedule a resend later or rely on polling
      return false;
    } finally {
      // also emit a socket event locally (optional) so other clients that rely on socket-only can pick it up if server doesn't handle POST->emit
      if (_socket?.connected == true) {
        _socket?.emit('sendMessage', {
          'deliveryBoyId': deliveryBoyId,
          'userId': userId,
          'senderType': 'user',
          'message': trimmed,
          'timestamp': DateTime.now().toIso8601String(),
        });
      }
    }
  }

  void _replaceTempMessage(ChatMessage temp, ChatMessage serverMsg) {
    final idx = _messages.indexWhere((m) => m.id == temp.id);
    if (idx != -1) {
      _messages[idx] = serverMsg;
    } else {
      // fallback: append if not found
      _messages.add(serverMsg);
    }
    _messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }

  // --- Socket connection
  void _connectSocket() {
    try {
      // Use the same host as server; socket endpoint usually same origin.
      // Use 'http' scheme for non-ssl. For wss/https use 'https://...'
      const serverUrl = 'http://31.97.206.144:5050'; // adjust port if socket server runs on different port (server.listen used 5050 in your code)
      _socket = IO.io(
        serverUrl,
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .enableReconnection()
            .enableForceNew()
            .setQuery({'deliveryBoyId': deliveryBoyId, 'userId': userId})
            .build(),
      );

      _socket?.on('connect', (_) {
        _connected = true;
        notifyListeners();
        // join the specific chat room on server side
        _socket?.emit('joinChat', {'deliveryBoyId': deliveryBoyId, 'userId': userId});
        // join location room if you later want
        _socket?.emit('joinDeliveryBoyTracking', deliveryBoyId);

        // optionally request chat history from socket
        // server code emits 'chatHistory' on get route - but we can also listen to history events
      });

      _socket?.on('disconnect', (_) {
        _connected = false;
        notifyListeners();
      });

      // Listen for a single new message emitted by the server
      _socket?.on('receiveMessage', (data) {
        try {
          if (data is Map<String, dynamic>) {
            final msg = ChatMessage.fromJson(Map<String, dynamic>.from(data));
            _maybeAddMessage(msg);
          } else if (data is Map) {
            final Map m = data;
            final converted = Map<String, dynamic>.from(m);
            final msg = ChatMessage.fromJson(converted);
            _maybeAddMessage(msg);
          } else if (data is String) {
            // sometimes socket gives JSON string
            final parsed = json.decode(data);
            if (parsed is Map) {
              final msg = ChatMessage.fromJson(Map<String, dynamic>.from(parsed));
              _maybeAddMessage(msg);
            }
          }
        } catch (_) {}
      });

      // Chat history event (server emits chatHistory in server code)
      _socket?.on('chatHistory', (payload) {
        try {
          if (payload is List) {
            final list = payload.map((e) {
              if (e is Map) {
                return ChatMessage.fromJson(Map<String, dynamic>.from(e));
              } else if (e is String) {
                return ChatMessage.fromJson(Map<String, dynamic>.from(json.decode(e)));
              }
              return null;
            }).whereType<ChatMessage>().toList();

            _messages = list;
            _messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
            notifyListeners();
            _scrollToBottomHelper();
          }
        } catch (_) {}
      });

      // optional test event
      _socket?.on('testEvent', (d) {
        // keep for debugging
      });

      // error handler
      _socket?.on('error', (err) {
        // handle socket errors
      });
    } catch (e) {
      // socket init failed
      _connected = false;
      notifyListeners();
    }
  }

  // add message only if not duplicate (matching server id)
  void _maybeAddMessage(ChatMessage msg) {
    final exists = _messages.any((m) => m.id == msg.id);
    if (!exists) {
      _messages.add(msg);
      _messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      notifyListeners();
      _scrollToBottomHelper();
    } else {
      // optionally update existing (replace)
      final idx = _messages.indexWhere((m) => m.id == msg.id);
      if (idx != -1) {
        _messages[idx] = msg;
        notifyListeners();
      }
    }
  }

  // helper to scroll UI - we call via a short-lived callback the UI can listen to (see below)
  VoidCallback? _scrollCallback;
  void setScrollCallback(VoidCallback cb) => _scrollCallback = cb;
  void _scrollToBottomHelper() {
    if (_scrollCallback != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollCallback!());
    }
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    try {
      _socket?.disconnect();
      _socket?.dispose();
    } catch (_) {}
    super.dispose();
  }
}
