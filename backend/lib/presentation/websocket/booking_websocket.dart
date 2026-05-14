import 'dart:convert';
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class BookingWebSocketHandler {
  final Map<WebSocketChannel, Map<String, String>> _connections = {};
  
  // Add a new connection with user info
  void addConnection(WebSocketChannel channel, String? userId, String? role) {
    _connections[channel] = {
      'userId': userId ?? '',
      'role': role ?? '',
    };
    
    print('WebSocket connection added. Total connections: ${_connections.length}');
  }
  
  // Remove a connection
  void removeConnection(WebSocketChannel channel) {
    _connections.remove(channel);
    print('WebSocket connection removed. Total connections: ${_connections.length}');
  }
  
  // Broadcast booking update to all connected clients
  void broadcastBookingUpdate(Map<String, dynamic> booking) {
    final message = jsonEncode({
      'type': 'booking_updated',
      'data': booking,
    });
    
    print('Broadcasting booking update to ${_connections.length} connections');
    
    for (final channel in _connections.keys) {
      try {
        channel.sink.add(message);
      } catch (e) {
        print('Error sending to channel: $e');
        removeConnection(channel);
      }
    }
  }
  
  // Broadcast to specific role (e.g., only mechanics or only admins)
  void broadcastToRole(String role, Map<String, dynamic> booking) {
    final message = jsonEncode({
      'type': 'booking_updated',
      'data': booking,
    });
    
    print('Broadcasting to role: $role');
    
    for (final entry in _connections.entries) {
      if (entry.value['role'] == role) {
        try {
          entry.key.sink.add(message);
        } catch (e) {
          print('Error sending to channel: $e');
          removeConnection(entry.key);
        }
      }
    }
  }
  
  // Broadcast to specific user
  void broadcastToUser(String userId, Map<String, dynamic> booking) {
    final message = jsonEncode({
      'type': 'booking_updated',
      'data': booking,
    });
    
    print('Broadcasting to user: $userId');
    
    for (final entry in _connections.entries) {
      if (entry.value['userId'] == userId) {
        try {
          entry.key.sink.add(message);
        } catch (e) {
          print('Error sending to channel: $e');
          removeConnection(entry.key);
        }
      }
    }
  }
  
  // Get total connections count
  int get connectionCount => _connections.length;
}

// Singleton instance
final bookingWebSocketHandler = BookingWebSocketHandler();

// WebSocket handler for Shelf
Handler webSocketHandler() {
  return webSocketHandler((WebSocketChannel channel, String? protocol) {
    // Extract userId and role from the connection (will be set by the client)
    // For now, we'll add connection without auth info
    // In production, you should validate the WebSocket connection with a token
    bookingWebSocketHandler.addConnection(channel, null, null);
    
    channel.stream.listen(
      (message) {
        // Handle incoming messages from clients
        print('Received message: $message');
        
        // Client can send auth info
        try {
          final data = jsonDecode(message);
          if (data['type'] == 'auth') {
            bookingWebSocketHandler.addConnection(
              channel,
              data['userId'],
              data['role'],
            );
          }
        } catch (e) {
          print('Error parsing message: $e');
        }
      },
      onDone: () {
        bookingWebSocketHandler.removeConnection(channel);
      },
      onError: (error) {
        print('WebSocket error: $error');
        bookingWebSocketHandler.removeConnection(channel);
      },
    );
  });
}
