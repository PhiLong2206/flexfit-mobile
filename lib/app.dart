import 'package:flutter/material.dart';

class FlexFitApp extends StatelessWidget {
  const FlexFitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FlexFit',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('FlexFit'),
        ),
        body: const Center(
          child: Text('FlexFit Mobile'),
        ),
      ),
    );
  }
}