import 'package:event_manager/event/event_view.dart';
import 'package:flutter/material.dart';
import 'event/event_view.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: EventView(),
    );
  }
}
