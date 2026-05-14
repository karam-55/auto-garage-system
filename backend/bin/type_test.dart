import 'package:backend/domain/entities/company_settings.dart';

void main() {
  final settings = CompanySettings(
    id: '123',
    companyName: 'Test',
    companyLogoUrl: null,
    createdAt: DateTime.now(),
    updatedAt: null,
  );
  print(settings);
}
