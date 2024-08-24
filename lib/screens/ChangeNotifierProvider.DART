import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => SettingsModel(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsModel>(
      builder: (context, settings, child) {
        return MaterialApp(
          theme: ThemeData(
            brightness: settings.darkMode ? Brightness.dark : Brightness.light,
            textTheme: TextTheme(
              bodyText2: TextStyle(fontSize: settings.fontSize),
            ),
          ),
          home: HomePage(),
        );
      },
    );
  }
}
