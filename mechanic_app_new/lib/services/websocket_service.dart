import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../core/constants/backend_constants.dart';

class WebSocketService extends ChangeNotifier {
  WebSocketChannel? _channel;
  bool _isConnected = false;
  Map<String, dynamic>? _lastBookingUpdate;

  bool get isConnected => _isConnected;
  Map<String, dynamic>? get lastBookingUpdate => _lastBookingUpdate;

  Future<void> connect({String? userId, String? role}) async {
    if (_isConnected) return;

    try {
      // Use ws:// for local, wss:// for production
      final protocol = BackendConstants.backendUrl.startsWith('https') ? 'wss' : 'ws';
      final wsUrl = BackendConstants.backendUrl.replaceFirst('http', protocol);
      
      _channel = WebSocketChannel.connect(Uri.parse('$wsUrl/ws'));
      
      // Send auth message
      if (userId != null || role != null) {
        _channel!.sink.add(jsonEncode({
          'type': 'auth',
          'userId': userId,
          'role': role,
        }));
      }

      _isConnected = true;
      notifyListeners();

      // Listen for messages
      _channel!.stream.listen(
        (message) {
          _handleMessage(message);
        },
        onError: (error) {
          print('WebSocket error: $error');
          _isConnected = false;
          notifyListeners();
        },
        onDone: () {
          print('WebSocket connection closed');
          _isConnected = false;
          notifyListeners();
        },
      );
    } catch (e) {
      print('WebSocket connection error: $e');
      _isConnected = false;
      notifyListeners();
    }
  }

  void _handleMessage(dynamic message) {
    try {
      final data = jsonDecode(message);
      if (data['type'] == 'booking_updated') {
        _lastBookingUpdate = data['data'];
        notifyListeners();
      }
    } catch (e) {
      print('Error parsing WebSocket message: $e');
    }
  }

  void disconnect() {
    _channel?.sink.close();
    _channel = null;
    _isConnected = false;
    _lastBookingUpdate = null;
    notifyListeners();
  }

  @override
  void dispose() {
    disconnect();
    super.dispose();
  }
}
