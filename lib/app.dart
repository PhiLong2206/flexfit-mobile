import 'package:flutter/material.dart';
import 'screens/explore/explore_screen.dart';

class FlexFitApp extends StatelessWidget {
  const FlexFitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'FlexFit',
      debugShowCheckedModeBanner: false,
      home: ExploreScreen(),
    );
  }
}