
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:home_brewery/api/auth.dart';
import 'package:home_brewery/components/splash.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        StreamProvider.value(
            value: AuthService().authStream, initialData: null),
      ],
      child: const MaterialApp(
        title: 'Home brewery',
        home: Splash(),
      ),
    );
  }
}
