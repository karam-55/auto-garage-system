import 'dart:io';
import 'dart:async';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

class SupabaseDnsResolver {
  static const String _supabaseDomain = 'epiqlptgiqskizfgmagj.supabase.co';
  static String? _cachedIPv4;
  
  /// Resolve DNS using Google DNS (8.8.8.8) instead of system DNS
  static Future<String?> resolveIPv4() async {
    // Return cached IP if available
    if (_cachedIPv4 != null) {
      print('Using cached IPv4: $_cachedIPv4');
      return _cachedIPv4;
    }
    
    try {
      print('Resolving DNS for $_supabaseDomain using Google DNS...');
      
      // Use Google DNS (8.8.8.8) for DNS lookup
      final ipv4 = await _resolveUsingGoogleDNS(_supabaseDomain);
      
      if (ipv4 != null) {
        print('Resolved IPv4: $ipv4');
        // Cache the result
        _cachedIPv4 = ipv4;
        return ipv4;
      } else {
        print('Failed to resolve using Google DNS, trying system DNS...');
        // Fallback to system DNS
        return await _resolveUsingSystemDNS(_supabaseDomain);
      }
    } catch (e) {
      print('DNS lookup failed: $e');
      return null;
    }
  }
  
  /// Resolve DNS using Google DNS (8.8.8.8)
  static Future<String?> _resolveUsingGoogleDNS(String domain) async {
    try {
      // Create DNS query
      final query = _buildDNSQuery(domain);
      
      // Send to Google DNS
      final socket = await Socket.connect('8.8.8.8', 53, timeout: const Duration(seconds: 5));
      socket.add(query);
      await socket.flush();
      
      // Read response
      final response = await socket.first;
      socket.close();
      
      // Parse response
      final ipv4 = _parseDNSResponse(response);
      return ipv4;
    } catch (e) {
      print('Google DNS lookup failed: $e');
      return null;
    }
  }
  
  /// Resolve DNS using system DNS
  static Future<String?> _resolveUsingSystemDNS(String domain) async {
    try {
      final addresses = await InternetAddress.lookup(domain);
      final ipv4Addresses = addresses.where((addr) => addr.type == InternetAddressType.IPv4).toList();
      
      if (ipv4Addresses.isEmpty) {
        return null;
      }
      
      return ipv4Addresses.first.address;
    } catch (e) {
      print('System DNS lookup failed: $e');
      return null;
    }
  }
  
  /// Build DNS query packet
  static Uint8List _buildDNSQuery(String domain) {
    final buffer = <int>[];
    
    // Header
    buffer.addAll([0x00, 0x01]); // Transaction ID
    buffer.addAll([0x01, 0x00]); // Flags (recursion desired)
    buffer.addAll([0x00, 0x01]); // QDCOUNT (1 question)
    buffer.addAll([0x00, 0x00]); // ANCOUNT
    buffer.addAll([0x00, 0x00]); // NSCOUNT
    buffer.addAll([0x00, 0x00]); // ARCOUNT
    
    // Question
    final labels = domain.split('.');
    for (final label in labels) {
      buffer.add(label.length);
      buffer.addAll(label.codeUnits);
    }
    buffer.add(0x00); // End of labels
    
    buffer.addAll([0x00, 0x01]); // QTYPE (A record)
    buffer.addAll([0x00, 0x01]); // QCLASS (IN)
    
    return Uint8List.fromList(buffer);
  }
  
  /// Parse DNS response packet
  static String? _parseDNSResponse(List<int> response) {
    try {
      // Skip header (12 bytes)
      var offset = 12;
      
      // Skip question section
      while (response[offset] != 0) {
        final length = response[offset];
        offset += length + 1;
      }
      offset += 5; // Skip null byte, QTYPE, QCLASS
      
      // Read ANCOUNT
      final ancount = (response[6] << 8) | response[7];
      
      if (ancount == 0) return null;
      
      // Skip name in answer
      if (response[offset] == 0xC0) {
        offset += 2; // Pointer
      } else {
        while (response[offset] != 0) {
          offset += response[offset] + 1;
        }
        offset += 1;
      }
      
      // Skip TYPE and CLASS
      offset += 8; // TYPE (2) + CLASS (2) + TTL (4)
      
      // Read RDLENGTH
      final rdlength = (response[offset] << 8) | response[offset + 1];
      offset += 2;
      
      // Read RDATA (IPv4 address)
      if (rdlength == 4) {
        final ipv4 = '${response[offset]}.${response[offset + 1]}.${response[offset + 2]}.${response[offset + 3]}';
        return ipv4;
      }
      
      return null;
    } catch (e) {
      print('Failed to parse DNS response: $e');
      return null;
    }
  }
  
  /// Get the base URL with IP or domain fallback
  static Future<String> getBaseUrl() async {
    final ipv4 = await resolveIPv4();
    
    if (ipv4 != null) {
      // Use IP address with custom HTTP client that adds Host header
      return 'https://$ipv4';
    } else {
      // Fallback to original domain
      return 'https://$_supabaseDomain';
    }
  }
  
  /// Get the Host header value
  static String getHostHeader() {
    return _supabaseDomain;
  }
}

/// Custom HTTP Client that adds Host header for IP-based requests
class CustomHttpClient extends IOClient {
  final String _hostHeader;
  
  CustomHttpClient(this._hostHeader) : super(HttpClient());
  
  @override
  Future<IOStreamedResponse> send(http.BaseRequest request) async {
    // Add Host header if using IP address
    if (request.url.host.contains('192.') || 
        request.url.host.contains('10.') ||
        request.url.host.contains('172.') ||
        request.url.host.contains('185.')) {
      request.headers['Host'] = _hostHeader;
      print('Adding Host header: $_hostHeader for URL: ${request.url}');
    }
    
    return super.send(request);
  }
}
