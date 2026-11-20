import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models/favorite_anime.dart';
import 'screens/login_screen.dart';
import 'screens/root_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(FavoriteAnimeAdapter());
  await Hive.openBox<FavoriteAnime>('favorites');

  final prefs = await SharedPreferences.getInstance();
  final bool isLogin = prefs.getBool('isLogin') ?? false;
  final String username = prefs.getString('username') ?? '';

  runApp(MyApp(isLogin: isLogin, username: username));
}

class MyApp extends StatelessWidget {
  final bool isLogin;
  final String username;

  const MyApp({super.key, required this.isLogin, required this.username});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Keripikroll',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212),
        primaryColor: const Color(0xFFFF6519),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFFF6519),
          surface: Color(0xFF1E1E1E),
        ),
      ),
      home: isLogin ? RootScreen(username: username) : const LoginScreen(),
    );
  }
}
