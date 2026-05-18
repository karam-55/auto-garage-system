import '../../domain/repositories/vendor_repository.dart';

class DeleteVendorUseCase {
  final VendorRepository _vendorRepository;

  DeleteVendorUseCase(this._vendorRepository);

  Future<void> execute(int id) async {
    await _vendorRepository.delete(id);
  }
}
