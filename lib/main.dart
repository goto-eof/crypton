import 'package:crypton/widget/crypton.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  windowManager.waitUntilReadyToShow().then((_) async {
    await windowManager.center();
    await windowManager.setResizable(false);
  });

  runApp(MaterialApp(
    themeMode: ThemeMode.system,
    darkTheme: ThemeData.dark(useMaterial3: true),
    debugShowCheckedModeBanner: false,
    home: Crypton(),
  ));
}
