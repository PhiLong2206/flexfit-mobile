import 'package:flutter/foundation.dart';

class BookingRefreshNotifier extends ChangeNotifier {
  BookingRefreshNotifier._();

  static final BookingRefreshNotifier instance = BookingRefreshNotifier._();

  int _version = 0;

  int get version => _version;

  void notifyBookingsChanged() {
    _version++;
    notifyListeners();
  }
}
