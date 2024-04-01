import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:untitled/screens/explore/explore.dart';
import 'package:untitled/screens/home/home.dart';
import 'package:untitled/screens/home/provider.dart';

import 'explore/provider.dart';

class IndexPage extends StatefulWidget {
  @override
  _IndexPageState createState() => _IndexPageState();
}

class _IndexPageState extends State<IndexPage> {
  int _currentIndex = 1;
  final List<Widget> _children = [
    HomePage(),
    ExplorePage()
  ];

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => HomeProvider()),
        ChangeNotifierProvider(create: (context) => ExploreProvider()),
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
              label: 'Edit',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.explore),
              label: 'Explore',
            ),
          ],
        ),
      ),
    );
  }
}

class Tab1Page extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Tab 1 Page'));
  }
}

class Tab2Page extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Tab 2 Page'));
  }
}

class Tab3Page extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Tab 3 Page'));
  }
}