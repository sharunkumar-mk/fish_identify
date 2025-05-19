import 'package:fish_identify/pages/home.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    initApp(); // initApp function called
    super.initState();
  }

  //function for 2 second delay for splash screen after 2 second delay screen moves to home screen
  void initApp() {
    Future.delayed(Duration(seconds: 2), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(),
        ), // this code move the screen to home page
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,

        children: [
          Lottie.asset(
            fit: BoxFit.cover,
            'assets/anim/fish.json',
            repeat: true,
            animate: true,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            spacing: 2,
            children: [
              Center(
                child: Text(
                  'Identify The Fish',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
              Text(
                'By Nibha',
                style: TextStyle(fontSize: 10, fontStyle: FontStyle.italic),
              ),
              SizedBox(width: 100, height: 2, child: LinearProgressIndicator()),
            ],
          ),
        ],
      ),
    );
  }
}
