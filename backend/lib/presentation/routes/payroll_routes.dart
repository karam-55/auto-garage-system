import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../../domain/entities/payroll_settings.dart';
import '../../domain/entities/salary_payment.dart';
import '../../domain/repositories/payroll_settings_repository.dart';
import '../../domain/repositories/salary_payment_repository.dart';
import '../../infrastructure/repositories/payroll_settings_repository_impl.dart';
import '../../infrastructure/repositories/salary_payment_repository_impl.dart';
import '../middlewares/auth_middleware.dart';
import '../../infrastructure/database/database_connection.dart';
import '../../application/usecases/get_payroll_settings_usecase.dart';
import '../../application/usecases/update_payroll_settings_usecase.dart';
import '../../application/usecases/generate_monthly_salary_payments_usecase.dart';
import '../../application/usecases/pay_salary_usecase.dart';
import '../../application/usecases/get_monthly_payroll_report_usecase.dart';
import '../../domain/entities/role.dart';

class PayrollRoutes {
  final PayrollSettingsRepository _settingsRepository;
  final SalaryPaymentRepository _salaryRepository;
  final AuthMiddleware _authMiddleware;
  final GetPayrollSettingsUseCase _getSettingsUseCase;
  final UpdatePayrollSettingsUseCase _updateSettingsUseCase;
  final GenerateMonthlySalaryPaymentsUseCase _generatePaymentsUseCase;
  final PaySalaryUseCase _paySalaryUseCase;
  final GetMonthlyPayrollReportUseCase _getReportUseCase;

  PayrollRoutes(
    this._settingsRepository,
    this._salaryRepository,
    this._authMiddleware,
    this._getSettingsUseCase,
    this._updateSettingsUseCase,
    this._generatePaymentsUseCase,
    this._paySalaryUseCase,
    this._getReportUseCase,
  );

  factory PayrollRoutes.create(DatabaseConnection db, AuthMiddleware authMiddleware) {
    final settingsRepository = PayrollSettingsRepositoryImpl(db);
    final salaryRepository = SalaryPaymentRepositoryImpl(db);
    final getSettingsUseCase = GetPayrollSettingsUseCase(settingsRepository);
    final updateSettingsUseCase = UpdatePayrollSettingsUseCase(settingsRepository);
    final generatePaymentsUseCase = GenerateMonthlySalaryPaymentsUseCase(salaryRepository, settingsRepository);
    final paySalaryUseCase = PaySalaryUseCase(salaryRepository, null);
    final getReportUseCase = GetMonthlyPayrollReportUseCase(salaryRepository);
    
    return PayrollRoutes(
      settingsRepository,
      salaryRepository,
      authMiddleware,
      getSettingsUseCase,
      updateSettingsUseCase,
      generatePaymentsUseCase,
      paySalaryUseCase,
      getReportUseCase,
    );
  }

  Router get router {
    final router = Router();

    // GET /payroll/settings
    router.get('/payroll/settings', _authMiddleware.authenticate()(_authMiddleware.requireAnyRole([Role.OWNER, Role.ACCOUNTANT])(_getSettings)));

    // PUT /payroll/settings
    router.put('/payroll/settings', _authMiddleware.authenticate()(_authMiddleware.requireAnyRole([Role.OWNER])(_updateSettings)));

    // POST /payroll/generate
    router.post('/payroll/generate', _authMiddleware.authenticate()(_authMiddleware.requireAnyRole([Role.OWNER, Role.ACCOUNTANT])(_generatePayments)));

    // GET /payroll/salaries
    router.get('/payroll/salaries', _authMiddleware.authenticate()(_authMiddleware.requireAnyRole([Role.OWNER, Role.MANAGER, Role.ACCOUNTANT])(_getSalaries)));

    // POST /payroll/salaries/:id/pay
    router.post('/payroll/salaries/<id>/pay', _authMiddleware.authenticate()(_authMiddleware.requireAnyRole([Role.OWNER, Role.ACCOUNTANT])(_paySalary)));

    // GET /payroll/report
    router.get('/payroll/report', _authMiddleware.authenticate()(_authMiddleware.requireAnyRole([Role.OWNER, Role.MANAGER, Role.ACCOUNTANT])(_getReport)));

    return router;
  }

  Future<Response> _getSettings(Request request) async {
    try {
      final settings = await _getSettingsUseCase.execute();
      return Response.ok(jsonEncode(settings.toJson()));
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to fetch payroll settings: $e'}),
      );
    }
  }

  Future<Response> _updateSettings(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;

      final currentSettings = await _getSettingsUseCase.execute();
      final updatedSettings = currentSettings.copyWith(
        monthlyWorkDays: data['monthly_work_days'] as int? ?? currentSettings.monthlyWorkDays,
        salaryPaymentDay: data['salary_payment_day'] as int? ?? currentSettings.salaryPaymentDay,
      );

      final result = await _updateSettingsUseCase.execute(updatedSettings);
      return Response.ok(jsonEncode(result.toJson()));
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to update payroll settings: $e'}),
      );
    }
  }

  Future<Response> _generatePayments(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;

      final monthYearStr = data['month_year'] as String;
      final monthYear = DateTime.parse(monthYearStr);
      final employees = data['employees'] as List<dynamic>;

      final payments = await _generatePaymentsUseCase.execute(monthYear, employees.cast<Map<String, dynamic>>());
      return Response.ok(jsonEncode({
        'message': 'Generated ${payments.length} salary payments',
        'payments': payments.map((p) => p.toJson()).toList(),
      }));
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to generate salary payments: $e'}),
      );
    }
  }

  Future<Response> _getSalaries(Request request) async {
    try {
      final params = request.url.queryParameters;
      DateTime? monthYear;

      if (params['month_year'] != null) {
        monthYear = DateTime.parse(params['month_year']!);
      }

      List<SalaryPayment> payments;
      if (monthYear != null) {
        payments = await _salaryRepository.findByMonthYear(monthYear);
      } else {
        payments = await _salaryRepository.findAllPayments();
      }

      return Response.ok(jsonEncode(payments.map((p) => p.toJson()).toList()));
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to fetch salary payments: $e'}),
      );
    }
  }

  Future<Response> _paySalary(Request request) async {
    try {
      final id = int.parse(request.params['id'] as String);
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;

      final paymentDate = DateTime.parse(data['payment_date'] as String);
      final paidByUserId = data['paid_by_user_id'] as String;

      await _paySalaryUseCase.execute(id, paymentDate, int.parse(paidByUserId));
      return Response.ok(jsonEncode({'message': 'Salary paid successfully'}));
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to pay salary: $e'}),
      );
    }
  }

  Future<Response> _getReport(Request request) async {
    try {
      final params = request.url.queryParameters;
      final monthYearStr = params['month_year'] as String;
      final monthYear = DateTime.parse(monthYearStr);

      final report = await _getReportUseCase.execute(monthYear);
      return Response.ok(jsonEncode({
        'month_year': report.monthYear.toIso8601String(),
        'payments': report.payments.map((p) => p.toJson()).toList(),
        'total_base_salary': report.totalBaseSalary,
        'total_bonuses': report.totalBonuses,
        'total_deductions': report.totalDeductions,
        'total_net_salary': report.totalNetSalary,
        'total_paid': report.totalPaid,
        'total_pending': report.totalPending,
      }));
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to fetch payroll report: $e'}),
      );
    }
  }
}
