import 'package:alumni/firebase_options.dart';
import 'package:alumni/pages/home_page.dart';
import 'package:alumni/pages/questions_page_desktop.dart';
import 'package:alumni/pages/navigation_page.dart';
import 'package:alumni/pages/welcome_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: 'welcome',
      routes: {
        'welcome': (context) => const WelcomePage(),
        'basic-info-form': (context) => const HomePage(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == 'questions') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => AlumniTrackingForm(userInformation: args),
          );
        }
        if (settings.name == 'profile') {
          final args = settings.arguments as String;
          return MaterialPageRoute(
            builder: (context) => NavigationPage(docID: args),
          );
        }
        return null;
      },
    );
  }
}
