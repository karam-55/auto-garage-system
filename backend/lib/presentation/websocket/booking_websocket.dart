import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_web_socket/shelf_web_socket.dart';

class BookingWebSocket {
  Handler get handler {
    return webSocketHandler((WebSocketChannel channel, String? protocol) {
      channel.stream.listen((message) {
        // Handle incoming messages
        print('WebSocket message: $message');
      });
    });
  }
}
