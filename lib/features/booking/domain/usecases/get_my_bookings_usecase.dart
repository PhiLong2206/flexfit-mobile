import '../../data/models/booking_model.dart';
import '../../data/repositories/booking_repository.dart';

// Currently Booking feature doesn't have an abstract Repository or UseCases.
// Since we are required to use Clean Architecture, we wrap the repository call in a UseCase.
class GetMyBookingsUseCase {
  const GetMyBookingsUseCase(this.repository);

  final BookingRepository repository;

  Future<List<BookingModel>> call() {
    return repository.getMyBookings();
  }
}
