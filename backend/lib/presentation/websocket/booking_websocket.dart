import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_web_socket/shelf_web_socket.dart';
import '../../domain/repositories/alert_repository.dart';

class BookingWebSocket {
  final AlertRepository _alertRepository;
  final Set<dynamic> _connections = {};

  BookingWebSocket(this._alertRepository);

  Handler get handler {
    return webSocketHandler((webSocket, protocol) {
      _connections.add(webSocket);
      
      webSocket.stream.listen(
        (message) {
          // Handle incoming messages
        },
        onDone: () {
          _connections.remove(webSocket);
        },
        onError: (error) {
          _connections.remove(webSocket);
        },
      );
    });
  }

  Future<void> broadcastAlert(Map<String, dynamic> alert) async {
    final message = jsonEncode(alert);
    for (final connection in _connections) {
      try {
        connection.sink.add(message);
      } catch (e) {
        _connections.remove(connection);
      }
    }
  }

  Future<void> broadcastLowStockAlert(String itemId, String itemName, String variantType, int quantity) async {
    final alert = {
      'type': 'LOW_STOCK',
      'itemId': itemId,
      'itemName': itemName,
      'variantType': variantType,
      'quantity': quantity,
      'message': 'تنبيه: $itemName ($variantType) وصل للحد الأدنى ($quantity)',
      'timestamp': DateTime.now().toIso8601String(),
    };
    await broadcastAlert(alert);
  }
}
