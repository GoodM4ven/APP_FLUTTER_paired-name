import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:paired_name_app/constants/colors.dart';
import 'package:paired_name_app/screens/home_screen.dart';

void main() async {
  await Hive.initFlutter();
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Paired Name App',
      theme: ThemeData(
        useMaterial3: true,
        splashColor: ConstantColors.pink,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        fontFamily: 'Ubuntu',
      ),
      home: const HomeScreen(),
    );
  }
}
