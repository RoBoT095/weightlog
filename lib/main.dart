import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weightlog/constants/theme_colors.dart';

import 'package:weightlog/providers/theme_mode.dart';
import 'package:weightlog/screens/nav.dart';

void main() async {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'WeightLog App',
        theme: AppThemes.lightDefault,
        darkTheme: AppThemes.darkDefault,
        themeMode: themeMode,
        home: const NavScreen());
  }
}
