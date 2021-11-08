import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:simpleadd/view/home_screen.dart';
import 'package:simpleadd/view/register_screen.dart';
import 'package:simpleadd/view/signin_screen.dart';
import 'package:simpleadd/view/upload_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (BuildContext context) => HomeScreen(),
        '/upload': (BuildContext context) => UploadScreen(),
        '/signIn': (BuildContext context) => SignInScreen(),
        '/register': (BuildContext context) => RegisterScreen(),
      },
    );
  }
}
