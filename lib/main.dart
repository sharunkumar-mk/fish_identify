import 'package:fish_identify/pages/splash.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load(
    fileName: ".env",
  ); // load environmental variable. The gemni api key is stored in .env file for security
  runApp(const MyApp()); // flutter app run from runApp()
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: const SplashPage(), // initially loads Splash screen for user
    );
  }
}
