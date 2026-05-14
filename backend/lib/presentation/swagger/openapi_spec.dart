import 'dart:convert';

class OpenApiSpec {
  static String get document {
    return jsonEncode({
      'openapi': '3.0.0',
      'info': {
        'title': 'Auto Garage System API',
        'version': '1.0.0',
        'description': 'API for Auto Garage Management System',
      },
      'servers': [
        {'url': 'http://localhost:8080', 'description': 'Local Development'},
        {'url': 'https://auto-garage-system-backend.onrender.com', 'description': 'Production'},
      ],
      'paths': {
        '/api/auth/login': {
          'post': {
            'summary': 'Login user',
            'requestBody': {
              'content': {
                'application/json': {
                  'schema': {
                    'type': 'object',
                    'properties': {
                      'username': {'type': 'string'},
                      'password': {'type': 'string'},
                    },
                  },
                },
              },
            },
            'responses': {
              '200': {
                'description': 'Login successful',
                'content': {
                  'application/json': {
                    'schema': {
                      'type': 'object',
                      'properties': {
                        'token': {'type': 'string'},
                        'refreshToken': {'type': 'string'},
                        'user': {'type': 'object'},
                      },
                    },
                  },
                },
              },
            },
          },
        },
        '/api/bookings': {
          'get': {
            'summary': 'Get all bookings',
            'responses': {
              '200': {
                'description': 'List of bookings',
                'content': {
                  'application/json': {
                    'schema': {
                      'type': 'array',
                      'items': {'\$ref': '#/components/schemas/Booking'},
                    },
                  },
                },
              },
            },
          },
          'post': {
            'summary': 'Create a new booking',
            'requestBody': {
              'content': {
                'application/json': {
                  'schema': {'\$ref': '#/components/schemas/BookingCreate'},
                },
              },
            },
            'responses': {
              '201': {
                'description': 'Booking created',
                'content': {
                  'application/json': {
                    'schema': {'\$ref': '#/components/schemas/Booking'},
                  },
                },
              },
            },
          },
        },
      },
      'components': {
        'schemas': {
          'Booking': {
            'type': 'object',
            'properties': {
              'id': {'type': 'string'},
              'customerId': {'type': 'string'},
              'vehicleId': {'type': 'string'},
              'status': {'type': 'string'},
              'customerName': {'type': 'string'},
              'vehicleMake': {'type': 'string'},
              'vehicleModel': {'type': 'string'},
              'licensePlate': {'type': 'string'},
              'createdAt': {'type': 'string', 'format': 'date-time'},
              'updatedAt': {'type': 'string', 'format': 'date-time'},
            },
          },
          'BookingCreate': {
            'type': 'object',
            'required': ['customerId', 'vehicleId'],
            'properties': {
              'customerId': {'type': 'string'},
              'vehicleId': {'type': 'string'},
              'status': {'type': 'string'},
            },
          },
        },
      },
    });
  }
}
