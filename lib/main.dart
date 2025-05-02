import 'package:flutter/material.dart';

import 'custom_loader.dart';


/// Example of how to use the RollingLoader in an app
import 'package:flutter/material.dart';
import 'custom_star_rating.dart';
import 'custom_switch.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final ValueNotifier<ThemeMode> _themeMode = ValueNotifier(ThemeMode.light);

  @override
  void dispose() {
    _themeMode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: _themeMode,
      builder: (context, themeMode, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode: themeMode,
          home: Scaffold(
            body: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: CustomSwitch(
                    width: 220,
                    height: 110,
                    onThemeChanged: (isLightMode) {
                      _themeMode.value = isLightMode ? ThemeMode.light : ThemeMode.dark;
                    },
                  ),
                ),
                const SizedBox(height: 30),
                StarRating(
                  starCount: 5,
                  size: 32.0,
                  spacing: 3.0,
                  initialRating: 2,
                  isEnabled: true,
                  onRatingChanged: (rating) {
                    print('New rating: $rating');
                  },
                ),
                const SizedBox(height: 20),
                const StarRating(starCount: 3, size: 24.0, initialRating: 1, isEnabled: false, strokeColor: Colors.blueGrey, fillColor: Colors.amber),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Default loader
                    const RollingLoader(),
                    const SizedBox(height: 60),
                    // Custom styled loader
                    const RollingLoader(
                      size: 120.0,
                      lineColor: Colors.blue,
                      squareColor: Colors.amber,
                      lineWidth: 6.0,
                      duration: Duration(milliseconds: 2000),
                    ),
                    const SizedBox(height: 60),
                    // Smaller, faster loader
                    const RollingLoader(
                      size: 60.0,
                      lineColor: Colors.green,
                      squareColor: Colors.redAccent,
                      duration: Duration(milliseconds: 1500),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}