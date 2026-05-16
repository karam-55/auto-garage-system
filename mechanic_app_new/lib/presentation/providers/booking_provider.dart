import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/booking.dart';
import '../../domain/entities/mechanic_assignment.dart';
import '../../domain/usecases/get_available_bookings_usecase.dart';
import '../../domain/usecases/get_my_assignments_usecase.dart';
import '../../domain/usecases/assign_booking_usecase.dart';
import '../../domain/usecases/update_booking_status_usecase.dart';
import '../../domain/repositories/booking_repository.dart';
import '../../data/repositories/booking_repository_impl.dart';
import '../../data/datasources/remote/booking_remote_datasource.dart';
import '../../data/datasources/local/cache_datasource.dart';
import '../../core/network/dio_client.dart';
import '../../core/constants/backend_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_provider.dart';

final bookingRemoteDataSourceProvider = Provider<BookingRemoteDataSource>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return BookingRemoteDataSource(dioClient);
});

final bookingRepositoryProvider = FutureProvider<BookingRepository>((ref) async {
  final remoteDataSource = ref.watch(bookingRemoteDataSourceProvider);
  final cacheDataSource = await ref.watch(cacheDataSourceProvider.future);
  return BookingRepositoryImpl(remoteDataSource, cacheDataSource);
});

final getAvailableBookingsUseCaseProvider = FutureProvider<GetAvailableBookingsUseCase>((ref) async {
  final repository = await ref.watch(bookingRepositoryProvider.future);
  return GetAvailableBookingsUseCase(repository);
});

final getMyAssignmentsUseCaseProvider = FutureProvider<GetMyAssignmentsUseCase>((ref) async {
  final repository = await ref.watch(bookingRepositoryProvider.future);
  return GetMyAssignmentsUseCase(repository);
});

final assignBookingUseCaseProvider = FutureProvider<AssignBookingUseCase>((ref) async {
  final repository = await ref.watch(bookingRepositoryProvider.future);
  return AssignBookingUseCase(repository);
});

final updateBookingStatusUseCaseProvider = FutureProvider<UpdateBookingStatusUseCase>((ref) async {
  final repository = await ref.watch(bookingRepositoryProvider.future);
  return UpdateBookingStatusUseCase(repository);
});

final bookingStateProvider = StateNotifierProvider<BookingNotifier, BookingState>((ref) {
  return BookingNotifier(ref);
});

class BookingNotifier extends StateNotifier<BookingState> {
  final Ref _ref;

  BookingNotifier(this._ref) : super(BookingState.initial());

  Future<void> fetchAvailableBookings() async {
    state = state.copyWith(isLoadingAvailable: true);
    
    try {
      final useCase = await _ref.read(getAvailableBookingsUseCaseProvider.future);
      final bookings = await useCase();
      state = state.copyWith(
        availableBookings: bookings,
        isLoadingAvailable: false,
        availableError: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingAvailable: false,
        availableError: e.toString(),
      );
    }
  }

  Future<void> fetchMyAssignments() async {
    state = state.copyWith(isLoadingAssignments: true);
    
    try {
      final authState = _ref.read(authStateProvider);
      final userId = authState.user?.id ?? '';
      
      final useCase = await _ref.read(getMyAssignmentsUseCaseProvider.future);
      final assignments = await useCase(userId);
      state = state.copyWith(
        myAssignments: assignments,
        isLoadingAssignments: false,
        assignmentsError: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingAssignments: false,
        assignmentsError: e.toString(),
      );
    }
  }

  Future<void> assignBooking(String bookingId) async {
    state = state.copyWith(isAssigning: true);
    
    try {
      final authState = _ref.read(authStateProvider);
      final userId = authState.user?.id ?? '';
      
      final useCase = await _ref.read(assignBookingUseCaseProvider.future);
      await useCase(bookingId, userId);
      
      // Refresh both lists
      await fetchAvailableBookings();
      await fetchMyAssignments();
      
      state = state.copyWith(isAssigning: false, assignError: null);
    } catch (e) {
      state = state.copyWith(
        isAssigning: false,
        assignError: e.toString(),
      );
    }
  }

  Future<void> updateBookingStatus(String bookingId, String status) async {
    state = state.copyWith(isUpdating: true);
    
    try {
      final useCase = await _ref.read(updateBookingStatusUseCaseProvider.future);
      final success = await useCase(bookingId, status);
      
      if (success) {
        // Refresh assignments
        await fetchMyAssignments();
      }
      
      state = state.copyWith(isUpdating: false, updateError: null);
    } catch (e) {
      state = state.copyWith(
        isUpdating: false,
        updateError: e.toString(),
      );
    }
  }

  void clearErrors() {
    state = state.copyWith(
      availableError: null,
      assignmentsError: null,
      assignError: null,
      updateError: null,
    );
  }
}

class BookingState {
  final List<Booking> availableBookings;
  final List<MechanicAssignment> myAssignments;
  final bool isLoadingAvailable;
  final bool isLoadingAssignments;
  final bool isAssigning;
  final bool isUpdating;
  final String? availableError;
  final String? assignmentsError;
  final String? assignError;
  final String? updateError;

  BookingState({
    this.availableBookings = const [],
    this.myAssignments = const [],
    this.isLoadingAvailable = false,
    this.isLoadingAssignments = false,
    this.isAssigning = false,
    this.isUpdating = false,
    this.availableError,
    this.assignmentsError,
    this.assignError,
    this.updateError,
  });

  factory BookingState.initial() => BookingState();

  BookingState copyWith({
    List<Booking>? availableBookings,
    List<MechanicAssignment>? myAssignments,
    bool? isLoadingAvailable,
    bool? isLoadingAssignments,
    bool? isAssigning,
    bool? isUpdating,
    String? availableError,
    String? assignmentsError,
    String? assignError,
    String? updateError,
  }) {
    return BookingState(
      availableBookings: availableBookings ?? this.availableBookings,
      myAssignments: myAssignments ?? this.myAssignments,
      isLoadingAvailable: isLoadingAvailable ?? this.isLoadingAvailable,
      isLoadingAssignments: isLoadingAssignments ?? this.isLoadingAssignments,
      isAssigning: isAssigning ?? this.isAssigning,
      isUpdating: isUpdating ?? this.isUpdating,
      availableError: availableError,
      assignmentsError: assignmentsError,
      assignError: assignError,
      updateError: updateError,
    );
  }
}
