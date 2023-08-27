import 'package:crypton/widget/crypton.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final themeData = ThemeData(
  useMaterial3: true,
  colorScheme:
      ColorScheme.fromSeed(brightness: Brightness.dark, seedColor: Colors.red),
  textTheme: GoogleFonts.latoTextTheme(),
);
void main() async {
  runApp(MaterialApp(
    themeMode: ThemeMode.system,
    darkTheme: ThemeData.dark(useMaterial3: true),
    debugShowCheckedModeBanner: false,
    home: const Crypton(),
  ));
}
