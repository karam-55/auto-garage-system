import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'constants/api_constants.dart';

class WebSocketService {
  WebSocketChannel? _channel;
  final List<void Function(Map<String, dynamic>)> _listeners = [];

  void connect() {
    try {
      String wsUrl = ApiConstants.wsUrl;
      // Ensure correct protocol
      if (wsUrl.startsWith('https://')) {
        wsUrl = wsUrl.replaceFirst('https://', 'wss://');
      } else if (wsUrl.startsWith('http://')) {
        wsUrl = wsUrl.replaceFirst('http://', 'ws://');
      }
      final uri = Uri.parse(wsUrl);
      _channel = WebSocketChannel.connect(uri);
      
      _channel!.stream.listen(
        (message) {
          final data = jsonDecode(message as String);
          for (final listener in _listeners) {
            listener(data as Map<String, dynamic>);
          }
        },
        onError: (error) {
          print('WebSocket error: $error');
        },
        onDone: () {
          print('WebSocket disconnected');
          _reconnect();
        },
      );
      print('WebSocket connected');
    } catch (e) {
      print('WebSocket connection failed: $e');
    }
  }

  void _reconnect() {
    Future.delayed(const Duration(seconds: 5), () {
      connect();
    });
  }

  void disconnect() {
    _channel?.sink.close();
    _channel = null;
  }

  void addListener(void Function(Map<String, dynamic>) listener) {
    _listeners.add(listener);
  }

  void removeListener(void Function(Map<String, dynamic>) listener) {
    _listeners.remove(listener);
  }
}

final webSocketService = WebSocketService();
