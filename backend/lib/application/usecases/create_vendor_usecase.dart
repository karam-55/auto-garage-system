import '../../domain/entities/vendor.dart';
import '../../domain/repositories/vendor_repository.dart';

class CreateVendorUseCase {
  final VendorRepository _vendorRepository;

  CreateVendorUseCase(this._vendorRepository);

  Future<Vendor> execute(Vendor vendor) async {
    return await _vendorRepository.create(vendor);
  }
}
