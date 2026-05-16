import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/inventory_item.dart';
import '../../domain/usecases/get_inventory_usecase.dart';
import '../../domain/usecases/consume_part_usecase.dart';
import '../../domain/repositories/inventory_repository.dart';
import '../../data/repositories/inventory_repository_impl.dart';
import '../../data/datasources/remote/inventory_remote_datasource.dart';
import '../../data/datasources/local/cache_datasource.dart';
import '../../core/network/dio_client.dart';
import '../../core/constants/backend_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

final inventoryRemoteDataSourceProvider = Provider<InventoryRemoteDataSource>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return InventoryRemoteDataSource(dioClient);
});

final inventoryRepositoryProvider = FutureProvider<InventoryRepository>((ref) async {
  final remoteDataSource = ref.watch(inventoryRemoteDataSourceProvider);
  final cacheDataSource = await ref.watch(cacheDataSourceProvider.future);
  return InventoryRepositoryImpl(remoteDataSource, cacheDataSource);
});

final getInventoryUseCaseProvider = FutureProvider<GetInventoryUseCase>((ref) async {
  final repository = await ref.watch(inventoryRepositoryProvider.future);
  return GetInventoryUseCase(repository);
});

final consumePartUseCaseProvider = FutureProvider<ConsumePartUseCase>((ref) async {
  final repository = await ref.watch(inventoryRepositoryProvider.future);
  return ConsumePartUseCase(repository);
});

final inventoryStateProvider = StateNotifierProvider<InventoryNotifier, InventoryState>((ref) {
  return InventoryNotifier(ref);
});

class InventoryNotifier extends StateNotifier<InventoryState> {
  final Ref _ref;

  InventoryNotifier(this._ref) : super(InventoryState.initial());

  Future<void> fetchInventory() async {
    state = state.copyWith(isLoading: true);
    
    try {
      final useCase = await _ref.read(getInventoryUseCaseProvider.future);
      final items = await useCase();
      
      // Filter items with available variants only
      final availableItems = items
          .where((item) => item.variants.any((variant) => variant.isAvailable))
          .toList();
      
      state = state.copyWith(
        items: availableItems,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> consumePart(String variantId, int quantity, String bookingId) async {
    state = state.copyWith(isConsuming: true);
    
    try {
      final useCase = await _ref.read(consumePartUseCaseProvider.future);
      final success = await useCase(variantId, quantity, bookingId);
      
      if (success) {
        // Refresh inventory
        await fetchInventory();
      }
      
      state = state.copyWith(isConsuming: false, consumeError: null);
    } catch (e) {
      state = state.copyWith(
        isConsuming: false,
        consumeError: e.toString(),
      );
    }
  }

  void clearErrors() {
    state = state.copyWith(error: null, consumeError: null);
  }
}

class InventoryState {
  final List<InventoryItem> items;
  final bool isLoading;
  final bool isConsuming;
  final String? error;
  final String? consumeError;

  InventoryState({
    this.items = const [],
    this.isLoading = false,
    this.isConsuming = false,
    this.error,
    this.consumeError,
  });

  factory InventoryState.initial() => InventoryState();

  InventoryState copyWith({
    List<InventoryItem>? items,
    bool? isLoading,
    bool? isConsuming,
    String? error,
    String? consumeError,
  }) {
    return InventoryState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      isConsuming: isConsuming ?? this.isConsuming,
      error: error,
      consumeError: consumeError,
    );
  }
}
