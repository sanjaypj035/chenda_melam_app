import 'package:flutter/material.dart';

import 'auth/login.dart';



class LaunchScreen extends StatelessWidget {

  const LaunchScreen({super.key});



  @override

  Widget build(BuildContext context) {

    return GestureDetector(

      // Tapping anywhere on the image will navigate to login

      onTap: () {

        Navigator.pushReplacement(

          context,

          MaterialPageRoute(builder: (_) => const LoginPage()),

        );

      },

      child: Scaffold(

        body: Center(

          child: Image.asset(

            'assets/images/launch_bg.png',

            fit: BoxFit.scaleDown, // Shows full image without zooming

          ),

        ),

      ),

    );

  }

}