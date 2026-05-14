import 'package:openapi_spec/openapi_spec.dart';

class OpenApiSpec {
  static OpenApiDocument get document {
    return OpenApiDocument(
      version: '3.0.0',
      info: Info(
        title: 'Auto Garage System API',
        version: '1.0.0',
        description: 'API for Auto Garage Management System',
      ),
      servers: [
        Server(url: 'http://localhost:8080', description: 'Local Development'),
        Server(url: 'https://auto-garage-system-backend.onrender.com', description: 'Production'),
      ],
      paths: {
        '/api/auth/login': PathItem(
          post: Operation(
            summary: 'Login user',
            requestBody: RequestBody(
              content: {
                'application/json': MediaType(
                  schema: Schema.object(properties: {
                    'username': Schema.string(),
                    'password': Schema.string(),
                  }),
                ),
              },
            ),
            responses: {
                '200': Response(
                  description: 'Login successful',
                  content: {
                    'application/json': MediaType(
                      schema: Schema.object(properties: {
                        'token': Schema.string(),
                        'refreshToken': Schema.string(),
                        'user': Schema.object(),
                      }),
                    ),
                  },
                ),
              },
          ),
        ),
        '/api/bookings': PathItem(
          get: Operation(
            summary: 'Get all bookings',
            responses: {
              '200': Response(
                description: 'List of bookings',
                content: {
                  'application/json': MediaType(
                    schema: Schema.array(
                      items: Schema.ref('#/components/schemas/Booking'),
                    ),
                  ),
                },
              ),
            },
          ),
          post: Operation(
            summary: 'Create a new booking',
            requestBody: RequestBody(
              content: {
                'application/json': MediaType(
                  schema: Schema.ref('#/components/schemas/BookingCreate'),
                ),
              },
            ),
            responses: {
              '201': Response(
                description: 'Booking created',
                content: {
                  'application/json': MediaType(
                    schema: Schema.ref('#/components/schemas/Booking'),
                  ),
                },
              ),
            },
          ),
        ),
        '/api/bookings/{id}': PathItem(
          get: Operation(
            summary: 'Get booking by ID',
            parameters: [
              Parameter(
                name: 'id',
                in: ParameterLocation.path,
                required: true,
                schema: Schema.string(),
              ),
            ],
            responses: {
              '200': Response(
                description: 'Booking details',
                content: {
                  'application/json': MediaType(
                    schema: Schema.ref('#/components/schemas/Booking'),
                  ),
                },
              ),
            },
          ),
        ),
      },
      components: Components(
        schemas: {
          'Booking': Schema.object(
            properties: {
              'id': Schema.string(),
              'customerId': Schema.string(),
              'vehicleId': Schema.string(),
              'status': Schema.string(),
              'customerName': Schema.string(),
              'vehicleMake': Schema.string(),
              'vehicleModel': Schema.string(),
              'licensePlate': Schema.string(),
              'createdAt': Schema.string(format: 'date-time'),
              'updatedAt': Schema.string(format: 'date-time'),
            },
          ),
          'BookingCreate': Schema.object(
            required: ['customerId', 'vehicleId'],
            properties: {
              'customerId': Schema.string(),
              'vehicleId': Schema.string(),
              'status': Schema.string(),
            },
          ),
        },
      ),
    );
  }
}
