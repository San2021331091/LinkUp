import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:vibely/screens/splash_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  static const _backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
        Color(0xFF1E3A8A), // Deep blue
    Color(0xFF3B82F6), // Bright blue
    Color(0xFF8B5CF6), // Purple
    ],
    stops: [0.0, 0.55, 1.0],
  );

  static const _systemUiStyle = SystemUiOverlayStyle(
    statusBarColor: Color.fromARGB(255, 16, 20, 20),
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Color.fromARGB(255, 18, 24, 24),
    systemNavigationBarIconBrightness: Brightness.light,
  );

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'LinkUp',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.transparent,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          systemOverlayStyle: _systemUiStyle,
        ),
      ),
      builder: (context, child) {
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: _systemUiStyle,
          child: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: _backgroundGradient,
            ),
            child: child ?? const SizedBox.shrink(),
          ),
        );
      },
      home: const SplashScreen(),
    );
  }
}