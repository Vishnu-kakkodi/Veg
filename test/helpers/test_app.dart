import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:veegify/provider/AuthProvider/auth_provider.dart';
import 'package:veegify/provider/theme_provider.dart';

Widget createTestApp(Widget child) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ChangeNotifierProvider(create: (_) => AuthProvider()),
    ],
    child: MaterialApp(
      home: child,
    ),
  );
}
