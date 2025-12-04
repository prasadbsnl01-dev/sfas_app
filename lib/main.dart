import 'package:flutter/material.dart';

import 'features/ctopup/screens/parent_ctop_input_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const SfasApp());
}

class SfasApp extends StatelessWidget {
  const SfasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SFAS POS View',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme, // <— use BSNL theme
      home: const ParentCtopInputScreen(),
    );
  }
}
