import 'package:crud_firebase/pages/auth/login_page.dart';
import 'package:crud_firebase/pages/home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 3), () async {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => FirebaseAuth.instance.currentUser == null
              ? LoginPage()
              : HomePage(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff101518),
      body: Center(
        child: Image.asset(
          'assets/splash_image.png',
          width: 200.w,
          height: 200.h,
        ),
      ),
    );
  }
}
