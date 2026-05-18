import '../../domain/entities/vendor.dart';
import '../../domain/repositories/vendor_repository.dart';

class UpdateVendorUseCase {
  final VendorRepository _vendorRepository;

  UpdateVendorUseCase(this._vendorRepository);

  Future<Vendor> execute(Vendor vendor) async {
    return await _vendorRepository.update(vendor);
  }
}
