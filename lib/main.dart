import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:untitled/api/client.dart';
import 'package:untitled/login.dart';
import 'package:untitled/player_provider.dart';
import 'package:untitled/screens/home/home.dart';
import 'package:untitled/screens/index.dart';
import 'package:untitled/screens/login/login.dart';
import 'package:untitled/store.dart';
import 'package:untitled/user_provider.dart';

import 'generated/l10n.dart';

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
      localizationsDelegates: [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate
      ],
      supportedLocales: S.delegate.supportedLocales,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal,brightness: Brightness.dark),
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
  bool isFirst = true;
  Future<bool> initApp() async {
    AppDataStore store = AppDataStore();
    await AppDataStore().refresh();
    User? lastLogin = store.getLastLoginUser();
    if (lastLogin != null && !AppDataStore().logoutFlag) {
      SunoClient().cookie = lastLogin.token;
      await SunoClient().loginUser();
      if (context.mounted) {
        final playerProvider = Provider.of<PlayerProvider>(context, listen: false);
        playerProvider.loadHistory();
      }
      return true;
    }
    return false;
  }

  void didChangeDependencies() {
    super.didChangeDependencies();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemNavigationBarColor: Theme.of(context).colorScheme.surface, // navigation bar color
    ));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: initApp(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (isFirst) {
            isFirst = false;
            final userProvider = Provider.of<UserProvider>(context, listen: false);
            userProvider.loginInfo = SunoClient().userInfo;
          }
          if (snapshot.data == true) {
            WidgetsBinding.instance!.addPostFrameCallback((_) {
              Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => IndexPage()));
            });
          } else {
            WidgetsBinding.instance!.addPostFrameCallback((_) {
              Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => UserLoginPage()));
            });
          }
        }
        return Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          )
        );
      },
    );
  }
}