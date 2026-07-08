import 'package:flutter/foundation.dart';

class CreditRefreshNotifier extends ChangeNotifier {
  CreditRefreshNotifier._();

  static final CreditRefreshNotifier instance = CreditRefreshNotifier._();

  int _version = 0;

  int get version => _version;

  void notifyCreditChanged() {
    _version++;
    notifyListeners();
  }
}
