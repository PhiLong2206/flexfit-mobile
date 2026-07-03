import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/constants/app_constants.dart';
import 'core/network/payment_deep_link_service.dart';
import 'core/di/injection_container.dart';
import 'features/ai/presentation/providers/ai_coach_provider.dart';
import 'features/auth/presentation/screens/auth_gate_page.dart';
import 'features/membership/data/credit_refresh_notifier.dart';
import 'features/membership/presentation/providers/membership_provider.dart';
import 'features/membership/presentation/screens/membership_page.dart';
import 'features/notification/presentation/providers/notification_provider.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

class FlexFitApp extends StatefulWidget {
  const FlexFitApp({super.key});

  @override
  State<FlexFitApp> createState() => _FlexFitAppState();
}

class _FlexFitAppState extends State<FlexFitApp> {
  StreamSubscription<PaymentDeepLinkResult>? _paymentLinkSub;

  @override
  void initState() {
    super.initState();
    _initPaymentDeepLinks();
  }

  Future<void> _initPaymentDeepLinks() async {
    final initialLink = await PaymentDeepLinkService.instance.getInitialLink();
    if (initialLink != null) {
      _handlePaymentDeepLink(initialLink);
    }

    _paymentLinkSub = PaymentDeepLinkService.instance.links.listen(
      _handlePaymentDeepLink,
    );
  }

  void _handlePaymentDeepLink(PaymentDeepLinkResult result) {
    final context = rootNavigatorKey.currentContext;
    if (context == null) return;

    final isSuccess = result.status == PaymentDeepLinkStatus.success;
    CreditRefreshNotifier.instance.notifyCreditChanged();

    rootNavigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MembershipPage()),
      (_) => false,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isSuccess ? 'Thanh toán thành công' : 'Bạn đã hủy giao dịch',
        ),
        backgroundColor: isSuccess ? Colors.green : AppConstants.primaryColor,
      ),
    );
  }

  @override
  void dispose() {
    _paymentLinkSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(
          create: (_) => AiCoachProvider(sl(), workoutSuggestionUseCase: sl()),
        ),
        ChangeNotifierProvider(create: (_) => MembershipProvider()),
      ],
      child: MaterialApp(
        navigatorKey: rootNavigatorKey,
        title: 'FlexFit',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          scaffoldBackgroundColor: AppConstants.backgroundColor,
          colorScheme: const ColorScheme.dark(
            primary: AppConstants.primaryColor,
            surface: AppConstants.surfaceColor,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: AppConstants.backgroundColor,
            elevation: 0,
            centerTitle: false,
          ),
        ),
        home: const AuthGatePage(),
      ),
    );
  }
}
