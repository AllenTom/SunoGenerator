import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:untitled/api/client.dart';
import 'package:untitled/player_provider.dart';
import 'package:untitled/screens/home/home.dart';
import 'package:untitled/store.dart';
import 'package:untitled/user_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => UserProvider()),
      ChangeNotifierProvider(create: (context) => PlayerProvider()),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SunoGenerator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  initApp() async {
    AppDataStore store = AppDataStore();
    await AppDataStore().refresh();
    User? lastLogin = store.getLastLoginUser();
    if (lastLogin != null) {
      SunoClient().cookie = lastLogin.token;
    }

  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: initApp(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return HomePage();
        }
        return Container();
      },
    );
  }
}
