import 'package:crypton/widget/crypton.dart';
import 'package:flutter/material.dart';

void main() async {
  runApp(MaterialApp(
    themeMode: ThemeMode.system,
    darkTheme: ThemeData.dark(useMaterial3: true),
    debugShowCheckedModeBanner: false,
    home: const Crypton(),
  ));
}
