import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:roamify/screens/state.dart'; 
import 'package:roamify/screens/favorites_provider.dart';
import 'package:roamify/screens/wrapper.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => SettingsModel()),
        ChangeNotifierProvider(create: (context) => FavoritesProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsModel>(
      builder: (context, settings, child) {
        return GetMaterialApp(
          title: 'Roamify',
          theme: ThemeData(
            brightness: settings.darkMode ? Brightness.dark : Brightness.light,
            textTheme: TextTheme(
              bodyText2: TextStyle(fontSize: settings.fontSize),
            ),
          ),
          home: Wrapper(),
        );
      },
    );
  }
}
