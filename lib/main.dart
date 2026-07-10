import 'package:flutter/material.dart';
import 'app.dart';
import 'core/di/injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  debugPrint('main started');
  debugPrint('runApp called');
  runApp(const FlexFitApp());
}
