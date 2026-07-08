import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 2), () {
      Get.offAllNamed('/tabs');
    });

    return SafeArea(
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE8F0FE),
              Color(0xFFD4E4FF),
              Color(0xFFF0F5FF),
              Colors.white,
            ],
            stops: [0.0, 0.3, 0.6, 1.0],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Spacer(flex: 2),
            Text(
              '让学习更简单',
              style: TextStyle(
                fontSize: 45,
                fontWeight: FontWeight.w500,
                fontStyle: FontStyle.italic,
                color: const Color(0xFF0066FF),
              ),
            ),
            const Spacer(flex: 3),
            Container(
              margin: EdgeInsets.only(bottom: 60),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      border:
                          Border.all(color: const Color(0xFF0066FF), width: 2),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Image.asset(
                      'assets/images/logo.png',
                      width: 35,
                      height: 35,
                      fit: BoxFit.contain,
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    '海豚侠',
                    style: TextStyle(
                      fontSize: 25,
                      color: const Color(0xFF0066FF),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
