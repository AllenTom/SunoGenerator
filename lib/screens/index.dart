import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:untitled/screens/explore/explore.dart';
import 'package:untitled/screens/home/home.dart';
import 'package:untitled/screens/home/provider.dart';
import 'package:untitled/screens/library/library.dart';
import 'package:untitled/screens/library/provider.dart';

import '../generated/l10n.dart';
import 'explore/provider.dart';

class IndexPage extends StatefulWidget {
  @override
  _IndexPageState createState() => _IndexPageState();
}

class _IndexPageState extends State<IndexPage> {

  int _currentIndex = 0;
  final List<Widget> _children = [
    const HomePage(),
    const ExplorePage(),
    const LibraryPage()
  ];

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemNavigationBarColor: Theme.of(context).colorScheme.surface, // navigation bar color
    ));
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => HomeProvider()),
        ChangeNotifierProvider(create: (context) => ExploreProvider()),
        ChangeNotifierProvider(create: (context) => LibraryProvider()),
      ],
      child: Scaffold(
        body: _children[_currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          onTap: onTabTapped,
          currentIndex: _currentIndex,
          backgroundColor: Theme.of(context).colorScheme.surface,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.edit),
              label: S.of(context).TabEdit,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.explore),
              label: S.of(context).TabExplore,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.library_music_rounded),
              label: S.of(context).TabLibrary,
            ),
          ],
        ),
      ),
    );
  }
}