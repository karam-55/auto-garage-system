import '../entities/employee_contract.dart';

abstract class EmployeeContractRepository {
  Future<EmployeeContract> create(EmployeeContract contract);
  Future<EmployeeContract?> findById(int id);
  Future<List<EmployeeContract>> findByUserId(String userId);
  Future<List<EmployeeContract>> findAll();
  Future<EmployeeContract> update(EmployeeContract contract);
  Future<void> delete(int id);
}
