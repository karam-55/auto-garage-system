import '../../domain/entities/vendor.dart';
import '../../domain/repositories/vendor_repository.dart';

class GetAllVendorsUseCase {
  final VendorRepository _vendorRepository;

  GetAllVendorsUseCase(this._vendorRepository);

  Future<List<Vendor>> execute() async {
    return await _vendorRepository.findAll();
  }
}
